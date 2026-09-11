import 'package:flutter/material.dart';

import '../../features/session/modal/session_modal.dart';

class SessionCard extends StatefulWidget {
  final SessionModel session;
  final String id;

  const SessionCard({super.key, required this.session, required this.id});

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(),
        child: Text(widget.session.title),
      ),
    );
  }
}
