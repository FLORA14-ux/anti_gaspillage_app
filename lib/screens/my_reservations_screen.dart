import 'dart:convert';
import 'package:anti_gaspillage_app/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyReservationsScreen extends StatelessWidget {
  const MyReservationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Mes Réservations',
          style: TextStyle(color: Color(0xFF333333)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getReservationsForConsumer(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF27AE60)),
            );
          }

          if (snapshot.hasError) {
            // Affiche l'erreur dans la console pour récupérer le lien de création d'index
            print("Erreur Firestore (Mes Réservations): ${snapshot.error}");
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucune réservation trouvée.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final reservationData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final invenduId = reservationData['invenduId'];
              final date =
                  (reservationData['createdAt'] as Timestamp?)?.toDate() ??
                  DateTime.now();

              // On doit récupérer les infos de l'invendu pour afficher le titre et l'image
              return FutureBuilder<DocumentSnapshot>(
                future: firestoreService.getInvendu(invenduId),
                builder: (context, invenduSnapshot) {
                  if (invenduSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Card(
                      child: ListTile(title: Text('Chargement des détails...')),
                    );
                  }

                  if (!invenduSnapshot.hasData || invenduSnapshot.hasError) {
                    return const Card(
                      child: ListTile(title: Text('Information indisponible')),
                    );
                  }

                  // Si l'invendu a été supprimé par le commerçant
                  if (!invenduSnapshot.data!.exists) {
                    return Card(
                      child: ListTile(
                        title: const Text('Offre supprimée'),
                        subtitle: Text(DateFormat('dd/MM/yyyy').format(date)),
                      ),
                    );
                  }

                  final invenduData =
                      invenduSnapshot.data!.data() as Map<String, dynamic>;
                  final imageUrl = invenduData['imageUrl'] ?? '';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Builder(
                            builder: (context) {
                              if (imageUrl.isEmpty)
                                return const Icon(Icons.fastfood);
                              try {
                                if (imageUrl.startsWith('http')) {
                                  return Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                  );
                                }
                                return Image.memory(
                                  base64Decode(imageUrl),
                                  fit: BoxFit.cover,
                                );
                              } catch (e) {
                                return const Icon(Icons.broken_image);
                              }
                            },
                          ),
                        ),
                      ),
                      title: Text(
                        invenduData['titre'] ?? 'Sans titre',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantité: ${reservationData['quantite'] ?? 1}'),
                          Text(
                            'Le ${DateFormat('dd/MM/yyyy à HH:mm').format(date)}',
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: reservationData['statut'] == 'retirée'
                              ? Colors.blue.withOpacity(0.1)
                              : const Color(0xFF27AE60).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          reservationData['statut'] ?? 'en attente',
                          style: TextStyle(
                            color: reservationData['statut'] == 'retirée'
                                ? Colors.blue
                                : const Color(0xFF27AE60),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
