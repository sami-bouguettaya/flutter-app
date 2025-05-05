import 'package:flutter/material.dart';
import 'package:car_rental_app/models/car.dart';
import 'package:car_rental_app/services/auth_service.dart';
import 'package:car_rental_app/services/car_service.dart';

class CarDetailScreen extends StatefulWidget {
  final Car car;

  const CarDetailScreen({super.key, required this.car});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  bool _isLoading = false;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _checkIfOwner();
  }

  Future<void> _checkIfOwner() async {
    final userData = await AuthService.getUserData();
    if (userData != null && mounted) {
      setState(() {
        _isOwner = userData['_id'] == widget.car.ownerId;
      });
    }
  }

  Future<void> _deleteCar() async {
    setState(() => _isLoading = true);
    try {
      await CarService.deleteCar(widget.car.id);
      if (mounted) {
        Navigator.pop(context);
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.car.brand} ${widget.car.model}'),
        actions: _isOwner
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _isLoading ? null : _deleteCar,
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              widget.car.image,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error_outline, size: 50),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.car.brand} ${widget.car.model}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Année: ${widget.car.year}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Prix par jour: ${widget.car.pricePerDay}€',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Localisation: ${widget.car.location}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.car.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Propriétaire',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(widget.car.ownerName),
                    subtitle: Text(widget.car.ownerEmail),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
