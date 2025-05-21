import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/services/car_service.dart';
import 'package:car_rental_app/screens/car_detail_screen.dart';
import 'package:car_rental_app/models/car.dart';
import 'package:car_rental_app/providers/auth_provider.dart';
import 'package:car_rental_app/services/auth_service.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  bool _isLoading = false;
  List<Car> _cars = [];
  final _carService = CarService();
  String _searchQuery = '';
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 30000);
  final double _minPrice = 0;
  final double _maxPrice = 30000;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService =
        Provider.of<AuthProvider>(context, listen: false).authService;
    _loadCars();
  }

  Future<void> _loadCars() async {
    setState(() => _isLoading = true);
    try {
      final filters = {
        if (_searchQuery.isNotEmpty) 'search': _searchQuery,
        if (_selectedCategory != null && _selectedCategory != 'All')
          'category': _selectedCategory!,
        'minPrice': _priceRange.start.round().toString(),
        'maxPrice': _priceRange.end.round().toString(),
      };
      final cars = await _carService.getCars(filters: filters);
      setState(() {
        _cars = cars;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Filter Options',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                      'Price Range: ${_priceRange.start.round()} DA - ${_priceRange.end.round()} DA'),
                  RangeSlider(
                    values: _priceRange,
                    min: _minPrice,
                    max: _maxPrice,
                    divisions: (_maxPrice - _minPrice).toInt(),
                    labels: RangeLabels(
                      _priceRange.start.round().toString(),
                      _priceRange.end.round().toString(),
                    ),
                    onChanged: (values) {
                      setModalState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Category',
                      style: Theme.of(context).textTheme.titleMedium),
                  DropdownButton<String>(
                    value: _selectedCategory,
                    hint: const Text('Select Category'),
                    items: ['All', 'Sedan', 'SUV', 'Coupe', 'Hatchback']
                        .map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setModalState(() {
                        _selectedCategory = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _loadCars();
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _rejectCar(String carId) async {
    setState(() => _isLoading = true);
    try {
      final carService = Provider.of<CarService>(context, listen: false);
      await carService.rejectCar(carId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car rejected successfully!')),
        );
        _loadCars();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject car: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorite(String carId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez vous connecter pour ajouter des favoris')),
      );
      return;
    }

    try {
      print('Toggling favorite for car ID: $carId');
      final List<dynamic> currentFavorites = user['favorites'] ?? [];
      final isFavorite = currentFavorites.contains(carId);

      if (isFavorite) {
        print('Attempting to remove favorite');
        await authProvider.removeFavorite(carId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Retiré des favoris')),
          );
        }
      } else {
        print('Attempting to add favorite');
        await authProvider.addFavorite(carId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ajouté aux favoris')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur favori: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isAdmin = user?['role'] == 'admin';
    final List<dynamic> favoriteCarIds = user?['favorites'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voitures disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.all(8.0),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                _loadCars();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cars.isEmpty
                    ? const Center(child: Text('Aucune voiture trouvée.'))
                    : ListView.builder(
                        itemCount: _cars.length,
                        itemBuilder: (context, index) {
                          final car = _cars[index];
                          return Card(
                            child: ListTile(
                              leading: car.image.isNotEmpty
                                  ? Image.network(
                                      car.image,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.error_outline);
                                      },
                                    )
                                  : const Icon(Icons.directions_car),
                              title: Text('${car.brand} ${car.model}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${car.year} - ${car.pricePerDay} DA/jour'),
                                  if (car.ownerName?.isNotEmpty ?? false)
                                    Text('Propriétaire: ${car.ownerName}'),
                                  if (car.ownerPhone?.isNotEmpty ?? false)
                                    Text('Téléphone: ${car.ownerPhone}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${car.pricePerDay} DA/jour'),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      favoriteCarIds.contains(car.id)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: favoriteCarIds.contains(car.id)
                                          ? Colors.red
                                          : null,
                                    ),
                                    onPressed: () => _toggleFavorite(car.id),
                                  ),
                                  if (isAdmin)
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.red),
                                      onPressed: () => _rejectCar(car.id),
                                    ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CarDetailScreen(car: car),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: user != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add_car');
              },
              tooltip: 'Ajouter une voiture',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
