import 'dart:io';
import 'package:flutter/material.dart';
import '../models/dog.dart';
import 'add_dog_screen.dart';
import 'report_screen.dart';

class DogDetailScreen extends StatelessWidget {
  final Dog dog;

  const DogDetailScreen({super.key, required this.dog});

  String _getEmoji(String mood) {
    if (mood.contains(' ')) {
      return mood.split(' ').last;
    }
    return '🐶';
  }

  Color _getMoodColor(String mood) {
    if (mood.contains('Happy')) return Colors.orange;
    if (mood.contains('Lazy')) return Colors.blue;
    if (mood.contains('Sick')) return Colors.indigo;
    return Colors.deepPurple;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog Details', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                children: [
                  Hero(
                    tag: 'dog_icon_${dog.id}',
                    flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                      return DefaultTextStyle(
                        style: DefaultTextStyle.of(toHeroContext).style,
                        child: toHeroContext.widget,
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _getMoodColor(dog.mood).withOpacity(0.15),
                        shape: BoxShape.circle,
                        image: dog.imagePath != null
                          ? DecorationImage(
                              image: FileImage(File(dog.imagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                      ),
                      alignment: Alignment.center,
                      child: dog.imagePath == null
                        ? Text(
                            _getEmoji(dog.mood),
                            style: const TextStyle(fontSize: 48),
                          )
                        : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    dog.name,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getMoodColor(dog.mood).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          dog.mood.replaceAll(' ${_getEmoji(dog.mood)}', ''),
                          style: TextStyle(
                            fontSize: 16,
                            color: _getMoodColor(dog.mood),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: dog.healthStatus == 'Healthy' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(dog.healthStatus == 'Healthy' ? Icons.check_circle : Icons.warning_amber_rounded, size: 18, color: dog.healthStatus == 'Healthy' ? Colors.green : Colors.red),
                            const SizedBox(width: 6),
                            Text(
                              dog.healthStatus,
                              style: TextStyle(
                                fontSize: 16,
                                color: dog.healthStatus == 'Healthy' ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (dog.needsFeeding) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.local_dining, size: 18, color: Colors.orange),
                              SizedBox(width: 6),
                              Text(
                                'Hungry',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (dog.lastFedTime != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.restaurant, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 12),
                          Text(
                            'Last fed at ${TimeOfDay.fromDateTime(dog.lastFedTime!).format(context)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (dog.notes.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        dog.notes,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportScreen(dog: dog),
                    ),
                  );
                },
                icon: const Icon(Icons.bar_chart),
                label: const Text('View Report', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context, 'delete'),
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    label: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final updatedDog = await Navigator.push<Dog>(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => AddDogScreen(existingDog: dog),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            var tween = Tween(begin: const Offset(0.0, 0.05), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutQuart));
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(position: animation.drive(tween), child: child),
                            );
                          },
                        ),
                      );
                      if (updatedDog != null) {
                        if (!context.mounted) return;
                        Navigator.pop(context, updatedDog);
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
