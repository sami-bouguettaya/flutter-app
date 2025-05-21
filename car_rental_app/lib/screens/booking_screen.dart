import 'package:flutter/material.dart';
import 'package:car_rental_app/models/car.dart';
import 'package:car_rental_app/services/booking_service.dart';
import 'package:car_rental_app/services/car_service.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final Car car;

  const BookingScreen({super.key, required this.car});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  bool _isCheckingAvailability = false;
  bool _isAvailable = true;
  final _bookingService = BookingService();
  final _carService = CarService();

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Si la date de fin est avant la nouvelle date de début, réinitialiser la date de fin
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });

      // Vérifier la disponibilité si les deux dates sont sélectionnées
      if (_startDate != null && _endDate != null) {
        _checkAvailability();
      }
    }
  }

  Future<void> _checkAvailability() async {
    if (_startDate == null || _endDate == null) return;

    setState(() => _isCheckingAvailability = true);
    try {
      final isAvailable = await _carService.checkCarAvailability(
        widget.car.id,
        _startDate!,
        _endDate!,
      );
      setState(() {
        _isAvailable = isAvailable;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isCheckingAvailability = false);
    }
  }

  Future<void> _createBooking() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Veuillez sélectionner les dates de début et de fin')),
      );
      return;
    }

    if (!_isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('La voiture n\'est pas disponible pour ces dates')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create the booking with status 'confirmed' directly in the backend route
      await _bookingService.createBooking(
        carId: widget.car.id,
        startDate: _startDate!,
        endDate: _endDate!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation confirmée avec succès!')),
        ); // Adjusted message
        Navigator.pop(context, true); // Retourner true pour indiquer le succès
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
    final dateFormat = DateFormat('dd/MM/yyyy');
    final days = _startDate != null && _endDate != null
        ? _endDate!.difference(_startDate!).inDays + 1
        : 0;
    final totalPrice = days * widget.car.pricePerDay;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver la voiture'),
      ),
      body: SingleChildScrollView(
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
                      '${widget.car.brand} ${widget.car.model}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                        '${widget.car.year} - ${widget.car.pricePerDay} DA/jour'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sélectionnez les dates',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(true),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_startDate == null
                        ? 'Date de début'
                        : dateFormat.format(_startDate!)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(false),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_endDate == null
                        ? 'Date de fin'
                        : dateFormat.format(_endDate!)),
                  ),
                ),
              ],
            ),
            if (_startDate != null && _endDate != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Récapitulatif',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Nombre de jours: $days'),
                      const SizedBox(height: 8),
                      Text('Prix par jour: ${widget.car.pricePerDay} DA'),
                      const SizedBox(height: 8),
                      Text('Prix Total: ${totalPrice.toStringAsFixed(2)} DA',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      if (_isCheckingAvailability)
                        const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Vérification de la disponibilité...'),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              _isAvailable ? Icons.check_circle : Icons.cancel,
                              color: _isAvailable ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isAvailable
                                  ? 'Voiture disponible pour ces dates'
                                  : 'Voiture non disponible pour ces dates',
                              style: TextStyle(
                                color: _isAvailable ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_isLoading || !_isAvailable) ? null : _createBooking,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Confirmer la réservation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
