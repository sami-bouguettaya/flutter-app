import 'package:flutter/material.dart';
import 'package:car_rental_app/models/car.dart';
import 'package:car_rental_app/widgets/car_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Toutes';
  RangeValues _priceRange = const RangeValues(0, 1000);
  bool _isLoading = false;
  List<Car> _cars = [];
  List<Car> _filteredCars = [];
  Set<String> _favorites = {};
  bool _showOnlyFavorites = false;
  String _sortBy = 'price'; // 'price', 'name', 'rating'

  final List<String> _categories = [
    'Toutes',
    'Citadine',
    'Berline',
    'SUV',
    'Break',
    'Sportive',
    'Utilitaire',
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadCars();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('favorites')?.toSet() ?? {};
    });
  }

  Future<void> _toggleFavorite(String carId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(carId)) {
        _favorites.remove(carId);
      } else {
        _favorites.add(carId);
      }
    });
    await prefs.setStringList('favorites', _favorites.toList());
  }

  Future<void> _loadCars() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Charger les voitures depuis l'API
      await Future.delayed(const Duration(seconds: 1)); // Simulation
      _cars = [
        Car(
          id: '1',
          brand: 'Renault',
          model: 'Clio',
          year: 2020,
          category: 'Citadine',
          images: ['https://example.com/clio.jpg'],
          price: 50.0,
          description: 'Renault Clio en excellent état',
          ownerId: 'user1',
          isAvailable: true,
          availableFrom: DateTime.now(),
          availableTo: DateTime.now().add(const Duration(days: 30)),
          features: ['Climatisation', 'GPS', 'Bluetooth'],
          location: 'Paris',
          rating: 4.5,
          reviews: [
            Review(
              userId: 'user2',
              userName: 'Jean Dupont',
              rating: 5,
              comment: 'Excellent véhicule, très propre et confortable.',
              date: DateTime.now().subtract(const Duration(days: 5)),
            ),
          ],
        ),
        Car(
          id: '2',
          brand: 'Peugeot',
          model: '308',
          year: 2021,
          category: 'Berline',
          images: ['https://example.com/308.jpg'],
          price: 65.0,
          description: 'Peugeot 308 en parfait état',
          ownerId: 'user3',
          isAvailable: true,
          availableFrom: DateTime.now(),
          availableTo: DateTime.now().add(const Duration(days: 45)),
          features: ['Climatisation', 'GPS', 'Bluetooth', 'Caméra de recul'],
          location: 'Lyon',
          rating: 4.8,
          reviews: [
            Review(
              userId: 'user4',
              userName: 'Marie Martin',
              rating: 5,
              comment: 'Voiture très agréable à conduire.',
              date: DateTime.now().subtract(const Duration(days: 2)),
            ),
          ],
        ),
      ];
      _applyFilters();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCars = _cars.where((car) {
        final matchesSearch = car.brand.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            car.model.toLowerCase().contains(_searchController.text.toLowerCase());
        final matchesCategory = _selectedCategory == 'Toutes' || car.category == _selectedCategory;
        final matchesPrice = car.price >= _priceRange.start && car.price <= _priceRange.end;
        final matchesFavorites = !_showOnlyFavorites || _favorites.contains(car.id);
        return matchesSearch && matchesCategory && matchesPrice && matchesFavorites;
      }).toList();

      // Trier les voitures
      switch (_sortBy) {
        case 'price':
          _filteredCars.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'name':
          _filteredCars.sort((a, b) => '${a.brand} ${a.model}'.compareTo('${b.brand} ${b.model}'));
          break;
        case 'rating':
          _filteredCars.sort((a, b) => b.rating.compareTo(a.rating));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher une voiture...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          ),
                        ),
                        onChanged: (value) => _applyFilters(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        _showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                        color: _showOnlyFavorites ? Colors.red : null,
                      ),
                      onPressed: () {
                        setState(() {
                          _showOnlyFavorites = !_showOnlyFavorites;
                        });
                        _applyFilters();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                            _applyFilters();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Prix: '),
                    Expanded(
                      child: RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 1000,
                        divisions: 20,
                        labels: RangeLabels(
                          '${_priceRange.start.round()}€',
                          '${_priceRange.end.round()}€',
                        ),
                        onChanged: (values) {
                          setState(() {
                            _priceRange = values;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Trier par:'),
                    DropdownButton<String>(
                      value: _sortBy,
                      items: const [
                        DropdownMenuItem(
                          value: 'price',
                          child: Text('Prix'),
                        ),
                        DropdownMenuItem(
                          value: 'name',
                          child: Text('Nom'),
                        ),
                        DropdownMenuItem(
                          value: 'rating',
                          child: Text('Note'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _sortBy = value;
                          });
                          _applyFilters();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCars.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune voiture trouvée',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredCars.length,
                        itemBuilder: (context, index) {
                          final car = _filteredCars[index];
                          return CarCard(
                            car: car,
                            isFavorite: _favorites.contains(car.id),
                            onFavoriteToggle: () => _toggleFavorite(car.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 