import 'reflect-metadata';
import {
  BadRequestException, Body, ConflictException, Controller, Get, Headers,
  Injectable, Module, OnModuleDestroy, OnModuleInit, Post, UnauthorizedException,
} from '@nestjs/common';
import { APP_GUARD, NestFactory } from '@nestjs/core';
import { JwtModule, JwtService } from '@nestjs/jwt';
import { ThrottlerGuard, ThrottlerModule } from '@nestjs/throttler';
import { randomBytes, scrypt, timingSafeEqual } from 'node:crypto';
import { promisify } from 'node:util';
import { Pool } from 'pg';

const deriveKey = promisify(scrypt);
const issuer = 'cinemapedia';
type Account = { id: string; email: string; name: string; password_hash: string };

function credentials(body: unknown) {
  if (typeof body !== 'object' || body === null) throw new BadRequestException('Formulario inválido.');
  const form = body as Record<string, unknown>;
  const email = typeof form.email === 'string' ? form.email.trim().toLowerCase() : '';
  const password = typeof form.password === 'string' ? form.password : '';
  if (email.length > 254 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) ||
      password.length < 6 || password.length > 128) {
    throw new BadRequestException('Revisa el correo y la contraseña.');
  }
  const name = typeof form.name === 'string' ? form.name.trim() : '';
  return { email, password, name };
}

@Injectable()
class Accounts implements OnModuleInit, OnModuleDestroy {
  private readonly pool = new Pool({ connectionTimeoutMillis: 5000 });
  constructor(private readonly jwt: JwtService) {}

  async onModuleInit() {
    await this.pool.query(`
      CREATE TABLE IF NOT EXISTS accounts (
        id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        email text NOT NULL UNIQUE,
        name text NOT NULL,
        password_hash text NOT NULL
      )
    `);
  }

  async onModuleDestroy() {
    await this.pool.end();
  }

  async register(body: unknown) {
    const { email, password, name } = credentials(body);
    if (name.length < 2 || name.length > 100) throw new BadRequestException('Revisa el nombre.');
    const salt = randomBytes(16).toString('hex');
    const key = await deriveKey(password, salt, 64) as Buffer;
    const { rows } = await this.pool.query<Account>(
      'INSERT INTO accounts (email, name, password_hash) VALUES ($1, $2, $3) ON CONFLICT (email) DO NOTHING RETURNING *',
      [email, name, salt + ':' + key.toString('hex')],
    );
    if (!rows[0]) throw new ConflictException('Ya existe una cuenta con ese correo.');
    return this.session(rows[0]);
  }

  async login(body: unknown) {
    const { email, password } = credentials(body);
    const { rows } = await this.pool.query<Account>('SELECT * FROM accounts WHERE email = $1', [email]);
    const account = rows[0];
    const [salt, hash] = account?.password_hash.split(':') ?? ['00000000000000000000000000000000', '00'.repeat(64)];
    const key = await deriveKey(password, salt, 64) as Buffer;
    if (!timingSafeEqual(key, Buffer.from(hash, 'hex')) || !account) {
      throw new UnauthorizedException('Correo o contraseña incorrectos.');
    }
    return this.session(account);
  }

  async profile(authorization?: string) {
    const token = authorization?.match(/^Bearer (\S+)$/i)?.[1];
    if (!token) throw new UnauthorizedException('Inicia sesión.');
    let id: string;
    try {
      const claims = await this.jwt.verifyAsync<{ sub: string }>(token, { issuer, algorithms: ['HS256'] });
      if (typeof claims.sub !== 'string' || !/^\d+$/.test(claims.sub)) throw new Error('Invalid subject');
      id = claims.sub;
    } catch {
      throw new UnauthorizedException('La sesión expiró o es inválida.');
    }
    const { rows } = await this.pool.query<Account>('SELECT * FROM accounts WHERE id = $1', [id]);
    if (!rows[0]) throw new UnauthorizedException('Cuenta no disponible.');
    return this.publicAccount(rows[0]);
  }

  private publicAccount({ id, email, name }: Account) {
    return { id, email, name };
  }

  private async session(account: Account) {
    const token = await this.jwt.signAsync({ sub: account.id });
    return { account: this.publicAccount(account), token };
  }
}

@Controller('auth')
class AuthController {
  constructor(private readonly accounts: Accounts) {}

  @Post('register') register(@Body() body: unknown) { return this.accounts.register(body); }
  @Post('login') login(@Body() body: unknown) { return this.accounts.login(body); }
  @Get('me') me(@Headers('authorization') auth?: string) { return this.accounts.profile(auth); }
}

@Module({
  imports: [
    JwtModule.registerAsync({ useFactory: () => {
      const secret = process.env.JWT_SECRET;
      if (!secret || secret.length < 32) throw new Error('Configure JWT_SECRET with at least 32 characters');
      return { secret, signOptions: { expiresIn: '1h', issuer, algorithm: 'HS256' } };
    } }),
    ThrottlerModule.forRoot([{ ttl: 60_000, limit: 20 }]),
  ],
  controllers: [AuthController],
  providers: [Accounts, { provide: APP_GUARD, useClass: ThrottlerGuard }],
})
class AppModule {}

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableShutdownHooks();
  await app.listen(Number(process.env.PORT ?? 3000), process.env.HOST ?? '127.0.0.1');
}

bootstrap().catch(error => {
  console.error(error.message);
  process.exitCode = 1;
});
