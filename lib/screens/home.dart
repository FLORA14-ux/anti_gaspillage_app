import 'dart:convert'; // Pour décoder l'image
import 'package:anti_gaspillage_app/screens/invendu_detail_screen.dart';
import 'package:anti_gaspillage_app/screens/my_reservations_screen.dart';
import 'package:anti_gaspillage_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invendu.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Offres Anti-Gaspillage',
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyReservationsScreen()));
              },
              icon: const Icon(Icons.history, color: Color(0xFF27AE60)),
              tooltip: 'Mes Réservations',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                AuthService().signOut();
              },
              icon: const Icon(Icons.logout, color: Color(0xFF27AE60)),
              tooltip: 'Déconnexion',
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getInvendus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF27AE60)),
            );
          }

          if (snapshot.hasError) {
            print("Erreur Firestore: ${snapshot.error}");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune offre disponible\npour le moment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final invendus = snapshot.data!.docs.map((doc) {
            return Invendu.fromFirestore(doc);
          }).toList();

          return CustomScrollView(
            slivers: [
              // Header section avec contenu
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🎯 Découvre les meilleures offres',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Des restaurants, boulangeries et commerces près de toi réduisent leurs prix pour lutter contre le gaspillage.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF27AE60).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF27AE60).withOpacity(0.3),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Color(0xFF27AE60),
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Réserver une offre te permet de la retirer en magasin dans les délais.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF27AE60),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Offres disponibles',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Grid of products
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverList.builder(
                  itemCount: invendus.length,
                  itemBuilder: (context, index) {
                    final invendu = invendus[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  InvenduDetailScreen(invendu: invendu),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image section - full width
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    height: 150,
                                    color: const Color(0xFFF5F5F5),
                                    child: Builder(
                                      builder: (context) {
                                        if (invendu.imageUrl.isEmpty) {
                                          return const Center(
                                            child: Icon(
                                              Icons.fastfood_rounded,
                                              size: 50,
                                              color: Color(0xFF27AE60),
                                            ),
                                          );
                                        }
                                        try {
                                          if (invendu.imageUrl.startsWith(
                                            'http',
                                          )) {
                                            return Image.network(
                                              invendu.imageUrl,
                                              fit: BoxFit.cover,
                                            );
                                          }
                                          return Image.memory(
                                            base64Decode(invendu.imageUrl),
                                            fit: BoxFit.cover,
                                          );
                                        } catch (e) {
                                          return const Icon(Icons.broken_image);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                // Content section
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        invendu.titre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF333333),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        invendu.description,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF666666),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Quantité: ${invendu.quantite}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF27AE60),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Text(
                                                    '${invendu.prixNormal.toStringAsFixed(2)} €',
                                                    style: const TextStyle(
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      color: Colors.grey,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF27AE60,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '${invendu.prixReduit.toStringAsFixed(2)} €',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF27AE60),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bottom padding
              SliverToBoxAdapter(child: const SizedBox(height: 20)),
            ],
          );
        },
      ),
    );
  }
}
