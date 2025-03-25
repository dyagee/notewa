import 'package:flutter/material.dart';

class CustomNoteCard extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final Color color;
  final VoidCallback? onDelete;

  const CustomNoteCard({
    super.key,
    required this.title,
    required this.content,
    required this.date,
    required this.color,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 70, // Ensure minimum height
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  content,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 20, color: Colors.black87),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.black, size: 32),
                onPressed: onDelete,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Date (Align to bottom right)
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              date,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
