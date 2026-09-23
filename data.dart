import 'package:flutter/material.dart';

class Post {
  final String id, title, excerpt, body, category;
  final DateTime date;
  final Color color;
  final IconData icon;
  const Post(this.id, this.title, this.excerpt, this.body, this.category,
      this.date, this.color, this.icon);
}

const categories = ['AI', 'Apps', 'Business', 'Trading', 'Tech'];

String fmt(DateTime d) {
  const m = ['January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December'];
  return '${m[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
}

// Replace this sample list with your own ORIGINAL articles.
final posts = <Post>[
  Post('1', '5 AI prompts that save an hour a day', 'Simple prompts for summaries, emails and planning...',
      'Write your own article text here. Explain each prompt with an example.', 'AI', DateTime(2026, 9, 20), Colors.indigo, Icons.smart_toy),
  Post('2', 'How to set a trading risk limit', 'A fixed risk per trade keeps one bad day from ending your month...',
      'Write your own article text here.', 'Trading', DateTime(2026, 9, 18), Colors.teal, Icons.show_chart),
  Post('3', 'Best free apps for small business owners', 'Invoicing, scheduling and chat tools that cost nothing...',
      'Write your own article text here.', 'Business', DateTime(2026, 9, 15), Colors.orange, Icons.store),
  Post('4', 'Speed up your phone in 5 minutes', 'Clear cache, remove unused apps and update your system...',
      'Write your own article text here.', 'Tech', DateTime(2026, 9, 12), Colors.blueGrey, Icons.phone_android),
  Post('5', 'Password manager basics', 'Why one strong master password beats ten weak ones...',
      'Write your own article text here.', 'Apps', DateTime(2026, 9, 9), Colors.purple, Icons.lock),
  Post('6', 'Using AI to research a market', 'Ask better questions and always verify the sources...',
      'Write your own article text here.', 'AI', DateTime(2026, 9, 6), Colors.pink, Icons.psychology),
  Post('7', 'Build a simple content calendar', 'Plan a month of posts in under an hour...',
      'Write your own article text here.', 'Business', DateTime(2026, 9, 3), Colors.green, Icons.calendar_month),
  Post('8', 'What is a prop firm challenge?', 'How evaluations work and the rules that trip people up...',
      'Write your own article text here.', 'Trading', DateTime(2026, 8, 30), Colors.red, Icons.account_balance),
];
