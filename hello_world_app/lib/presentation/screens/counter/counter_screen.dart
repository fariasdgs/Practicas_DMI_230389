import 'package:flutter/material.dart';

class CounterFunctionsScreen extends StatefulWidget {
  const CounterFunctionsScreen({super.key});

  @override
  State<CounterFunctionsScreen> createState() => _CounterFunctionsScreenState();
}

class _CounterFunctionsScreenState extends State<CounterFunctionsScreen> {
  int clickCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Functions'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                clickCounter = 0; // Reset the counter to zero
              });
              // Handle info button press
            },
          ),
        ],
        elevation: 0,
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'increment',
            tooltip: 'Sumar uno',
            onPressed: () {
              setState(() {
                clickCounter++;
              });
            },
            child: const Icon(Icons.plus_one),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'decrement',
            tooltip: 'Restar uno',
            onPressed: () {
              setState(() {
                clickCounter--;
              });
            },
            child: const Text('-1'),
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
                fontSize: 160,
                fontWeight: FontWeight.w100,
                color: clickCounter > 0
                    ? Colors.green
                    : clickCounter == 0
                    ? Colors.blue
                    : Colors.red,
              ),
            ),

            Text(
              'Click${clickCounter == 1 ? 's' : ''}',
              style: TextStyle(fontSize: 25),
            ),
          ],
        ),
      ),
    );
  }
}
