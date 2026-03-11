import 'package:flutter/material.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Inbox", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[900],
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              "User ${index + 1} liked your video",
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            subtitle: Text(
              "${index + 1} hour ago",
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
            ),
            trailing: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(4)),
            ),
          );
        },
      ),
    );
  }
}
