import 'package:flutter/material.dart';
import 'package:car_rental_app/models/user.dart';
import 'package:car_rental_app/models/car.dart';
import 'package:car_rental_app/screens/car_detail_screen.dart';
import 'package:car_rental_app/screens/add_car_screen.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  User? _user;
  List<Car> _userCars = [];
  List<Car> _reservations = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // TODO: Charger les données depuis l'API
    await Future.delayed(const Duration(seconds: 1)); // Simulation
    setState(() {
      _user = User(
        id: '1',
        name: 'Jean Dupont',
        email: 'jean.dupont@example.com',
        phone: '+213 555 123 456',
        profileImage: 'https://example.com/profile.jpg',
      );
      _userCars = [
        Car(
          id: '1',
          brand: 'Renault',
          model: 'Clio',
          year: 2020,
          category: 'Citadine',
          images: ['https://example.com/car1.jpg'],
          price: 50.0,
          description: 'Voiture en excellent état',
          ownerId: '1',
          availableFrom: DateTime.now(),
          availableTo: DateTime.now().add(const Duration(days: 30)),
          features: ['Climatisation', 'GPS'],
          location: 'Alger',
          isActive: true,
        ),
      ];
      _reservations = [];
      _isLoading = false;
    });
  }

  Future<void> _toggleCarStatus(Car car) async {
    setState(() {
      _userCars = _userCars.map((c) {
        if (c.id == car.id) {
          return c.copyWith(isActive: !c.isActive);
        }
        return c;
      }).toList();
    });

    // TODO: Mettre à jour le statut dans la base de données
    await Future.delayed(const Duration(seconds: 1)); // Simulation

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            car.isActive
                ? 'Annonce désactivée avec succès'
                : 'Annonce activée avec succès',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteCar(Car car) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'annonce'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer définitivement cette annonce ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _userCars.removeWhere((c) => c.id == car.id);
      });

      // TODO: Supprimer l'annonce de la base de données
      await Future.delayed(const Duration(seconds: 1)); // Simulation

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Annonce supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Erreur de chargement des données'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implémenter la déconnexion
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations de l'utilisateur
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(_user!.profileImage),
                      onBackgroundImageError: (_, __) {},
                      child: _user!.profileImage.isEmpty
                          ? Text(
                              _user!.name[0].toUpperCase(),
                              style: const TextStyle(fontSize: 32),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _user!.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(_user!.email),
                          const SizedBox(height: 4),
                          Text(_user!.phone),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Mes annonces
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mes annonces',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddCarScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une annonce'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_userCars.isEmpty)
              const Center(
                child: Text('Vous n\'avez pas encore d\'annonces'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _userCars.length,
                itemBuilder: (context, index) {
                  final car = _userCars[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              car.images.first,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error_outline),
                                );
                              },
                            ),
                          ),
                          title: Text('${car.brand} ${car.model}'),
                          subtitle: Text(
                            '${car.price.toStringAsFixed(2)}€ / jour',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  car.isActive
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: car.isActive
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                onPressed: () => _toggleCarStatus(car),
                                tooltip: car.isActive
                                    ? 'Désactiver l\'annonce'
                                    : 'Activer l\'annonce',
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // TODO: Naviguer vers l'écran de modification
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteCar(car),
                              ),
                            ],
                          ),
                        ),
                        if (!car.isActive)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            color: Colors.grey[200],
                            child: const Text(
                              'Annonce désactivée',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),

            // Mes réservations
            const Text(
              'Mes réservations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_reservations.isEmpty)
              const Center(
                child: Text('Vous n\'avez pas encore de réservations'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reservations.length,
                itemBuilder: (context, index) {
                  final car = _reservations[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          car.images.first,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error_outline),
                            );
                          },
                        ),
                      ),
                      title: Text('${car.brand} ${car.model}'),
                      subtitle: Text(
                        'Du ${DateFormat('dd/MM/yyyy').format(car.availableFrom)} au ${DateFormat('dd/MM/yyyy').format(car.availableTo)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
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
          ],
        ),
      ),
    );
  }
} 