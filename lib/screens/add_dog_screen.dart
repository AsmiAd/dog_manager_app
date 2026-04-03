import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/dog.dart';
import '../models/dog_history.dart';

class AddDogScreen extends StatefulWidget {
  final Dog? existingDog;

  const AddDogScreen({super.key, this.existingDog});

  @override
  State<AddDogScreen> createState() => _AddDogScreenState();
}

class _AddDogScreenState extends State<AddDogScreen> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _weightController = TextEditingController();
  
  String _selectedMood = 'Happy 😊';
  String _healthStatus = 'Healthy';
  
  String? _imagePath;
  DateTime? _birthDate;

  TimeOfDay? _lastFedTime;
  int _feedingInterval = 6;
  
  TimeOfDay? _lastWalkedTime;
  int _walkInterval = 8;

  final List<String> _moods = ['Happy 😊', 'Sick 🤒', 'Lazy 😴'];
  final List<String> _healthStatuses = ['Healthy', 'Sick'];
  final List<int> _intervals = [2, 4, 6, 8, 12, 24];

  @override
  void initState() {
    super.initState();
    if (widget.existingDog != null) {
      final dog = widget.existingDog!;
      _nameController.text = dog.name;
      _notesController.text = dog.notes;
      if (dog.weight != null) _weightController.text = dog.weight.toString();
      
      if (_moods.contains(dog.mood)) _selectedMood = dog.mood;
      if (_healthStatuses.contains(dog.healthStatus)) _healthStatus = dog.healthStatus;
      
      _imagePath = dog.imagePath;
      _birthDate = dog.birthDate;
      
      if (dog.lastFedTime != null) {
        _lastFedTime = TimeOfDay.fromDateTime(dog.lastFedTime!);
      }
      _feedingInterval = dog.feedingInterval;
      
      if (dog.lastWalkedTime != null) {
        _lastWalkedTime = TimeOfDay.fromDateTime(dog.lastWalkedTime!);
      }
      _walkInterval = dog.walkInterval;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _pickTime(bool isFed) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: isFed ? (_lastFedTime ?? TimeOfDay.now()) : (_lastWalkedTime ?? TimeOfDay.now()),
    );
    if (pickedTime != null) {
      setState(() {
        if (isFed) _lastFedTime = pickedTime;
        else _lastWalkedTime = pickedTime;
      });
    }
  }

  void _saveDog() {
    final name = _nameController.text.trim();
    final notes = _notesController.text.trim();
    final weightStr = _weightController.text.trim();

    if (name.isNotEmpty) {
      final nowTime = DateTime.now();

      DateTime? fedDateTime;
      if (_lastFedTime != null) {
        fedDateTime = DateTime(nowTime.year, nowTime.month, nowTime.day, _lastFedTime!.hour, _lastFedTime!.minute);
      }

      DateTime? walkedDateTime;
      if (_lastWalkedTime != null) {
        walkedDateTime = DateTime(nowTime.year, nowTime.month, nowTime.day, _lastWalkedTime!.hour, _lastWalkedTime!.minute);
      }

      final List<DogHistory> history = List.from(widget.existingDog?.history ?? []);
      final existingIndex = history.indexWhere((h) => 
          h.date.year == nowTime.year && 
          h.date.month == nowTime.month && 
          h.date.day == nowTime.day);
          
      if (existingIndex >= 0) {
        history[existingIndex] = DogHistory(
          date: nowTime,
          mood: _selectedMood,
          wasFed: history[existingIndex].wasFed || (_lastFedTime != null),
        );
      } else {
        history.add(DogHistory(
          date: nowTime,
          mood: _selectedMood,
          wasFed: _lastFedTime != null,
        ));
      }

      history.removeWhere((h) => nowTime.difference(h.date).inDays > 30);

      final newDog = Dog(
        id: widget.existingDog?.id ?? nowTime.microsecondsSinceEpoch.toString(),
        name: name,
        mood: _selectedMood,
        notes: notes,
        healthStatus: _healthStatus,
        lastFedTime: fedDateTime,
        feedingInterval: _feedingInterval,
        history: history,
        imagePath: _imagePath,
        weight: double.tryParse(weightStr),
        birthDate: _birthDate,
        lastWalkedTime: walkedDateTime,
        walkInterval: _walkInterval,
      );
      Navigator.pop(context, newDog);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a dog name', style: TextStyle(fontWeight: FontWeight.bold)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
      filled: true,
      fillColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildTimeTracker(String label, IconData icon, TimeOfDay? time, int interval, bool isFed) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: InkWell(
            onTap: () => _pickTime(isFed),
            borderRadius: BorderRadius.circular(16),
            child: InputDecorator(
              decoration: _buildInputDecoration(label, icon),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    time != null ? time.format(context) : 'Not Logged', 
                    style: TextStyle(
                      fontSize: 15, 
                      fontWeight: FontWeight.w500,
                      color: time != null ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey,
                    ),
                  ),
                  const Icon(Icons.edit_calendar, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: DropdownButtonFormField<int>(
            value: interval,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            items: _intervals.map((val) {
              return DropdownMenuItem<int>(
                value: val,
                child: Text('Every $val hrs', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  if (isFed) _feedingInterval = val;
                  else _walkInterval = val;
                });
              }
            },
            decoration: _buildInputDecoration('Interval', Icons.timer),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingDog != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Dog' : 'Add a Dog', style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Picker UI
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), width: 2),
                      image: _imagePath != null
                          ? DecorationImage(image: FileImage(File(_imagePath!)), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _imagePath == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 32, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(height: 4),
                              Text('Add Photo', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                decoration: _buildInputDecoration('Dog Name', Icons.pets),
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedMood,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      items: _moods.map((mood) {
                        return DropdownMenuItem<String>(
                          value: mood,
                          child: Text(mood, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedMood = value);
                      },
                      decoration: _buildInputDecoration('Mood', Icons.emoji_emotions_outlined),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _healthStatus,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      items: _healthStatuses.map((hs) {
                        return DropdownMenuItem<String>(
                          value: hs,
                          child: Row(
                            children: [
                              Icon(
                                hs == 'Healthy' ? Icons.check_circle : Icons.warning_amber_rounded,
                                color: hs == 'Healthy' ? Colors.green : Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(hs, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _healthStatus = value);
                      },
                      decoration: _buildInputDecoration('Health', Icons.monitor_heart_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      decoration: _buildInputDecoration('Weight (kg)', Icons.scale),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(16),
                      child: InputDecorator(
                        decoration: _buildInputDecoration('Birthday', Icons.cake),
                        child: Text(
                          _birthDate != null ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}' : 'Unknown', 
                          style: TextStyle(
                            fontSize: 15, 
                            fontWeight: FontWeight.w500,
                            color: _birthDate != null ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Text('Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
              ),
              _buildTimeTracker('Last Fed', Icons.restaurant, _lastFedTime, _feedingInterval, true),
              const SizedBox(height: 16),
              _buildTimeTracker('Last Walked', Icons.directions_walk, _lastWalkedTime, _walkInterval, false),
              
              const SizedBox(height: 20),
              TextField(
                controller: _notesController,
                decoration: _buildInputDecoration('Notes (Optional)', Icons.notes),
                maxLines: 3,
                style: const TextStyle(fontSize: 15),
              ),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveDog,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 4,
                  shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Save Dog', 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
