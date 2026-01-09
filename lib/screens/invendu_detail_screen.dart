import 'package:flutter/material.dart';
import 'package:anti_gaspillage_app/models/invendu.dart';
import 'package:anti_gaspillage_app/services/firestore_service.dart';

class InvenduDetailScreen extends StatelessWidget {
  final Invendu invendu;

  const InvenduDetailScreen({Key? key, required this.invendu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(invendu.titre),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              invendu.titre,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              invendu.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Prix: ${invendu.prix.toStringAsFixed(2)} €',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Quantité disponible: ${invendu.quantite}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Localisation: ${invendu.localisation}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Statut: ${invendu.statut}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            if (invendu.statut == 'disponible')
              ElevatedButton(
                onPressed: () async {
                  try {
                    await FirestoreService().reserveInvendu(invendu.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invendu réservé avec succès!')),
                    );
                    Navigator.of(context).pop(); // Go back to the list
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de la réservation: ${e.toString()}')),
                    );
                  }
                },
                child: const Text('Réserver cet invendu'),
              )
            else
              Text(
                'Cet invendu est ${invendu.statut}.',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
