import 'package:flutter/material.dart';

class ParentDasboardScreen extends StatefulWidget {
  const ParentDasboardScreen({super.key});

  @override
  State<ParentDasboardScreen> createState() => _ParentDasboardScreenState();
}

class _ParentDasboardScreenState extends State<ParentDasboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('this is parent'),),);
  }
}
