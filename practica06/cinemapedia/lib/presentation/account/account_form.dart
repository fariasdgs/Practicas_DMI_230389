import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

class EmailInput extends FormzInput<String, String> {
  const EmailInput.pure() : super.pure('');
  const EmailInput.dirty(String value) : super.dirty(value);

  @override
  String? validator(String value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())
      ? null
      : 'Introduce un correo válido';
}

class PasswordInput extends FormzInput<String, String> {
  const PasswordInput.pure() : super.pure('');
  const PasswordInput.dirty(String value) : super.dirty(value);

  @override
  String? validator(String value) =>
      value.length >= 6 ? null : 'Usa al menos 6 caracteres';
}

class AccountFields {
  final EmailInput email;
  final PasswordInput password;
  const AccountFields({
    this.email = const EmailInput.pure(),
    this.password = const PasswordInput.pure(),
  });
  bool get valid => Formz.validate([email, password]);
}

class AccountFormCubit extends Cubit<AccountFields> {
  AccountFormCubit() : super(const AccountFields());
  void emailChanged(String value) => emit(
    AccountFields(email: EmailInput.dirty(value), password: state.password),
  );
  void passwordChanged(String value) => emit(
    AccountFields(email: state.email, password: PasswordInput.dirty(value)),
  );
  bool validate() {
    emit(
      AccountFields(
        email: EmailInput.dirty(state.email.value),
        password: PasswordInput.dirty(state.password.value),
      ),
    );
    return state.valid;
  }
}

class AccountForm extends StatelessWidget {
  final bool registering;
  final bool busy;
  final void Function(String email, String password, String name) onSubmit;

  const AccountForm({
    super.key,
    required this.registering,
    required this.busy,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => AccountFormCubit(),
    child: _Fields(registering: registering, busy: busy, onSubmit: onSubmit),
  );
}

class _Fields extends StatefulWidget {
  final bool registering;
  final bool busy;
  final void Function(String email, String password, String name) onSubmit;
  const _Fields({
    required this.registering,
    required this.busy,
    required this.onSubmit,
  });

  @override
  State<_Fields> createState() => _FieldsState();
}

class _FieldsState extends State<_Fields> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AccountFormCubit, AccountFields>(
        builder: (context, fields) {
          final cubit = context.read<AccountFormCubit>();
          return Form(
            key: _key,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.registering)
                    TextFormField(
                      controller: _name,
                      enabled: !widget.busy,
                      autofillHints: const [AutofillHints.name],
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                      ),
                      validator: (value) => (value?.trim().length ?? 0) < 2
                          ? 'Introduce tu nombre'
                          : null,
                    ),
                  TextField(
                    enabled: !widget.busy,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: 'Correo',
                      errorText: fields.email.displayError,
                    ),
                    onChanged: cubit.emailChanged,
                  ),
                  TextField(
                    enabled: !widget.busy,
                    obscureText: true,
                    autofillHints: [
                      widget.registering
                          ? AutofillHints.newPassword
                          : AutofillHints.password,
                    ],
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      errorText: fields.password.displayError,
                    ),
                    onChanged: cubit.passwordChanged,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: widget.busy
                        ? null
                        : () {
                            final valid = cubit.validate();
                            if (_key.currentState!.validate() && valid) {
                              widget.onSubmit(
                                cubit.state.email.value.trim(),
                                cubit.state.password.value,
                                _name.text.trim(),
                              );
                            }
                          },
                    child: Text(
                      widget.busy
                          ? 'Procesando…'
                          : widget.registering
                          ? 'Crear cuenta'
                          : 'Iniciar sesión',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
}
