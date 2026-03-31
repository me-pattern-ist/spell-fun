import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/math_model.dart';
import 'math_game_screen.dart';

class MathMenuScreen extends StatelessWidget {
  const MathMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Fun'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F7FA), Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMenuButton(context, 'Addition (+)', MathOperation.addition, Colors.orange),
              const SizedBox(height: 20),
              _buildMenuButton(context, 'Subtraction (-)', MathOperation.subtraction, Colors.blue),
              const SizedBox(height: 20),
              _buildMenuButton(context, 'Fractions (1/2)', MathOperation.fractions, Colors.purple),
              // Future: Multiplication, Division
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, MathOperation op, Color color) {
    return SizedBox(
      width: 250,
      height: 80,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MathGameScreen(operation: op),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
        ),
        child: Text(
          label,
          style: GoogleFonts.comicNeue(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
