import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/services/car_service.dart';
import 'package:car_rental_app/screens/car_detail_screen.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _cars = [];

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    setState(() => _isLoading = true);
    try {
      final carService = Provider.of<CarService>(context, listen: false);
      final cars = await carService.getCars();
      setState(() => _cars = cars);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voitures disponibles'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cars.isEmpty
              ? const Center(child: Text('Aucune voiture disponible'))
              : ListView.builder(
                  itemCount: _cars.length,
                  itemBuilder: (context, index) {
                    final car = _cars[index];
                    return Card(
                      child: ListTile(
                        leading: car['image'] != null
                            ? Image.network(
                                car['image'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error_outline);
                                },
                              )
                            : const Icon(Icons.directions_car),
                        title: Text('${car['brand']} ${car['model']}'),
                        subtitle: Text(
                            '${car['year']} - ${car['pricePerDay']}€/jour'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CarDetailScreen(car: car),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
