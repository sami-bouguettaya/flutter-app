import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/providers/auth_provider.dart';
import 'package:car_rental_app/services/car_service.dart';
import 'package:car_rental_app/models/car.dart';
import 'package:car_rental_app/services/booking_service.dart';
import 'package:car_rental_app/models/booking.dart';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  List<Car> _userCars = [];
  List<Car> _pendingCars = [];
  bool _isAdminLoading = false;
  List<Car> _rejectedCars = [];
  List<Booking> _userBookings = [];
  final _bookingService = BookingService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final carService = Provider.of<CarService>(context, listen: false);
      final user = authProvider.user;

      if (user != null) {
        final cars = await carService.getCars();
        setState(() {
          _userCars = cars.where((car) => car.ownerId == user['_id']).toList();
        });

        try {
          final bookings = await _bookingService.getUserBookings();
          setState(() {
            _userBookings = bookings;
          });
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Erreur lors du chargement des réservations: ${e.toString()}'),
              ),
            );
          }
          setState(() {
            _userBookings = [];
          });
        }

        if (user['role'] == 'admin') {
          setState(() => _isAdminLoading = true);
          try {
            final pendingCars =
                await carService.getPendingCars(token: user['token']);
            final rejectedCars =
                await carService.getRejectedCars(token: user['token']);
            setState(() {
              _pendingCars = pendingCars;
              _rejectedCars = rejectedCars;
            });
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur: ${e.toString()}'),
                ),
              );
            }
          } finally {
            setState(() => _isAdminLoading = false);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveCar(String carId) async {
    setState(() => _isAdminLoading = true);
    try {
      final carService = Provider.of<CarService>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.user?['token'];
      await carService.approveCar(carId, token: token);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car approved successfully!')),
        );
        _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
          ),
        );
      }
    } finally {
      setState(() => _isAdminLoading = false);
    }
  }

  Future<void> _rejectCar(String carId) async {
    setState(() => _isAdminLoading = true);
    try {
      final carService = Provider.of<CarService>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.user?['token'];
      final carToReject = _pendingCars.firstWhere((car) => car.id == carId,
          orElse: () => _rejectedCars.firstWhere((car) => car.id == carId,
              orElse: () => _userCars.firstWhere((car) => car.id == carId,
                  orElse: () => null as Car)));

      print(
          'ProfileScreen: Attempting to reject car with ID: $carId, Status: ${carToReject.available ? 'approved' : 'pending/rejected'}');

      print('ProfileScreen: Rejecting car with token: $token');
      await carService.rejectCar(carId, token: token);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car rejected successfully!')),
        );
        _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
          ),
        );
      }
    } finally {
      setState(() => _isAdminLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    setState(() => _isLoading = true);
    try {
      await _bookingService.cancelBooking(bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation annulée avec succès!')),
        );
        _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmBookingPayment(String bookingId) async {
    setState(() => _isAdminLoading = true);
    try {
      await _bookingService.updateBookingStatus(bookingId, 'confirmed');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Paiement confirmé et réservation mise à jour!')),
        );
        _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
          ),
        );
      }
    } finally {
      setState(() => _isAdminLoading = false);
    }
  }

  Future<void> _testBackendConnection() async {
    try {
      print('Testing backend connection to: ${ApiConfig.baseUrl}');
      final response = await http.get(Uri.parse(ApiConfig.baseUrl));
      print('Backend test response status: ${response.statusCode}');
      print('Backend test response body: ${response.body}');
    } catch (e) {
      print('Error testing backend connection: $e');
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String status) async {
    setState(() => _isLoading = true);
    try {
      await _bookingService.updateBookingStatus(bookingId, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Statut de la réservation mis à jour avec succès!')),
        );
        _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erreur lors de la mise à jour du statut : ${e.toString()}'),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isAdmin = user?['role'] == 'admin';

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Utilisateur non connecté'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informations personnelles',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Text('Nom: ${user['nom']}'),
                          Text('Email: ${user['email']}'),
                          if (user['telephone'] != null)
                            Text('Téléphone: ${user['telephone']}'),
                          if (user['adresse'] != null)
                            Text('Adresse: ${user['adresse']}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // User Bookings Section
                  if (!isAdmin) ...[
                    Text(
                      'Mes Réservations',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildUserBookingsList(),
                  ],
                  // Admin Bookings Section
                  if (isAdmin) ...[
                    Text(
                      'Gérer Toutes les Réservations (Admin)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildAdminBookingsList(),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Mes Voitures',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (_userCars.isEmpty)
                    const Center(
                      child: Text('Aucune voiture enregistrée'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _userCars.length,
                      itemBuilder: (context, index) {
                        final car = _userCars[index];
                        return Card(
                          child: ListTile(
                            title: Text('${car.brand} ${car.model}'),
                            subtitle:
                                Text('${car.year} - ${car.pricePerDay}€/jour'),
                            trailing: isAdmin
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () async {
                                          try {
                                            final carService =
                                                Provider.of<CarService>(context,
                                                    listen: false);
                                            await carService.deleteCar(car.id);
                                            await _loadUserData();
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Erreur: ${e.toString()}'),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                      if (_pendingCars.any((pendingCar) =>
                                          pendingCar.id == car.id))
                                        IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.red),
                                          onPressed: () => _rejectCar(car.id),
                                        ),
                                    ],
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      try {
                                        final carService =
                                            Provider.of<CarService>(context,
                                                listen: false);
                                        await carService.deleteCar(car.id);
                                        await _loadUserData();
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Erreur: ${e.toString()}'),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                          ),
                        );
                      },
                    ),
                  if (isAdmin)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          'Pending Car Listings (Admin)',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        if (_isAdminLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (_pendingCars.isEmpty)
                          const Center(child: Text('No pending car listings.'))
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _pendingCars.length,
                            itemBuilder: (context, index) {
                              final car = _pendingCars[index];
                              return Card(
                                child: ListTile(
                                  title: Text('${car.brand} ${car.model}'),
                                  subtitle: Text(
                                      '${car.year} - ${car.pricePerDay}€/jour'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check,
                                            color: Colors.green),
                                        onPressed: () => _approveCar(car.id),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.red),
                                        onPressed: () => _rejectCar(car.id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 24),
                        Text(
                          'Rejected Car Listings (Admin)',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        if (_isAdminLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (_rejectedCars.isEmpty)
                          const Center(child: Text('No rejected car listings.'))
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _rejectedCars.length,
                            itemBuilder: (context, index) {
                              final car = _rejectedCars[index];
                              return Card(
                                child: ListTile(
                                  title: Text('${car.brand} ${car.model}'),
                                  subtitle: Text(
                                      '${car.year} - ${car.pricePerDay}€/jour'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check,
                                            color: Colors.green),
                                        onPressed: () => _approveCar(car.id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildUserBookingsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_userBookings.isEmpty) {
      return const Text('Aucune réservation trouvée.');
    } else {
      final now = DateTime.now();
      final upcomingBookings = _userBookings
          .where((booking) => booking.endDate.isAfter(now))
          .toList();
      final pastBookings = _userBookings
          .where((booking) => !booking.endDate.isAfter(now))
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (upcomingBookings.isNotEmpty) ...[
            Text('Réservations à venir',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: upcomingBookings.length,
              itemBuilder: (context, index) {
                final booking = upcomingBookings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Voiture: ${booking.car?.brand ?? 'N/A'} ${booking.car?.model ?? 'N/A'}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                            'Du: ${booking.startDate.toLocal().toString().split(' ')[0]}'),
                        Text(
                            'Au: ${booking.endDate.toLocal().toString().split(' ')[0]}'),
                        Text('Prix Total: ${booking.totalPrice} DA'),
                        const SizedBox(height: 8),
                        Text('Statut: ${booking.status}'),
                        if (booking.status != 'cancelled')
                          Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton(
                              onPressed: () => _cancelBooking(booking.id),
                              child: const Text('Annuler'),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
          if (pastBookings.isNotEmpty) ...[
            Text('Réservations passées',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: pastBookings.length,
              itemBuilder: (context, index) {
                final booking = pastBookings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Voiture: ${booking.car?.brand ?? 'N/A'} ${booking.car?.model ?? 'N/A'}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                            'Du: ${booking.startDate.toLocal().toString().split(' ')[0]}'),
                        Text(
                            'Au: ${booking.endDate.toLocal().toString().split(' ')[0]}'),
                        Text('Prix Total: ${booking.totalPrice} DA'),
                        const SizedBox(height: 8),
                        Text('Statut: ${booking.status}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
          if (upcomingBookings.isEmpty && pastBookings.isEmpty)
            const Text('Aucune réservation trouvée pour cet utilisateur.'),
        ],
      );
    }
  }

  Widget _buildAdminBookingsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_userBookings.isEmpty) {
      // _userBookings contains all bookings for admin
      return const Text('Aucune réservation trouvée dans le système.');
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _userBookings.length,
        itemBuilder: (context, index) {
          final booking = _userBookings[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voiture: ${booking.car?.brand ?? 'N/A'} ${booking.car?.model ?? 'N/A'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text('Client: ${booking.user?['nom'] ?? 'N/A'}'),
                  Text('Email client: ${booking.user?['email'] ?? 'N/A'}'),
                  if (booking.user?['telephone'] != null &&
                      booking.user!['telephone']!.isNotEmpty)
                    Text('Téléphone client: ${booking.user!['telephone']}'),
                  const SizedBox(height: 8),
                  Text(
                      'Du: ${booking.startDate.toLocal().toString().split(' ')[0]}'),
                  Text(
                      'Au: ${booking.endDate.toLocal().toString().split(' ')[0]}'),
                  Text('Prix Total: ${booking.totalPrice} DA'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Statut: ',
                          style: Theme.of(context).textTheme.bodyLarge),
                      DropdownButton<String>(
                        value: booking.status,
                        items: [
                          'pending',
                          'confirmed',
                          'cancelled',
                          'completed'
                        ].map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null && newValue != booking.status) {
                            _updateBookingStatus(booking.id, newValue);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
