import 'package:flutter/material.dart';

class CounterFunctionsScreen extends StatefulWidget {
  const CounterFunctionsScreen({super.key});

  @override
  State<CounterFunctionsScreen> createState() => _CounterFunctionsScreenState();
}

class _CounterFunctionsScreenState extends State<CounterFunctionsScreen> {
  int clickCounter = 0;

  Color _getCounterColor(int value) {
    if (value == 0) {
      return Colors.blue;
    } else if (value > 0) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Counter Functions',
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                clickCounter = 0;
              });
            },
          ),
        ],
        elevation: 0,
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomButton(
            icon: Icons.plus_one,
            heroTag: 'increment',
            tooltip: 'Sumar uno',
            onPressed: () {
              setState(() {
                clickCounter++;
              });
            },
          ),
          const SizedBox(height: 10),
          CustomButton(
            icon: Icons.exposure_minus_1_outlined,
            heroTag: 'decrement',
            tooltip: 'Restar uno',
            onPressed: () {
              setState(() {
                clickCounter--;
              });
            },
          ),
          const SizedBox(height: 10),
          CustomButton(
            icon: Icons.refresh_rounded,
            heroTag: 'reset',
            tooltip: 'Reiniciar contador',
            onPressed: () {
              setState(() {
                clickCounter = 0;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$clickCounter',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 160,
                fontWeight: FontWeight.w100,
                color: _getCounterColor(clickCounter),
              ),
            ),

            Text(
              'Click${clickCounter == 1 ? '' : 's'}',
              style: const TextStyle(fontFamily: 'Montserrat', fontSize: 25),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String heroTag;
  final String tooltip;

  const CustomButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.heroTag,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      enableFeedback: true,
      elevation: 20,
      tooltip: tooltip,
      shape: const StadiumBorder(),
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}
