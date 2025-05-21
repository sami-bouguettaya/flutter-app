import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/providers/auth_provider.dart';
import 'package:car_rental_app/services/car_service.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageController = TextEditingController();
  String? _selectedCategory;
  final List<String> _predefinedFeatures = [
    'Climatisation',
    'Bluetooth',
    'GPS',
    'Sièges chauffants',
    'Toit ouvrant',
    'Caméra de recul',
    'Régulateur de vitesse',
  ];
  final List<String> _selectedFeatures = [];

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final carService = Provider.of<CarService>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      await carService.createCar(
        brand: _brandController.text,
        model: _modelController.text,
        year: int.parse(_yearController.text),
        pricePerDay: double.parse(_priceController.text),
        description: _descriptionController.text,
        location: _locationController.text,
        image: _imageController.text,
        owner: user['_id'],
        category: _selectedCategory!,
        features: _selectedFeatures,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voiture ajoutée avec succès')),
        );
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
        title: const Text('Ajouter une voiture'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(labelText: 'Marque'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une marque';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(labelText: 'Modèle'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un modèle';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(labelText: 'Année'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une année';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Veuillez entrer une année valide';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                          labelText: 'Prix par jour (DA)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un prix';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Veuillez entrer un prix valide';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une description';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _locationController,
                      decoration:
                          const InputDecoration(labelText: 'Localisation'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une localisation';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _imageController,
                      decoration:
                          const InputDecoration(labelText: 'URL de l\'image'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une URL d\'image';
                        }
                        return null;
                      },
                    ),
                    Text('Caractéristiques',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _predefinedFeatures.map((feature) {
                        return FilterChip(
                          label: Text(feature),
                          selected: _selectedFeatures.contains(feature),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedFeatures.add(feature);
                              } else {
                                _selectedFeatures.remove(feature);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Catégorie'),
                      value: _selectedCategory,
                      hint: const Text('Sélectionner une catégorie'),
                      items: ['SUV', 'Sedan', 'Coupe', 'Hatchback']
                          .map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner une catégorie';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      child: const Text('Ajouter'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
