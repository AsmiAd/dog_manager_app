import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dog.dart';
import 'add_dog_screen.dart';
import 'dog_detail_screen.dart';
import '../main.dart'; 

enum SortOption { name, lastFed, mood }
enum FilterOption { all, hungry, sick, happy }

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Dog> dogs = [];
  final Set<String> _notifiedDogs = {};
  
  SortOption _currentSort = SortOption.name;
  FilterOption _currentFilter = FilterOption.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDogs();
  }

  void _sortDogs() {
    setState(() {
      switch (_currentSort) {
        case SortOption.name:
          dogs.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          break;
        case SortOption.lastFed:
          dogs.sort((a, b) {
            final aTime = a.lastFedTime;
            final bTime = b.lastFedTime;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return -1; 
            if (bTime == null) return 1;
            return aTime.compareTo(bTime);
          });
          break;
        case SortOption.mood:
          dogs.sort((a, b) => a.mood.compareTo(b.mood));
          break;
      }
    });
  }

  List<Dog> get filteredDogs {
    List<Dog> result = dogs;
    
    if (_searchQuery.trim().isNotEmpty) {
      result = result.where((dog) => dog.name.toLowerCase().contains(_searchQuery.trim().toLowerCase())).toList();
    }

    switch (_currentFilter) {
      case FilterOption.hungry:
        result = result.where((dog) => dog.needsFeeding).toList();
        break;
      case FilterOption.sick:
        result = result.where((dog) => dog.healthStatus == 'Sick').toList();
        break;
      case FilterOption.happy:
        result = result.where((dog) => dog.mood.contains('Happy')).toList();
        break;
      case FilterOption.all:
      default:
        break;
    }
    return result;
  }

  Future<void> _loadDogs() async {
    final prefs = await SharedPreferences.getInstance();
    final dogsJsonString = prefs.getString('dogs_list');
    if (dogsJsonString != null) {
      final List<dynamic> decodedList = jsonDecode(dogsJsonString);
      setState(() {
        dogs = decodedList.map((item) => Dog.fromJson(item)).toList();
      });
      _sortDogs();
      _triggerFeedingNotifications();
    }
  }

  void _triggerFeedingNotifications() {
    for (var dog in dogs) {
      if (dog.needsFeeding) {
        showFeedingWarning(dog.name);
      }
      if (dog.needsWalking) {
        showWalkWarning(dog.name);
      }
    }
  }

  Future<void> _saveDogs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(dogs.map((d) => d.toJson()).toList());
    await prefs.setString('dogs_list', encodedList);
    _triggerFeedingNotifications(); 
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.05);
        const end = Offset.zero;
        const curve = Curves.easeOutQuart;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _navigateToAddDogScreen() async {
    final newDog = await Navigator.push<Dog>(
      context,
      _createRoute(const AddDogScreen()),
    );

    if (newDog != null) {
      setState(() {
        dogs.add(newDog);
      });
      _sortDogs();
      _saveDogs();
    }
  }

  Future<void> _navigateToDogDetail(Dog dog) async {
    final result = await Navigator.push(
      context,
      _createRoute(DogDetailScreen(dog: dog)),
    );

    if (result == 'delete') {
      setState(() {
        dogs.removeWhere((d) => d.id == dog.id);
      });
      _saveDogs();
    } else if (result is Dog) {
      setState(() {
        final masterIndex = dogs.indexWhere((d) => d.id == dog.id);
        if (masterIndex != -1) dogs[masterIndex] = result;
      });
      _sortDogs();
      _saveDogs();
    }
  }

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

  Widget _buildDogAvatar(Dog dog) {
    if (dog.imagePath != null) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          image: DecorationImage(
            image: FileImage(File(dog.imagePath!)),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    String emoji = '🐶';
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _getMoodColor(dog.mood).withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        _getEmoji(dog.mood),
        style: const TextStyle(fontSize: 28),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final displayDogs = filteredDogs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog Manager', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          PopupMenuButton<FilterOption>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Dogs',
            onSelected: (FilterOption option) {
              setState(() {
                _currentFilter = option;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<FilterOption>>[
              const PopupMenuItem<FilterOption>(
                value: FilterOption.all,
                child: Text('Show All'),
              ),
              const PopupMenuItem<FilterOption>(
                value: FilterOption.hungry,
                child: Text('Show Hungry'),
              ),
              const PopupMenuItem<FilterOption>(
                value: FilterOption.sick,
                child: Text('Show Sick'),
              ),
              const PopupMenuItem<FilterOption>(
                value: FilterOption.happy,
                child: Text('Show Happy'),
              ),
            ],
          ),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort Dogs',
            onSelected: (SortOption option) {
              setState(() {
                _currentSort = option;
              });
              _sortDogs();
              _saveDogs(); 
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.name,
                child: Text('Sort by Name'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.lastFed,
                child: Text('Sort by Last Fed Time'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.mood,
                child: Text('Sort by Mood'),
              ),
            ],
          ),
          Row(
            children: [
              Icon(isDark ? Icons.dark_mode : Icons.light_mode, size: 20),
              Switch(
                value: isDark,
                onChanged: widget.onThemeChanged,
              ),
              const SizedBox(width: 8),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search dogs by name...',
                prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: displayDogs.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.pets,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _currentFilter == FilterOption.all 
                              ? 'It\'s awfully empty here! 🐕'
                              : 'No dogs match this filter! 🤷',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _currentFilter == FilterOption.all
                              ? 'Tap the Add Dog button below\nto register your first furry friend.'
                              : 'Try searching differently or tweaking filters.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    itemCount: displayDogs.length,
                    itemBuilder: (context, index) {
                      final dog = displayDogs[index];
                      return TweenAnimationBuilder(
                        key: ValueKey(dog.id),
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutQuart,
                        builder: (context, double value, child) {
                          return Transform.translate(
                            offset: Offset(0, 30 * (1 - value)),
                            child: Opacity(
                              opacity: value,
                              child: child,
                            ),
                          );
                        },
                        child: GestureDetector(
                          onTap: () => _navigateToDogDetail(dog),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                if (!isDark) 
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: _getMoodColor(dog.mood).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _getEmoji(dog.mood),
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dog.name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).textTheme.titleLarge?.color,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              dog.mood.replaceAll(' ${_getEmoji(dog.mood)}', ''),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: _getMoodColor(dog.mood),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: dog.healthStatus == 'Healthy' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                dog.healthStatus,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: dog.healthStatus == 'Healthy' ? Colors.green : Colors.red,
                                                ),
                                              ),
                                            ),
                                            if (dog.needsFeeding) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'Hungry',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                              ),
                                            ]
                                          ],
                                        ),
                                        if (dog.lastFedTime != null) ...[
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(Icons.restaurant, size: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Fed at ${TimeOfDay.fromDateTime(dog.lastFedTime!).format(context)}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        if (dog.notes.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            dog.notes,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                                              height: 1.3,
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color?.withOpacity(0.3)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddDogScreen,
        elevation: isDark ? 1 : 3,
        icon: const Icon(Icons.add),
        label: const Text('Add Dog', style: TextStyle(fontWeight: FontWeight.w600)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
