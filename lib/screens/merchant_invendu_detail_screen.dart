import 'package:anti_gaspillage_app/models/invendu.dart';
import 'package:anti_gaspillage_app/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MerchantInvenduDetailScreen extends StatelessWidget {
  final Invendu invendu;

  const MerchantInvenduDetailScreen({Key? key, required this.invendu})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Détails de mon offre')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Infos de l'invendu
            Text(
              invendu.titre,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Statut: ${invendu.statut}',
              style: TextStyle(
                color: invendu.statut == 'disponible'
                    ? Colors.green
                    : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 30),

            // Section Réservations
            const Text(
              'Réservations pour cet article :',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestoreService.getReservationsForInvendu(invendu.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Text('Erreur de chargement des réservations');
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Aucune réservation pour le moment.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final data =
                          snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;
                      final date =
                          (data['createdAt'] as Timestamp?)?.toDate() ??
                          DateTime.now();

                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(
                            'Client ID: ...${data['consommateurId'].toString().substring(0, 5)}',
                          ), // On affiche juste une partie de l'ID pour l'instant
                          subtitle: Text(
                            'Réservé le : ${DateFormat('dd/MM/yyyy HH:mm').format(date)}',
                          ),
                          trailing: Text(data['statut'] ?? ''),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
