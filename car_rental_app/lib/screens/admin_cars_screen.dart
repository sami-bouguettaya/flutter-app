import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/services/car_service.dart';
import 'package:car_rental_app/models/car.dart';
import 'package:car_rental_app/providers/auth_provider.dart';

class AdminCarsScreen extends StatefulWidget {
  const AdminCarsScreen({super.key});

  @override
  State<AdminCarsScreen> createState() => _AdminCarsScreenState();
}

class _AdminCarsScreenState extends State<AdminCarsScreen> {
  late Future<List<Car>> _pendingCarsFuture;

  @override
  void initState() {
    super.initState();
    print('AdminCarsScreen: initState called.');
    _pendingCarsFuture = _loadPendingCars().catchError((error) {
      // Log the error or handle it as needed
      print('Error fetching pending cars in initState: $error');
      // Re-throw the error so FutureBuilder can catch and display it
      throw error;
    });
  }

  Future<List<Car>> _loadPendingCars() async {
    print('AdminCarsScreen: _loadPendingCars called.');
    final carService = Provider.of<CarService>(context, listen: false);
    print('AdminCarsScreen: Calling carService.getPendingCars()...');
    try {
      final cars = await carService.getPendingCars();
      print('AdminCarsScreen: Received cars from getPendingCars.');
      return cars;
    } catch (e) {
      print('AdminCarsScreen: Error in _loadPendingCars: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading pending cars: ${e.toString()}')),
        );
      }
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    print('AdminCarsScreen: build called.');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Car Listings'),
      ),
      body: FutureBuilder<List<Car>>(
        future: _pendingCarsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('AdminCarsScreen: FutureBuilder connection state: waiting');
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print(
                'AdminCarsScreen: FutureBuilder has error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('AdminCarsScreen: FutureBuilder has data: empty or null');
            return const Center(child: Text('No pending car listings.'));
          } else {
            print(
                'AdminCarsScreen: FutureBuilder has data: ${snapshot.data!.length} cars');
            final pendingCars = snapshot.data!;
            return ListView.builder(
              itemCount: pendingCars.length,
              itemBuilder: (context, index) {
                final car = pendingCars[index];
                return ListTile(
                  leading: car.image.isNotEmpty
                      ? CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(car.image),
                        )
                      : const Icon(Icons.directions_car),
                  title: Text('${car.brand} ${car.model}'),
                  subtitle: Text('Owner: ${car.ownerName ?? 'N/A'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _approveCar(car.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectCar(car.id),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _approveCar(String carId) async {
    try {
      final carService = Provider.of<CarService>(context, listen: false);
      await carService.approveCar(carId);
      // Refresh the list after successful approval
      setState(() {
        _pendingCarsFuture = _loadPendingCars();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car approved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve car: ${e.toString()}')),
      );
    }
  }

  Future<void> _rejectCar(String carId) async {
    try {
      final carService = Provider.of<CarService>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.user?['token'];
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin token not available.')),
        );
        return;
      }
      await carService.rejectCar(carId, token: token);
      // Refresh the list after successful rejection
      setState(() {
        _pendingCarsFuture = _loadPendingCars();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car rejected successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject car: ${e.toString()}')),
      );
    }
  }
}
