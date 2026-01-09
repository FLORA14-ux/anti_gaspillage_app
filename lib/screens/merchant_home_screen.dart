import 'package:anti_gaspillage_app/models/invendu.dart';
import 'package:anti_gaspillage_app/screens/add_invendu_screen.dart'; // Import AddInvenduScreen
import 'package:anti_gaspillage_app/screens/merchant_invendu_detail_screen.dart'; // Import MerchantInvenduDetailScreen
import 'package:anti_gaspillage_app/services/auth_service.dart'; // For logout
import 'package:anti_gaspillage_app/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MerchantHomeScreen extends StatelessWidget {
  const MerchantHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Invendus (Commerçant)'),
        actions: [
          IconButton(
            onPressed: () {
              AuthService().signOut();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getInvendusForMerchant(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Une erreur est survenue: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Vous n\'avez pas encore publié d\'invendus.'),
            );
          }

          final invendus = snapshot.data!.docs.map((doc) {
            return Invendu.fromFirestore(doc);
          }).toList();

          return ListView.builder(
            itemCount: invendus.length,
            itemBuilder: (context, index) {
              final invendu = invendus[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MerchantInvenduDetailScreen(invendu: invendu),
                      ),
                    );
                  },
                  title: Text(
                    invendu.titre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${invendu.description}\nQuantité: ${invendu.quantite}\nStatut: ${invendu.statut}',
                  ),
                  trailing: Text(
                    '${invendu.prix.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddInvenduScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
