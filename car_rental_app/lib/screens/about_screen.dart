import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'CarShare',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Text(
              'À propos de CarShare',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'CarShare est une application de location de voitures entre particuliers. '
              'Notre mission est de faciliter la mise en relation entre propriétaires '
              'et locataires de véhicules, tout en offrant une expérience simple et sécurisée.',
            ),
            const SizedBox(height: 24),
            const Text(
              'Nos valeurs',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildValueCard(
              context,
              'Confiance',
              'Nous mettons tout en œuvre pour garantir la sécurité et la confiance entre nos utilisateurs.',
              Icons.security,
            ),
            const SizedBox(height: 16),
            _buildValueCard(
              context,
              'Simplicité',
              'Une interface intuitive et des processus simplifiés pour une expérience utilisateur optimale.',
              Icons.touch_app,
            ),
            const SizedBox(height: 16),
            _buildValueCard(
              context,
              'Économie',
              'Une solution économique pour les propriétaires et les locataires.',
              Icons.attach_money,
            ),
            const SizedBox(height: 32),
            const Text(
              'Contact',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pour toute question ou suggestion, n\'hésitez pas à nous contacter :\n'
              'Email : contact@carshare.com\n'
              'Téléphone : +33 1 23 45 67 89',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 