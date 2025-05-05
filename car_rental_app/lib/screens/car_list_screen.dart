import 'package:flutter/material.dart';
import 'package:car_rental_app/models/car.dart';
import 'package:car_rental_app/services/car_service.dart';
import 'package:car_rental_app/screens/car_detail_screen.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  List<Car> _cars = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedLocation = 'Tous';

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    try {
      final cars = await CarService.getAllCars();
      if (mounted) {
        setState(() {
          _cars = cars.map((car) => Car.fromJson(car)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  List<Car> get _filteredCars {
    return _cars.where((car) {
      final matchesSearch =
          car.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              car.model.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesLocation =
          _selectedLocation == 'Tous' || car.location == _selectedLocation;
      return matchesSearch && matchesLocation;
    }).toList();
  }

  List<String> get _locations {
    final locations = _cars.map((car) => car.location).toSet().toList();
    locations.sort();
    return ['Tous', ...locations];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voitures disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadCars,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Rechercher',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: _locations.map((location) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    label: Text(location),
                    selected: _selectedLocation == location,
                    onSelected: (selected) {
                      setState(() {
                        _selectedLocation = location;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCars.isEmpty
                    ? const Center(child: Text('Aucune voiture trouvée'))
                    : ListView.builder(
                        itemCount: _filteredCars.length,
                        itemBuilder: (context, index) {
                          final car = _filteredCars[index];
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CarDetailScreen(car: car),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    car.image,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.error_outline,
                                            size: 50),
                                      );
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${car.brand} ${car.model}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Année: ${car.year}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Prix par jour: ${car.pricePerDay}€',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Localisation: ${car.location}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
