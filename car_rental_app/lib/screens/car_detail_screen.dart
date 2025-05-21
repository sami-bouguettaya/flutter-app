import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/providers/auth_provider.dart';
import 'package:car_rental_app/services/car_service.dart';
import 'package:car_rental_app/models/car.dart';
import 'package:car_rental_app/screens/booking_screen.dart';

class CarDetailScreen extends StatefulWidget {
  final Car car;

  const CarDetailScreen({super.key, required this.car});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  bool _isLoading = false;
  int _currentRating = 0;
  TextEditingController _commentController = TextEditingController();

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content:
            const Text('Êtes-vous sûr de vouloir supprimer cette voiture ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final carService = Provider.of<CarService>(context, listen: false);
      await carService.deleteCar(widget.car.id);
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

  Future<void> _submitRating() async {
    if (_currentRating == 0) {
      // Rating is required, although the button is disabled if rating is 0
      return;
    }

    setState(() => _isLoading = true);

    try {
      final carService = Provider.of<CarService>(context, listen: false);
      // Assuming the backend response includes the updated car data or at least the new average rating
      // We might need to refetch the car details to update the UI accurately.
      final response = await carService.submitCarRating(
        widget.car.id, // Car ID
        _currentRating, // Rating (1-5)
        _commentController.text, // Comment
      );

      // Optionally refetch car details to show updated average rating and comments
      // This might require a method in CarService to get a car by ID with populated ratings
      // For now, let's just show a success message and clear the form.

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note soumise avec succès!')),
        );
        // Clear the form
        setState(() {
          _currentRating = 0;
          _commentController.clear();
        });
        // TODO: Consider refetching car details to update average rating and comments display
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erreur lors de la soumission de la note : ${e.toString()}')),
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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isOwner = user != null && widget.car.ownerId == user['_id'];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.car.brand} ${widget.car.model}'),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _handleDelete,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.car.image.isNotEmpty)
                    Image.network(
                      widget.car.image,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
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
                          'Prix par jour: ${widget.car.pricePerDay} DA',
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
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Propriétaire',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.car.ownerName,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Rating Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notes et Avis',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        // Display Average Rating
                        if (widget.car.rating > 0)
                          Row(
                            children: [
                              Text('Note moyenne:',
                                  style: Theme.of(context).textTheme.bodyLarge),
                              const SizedBox(width: 8),
                              Text(
                                  '${widget.car.rating.toStringAsFixed(1)} / 5',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 20),
                            ],
                          ) // Assuming car.rating holds the average rating
                        else
                          Text('Aucune note pour l\'instant.',
                              style: Theme.of(context).textTheme.bodyLarge),

                        const SizedBox(height: 16),

                        // Add a rating/comment form for logged-in users
                        if (user != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Soumettre votre note',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              // Rating input (using a simple row of stars for now)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(5, (index) {
                                  return IconButton(
                                    icon: Icon(
                                      index < _currentRating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _currentRating = index + 1;
                                      });
                                    },
                                  );
                                }),
                              ),
                              const SizedBox(height: 8),
                              // Comment input
                              TextFormField(
                                controller: _commentController,
                                decoration: const InputDecoration(
                                  labelText: 'Votre commentaire (Optionnel)',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _currentRating > 0
                                      ? _submitRating
                                      : null, // Enable button only if a rating is selected
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white)
                                      : const Text('Soumettre la note'),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookingScreen(car: widget.car),
                            ),
                          );
                          if (result == true) {
                            // Si la réservation a réussi, on peut rafraîchir les données si nécessaire
                            Navigator.pop(context, true);
                          }
                        },
                        child: const Text('Réserver cette voiture'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
