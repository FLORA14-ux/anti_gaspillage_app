import 'dart:convert';
import 'package:anti_gaspillage_app/models/invendu.dart';
import 'package:anti_gaspillage_app/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MerchantInvenduDetailScreen extends StatefulWidget {
  final Invendu invendu;

  const MerchantInvenduDetailScreen({Key? key, required this.invendu})
    : super(key: key);

  @override
  State<MerchantInvenduDetailScreen> createState() =>
      _MerchantInvenduDetailScreenState();
}

class _MerchantInvenduDetailScreenState
    extends State<MerchantInvenduDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _deleteInvendu(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer cet invendu ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _firestoreService.deleteInvendu(widget.invendu.id);
      if (mounted) Navigator.pop(context);
    }
  }

  void _editInvendu(BuildContext context) {
    final prixController = TextEditingController(
      text: widget.invendu.prixReduit.toString(),
    );
    final quantiteController = TextEditingController(
      text: widget.invendu.quantite.toString(),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier l\'offre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: prixController,
              decoration: const InputDecoration(
                labelText: 'Nouveau prix réduit (€)',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: quantiteController,
              decoration: const InputDecoration(labelText: 'Nouvelle quantité'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestoreService.updateInvendu(widget.invendu.id, {
                'prixReduit':
                    double.tryParse(prixController.text) ??
                    widget.invendu.prixReduit,
                'quantite':
                    int.tryParse(quantiteController.text) ??
                    widget.invendu.quantite,
              });
              if (mounted) {
                Navigator.pop(ctx);
                Navigator.pop(
                  context,
                ); // Retour à la liste pour voir les changements
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invendu = widget.invendu;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('', style: TextStyle(color: Color(0xFF333333))),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _editInvendu(context);
              if (value == 'delete') _deleteInvendu(context);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Modifier prix/quantité'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Supprimer l\'offre',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: Color(0xFF333333)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            if (invendu.imageUrl.isNotEmpty)
              Container(
                height: 300,
                width: double.infinity,
                color: const Color(0xFFF5F5F5),
                child: Builder(
                  builder: (context) {
                    try {
                      if (invendu.imageUrl.startsWith('http')) {
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
                      return const Center(
                        child: Icon(Icons.broken_image, size: 60),
                      );
                    }
                  },
                ),
              ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    invendu.titre,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Status badge
                  if (invendu.statut == 'disponible')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF27AE60),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Color(0xFF27AE60),
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Disponible',
                            style: TextStyle(
                              color: Color(0xFF27AE60),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            invendu.statut[0].toUpperCase() +
                                invendu.statut.substring(1),
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    invendu.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info cards
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9F8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Column(
                      children: [
                        // Quantity and price
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF27AE60).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                color: Color(0xFF27AE60),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Quantité disponible',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${invendu.quantite}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        // Location
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF27AE60).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFF27AE60),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Localisation',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    invendu.localisation,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        // Prices
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF27AE60).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.local_offer_outlined,
                                color: Color(0xFF27AE60),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${invendu.prixNormal.toStringAsFixed(2)} €',
                                        style: const TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF27AE60),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          '${invendu.prixReduit.toStringAsFixed(2)} €',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Reservations section
                  const Text(
                    'Réservations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reservations list
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestoreService.getReservationsForInvendu(
                      invendu.id,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF27AE60),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        print(
                          "Erreur Firestore (Réservations): ${snapshot.error}",
                        );
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 48,
                              ),
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
                                size: 48,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Aucune réservation pour le moment.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;
                          final date =
                              (data['createdAt'] as Timestamp?)?.toDate() ??
                              DateTime.now();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9F8),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF27AE60,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.person_outline,
                                      color: Color(0xFF27AE60),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Quantité : ${data['quantite'] ?? 1}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFF333333),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Réservé le ${DateFormat('dd/MM/yyyy HH:mm').format(date)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: data['statut'] == 'confirmée'
                                          ? const Color(
                                              0xFF27AE60,
                                            ).withOpacity(0.2)
                                          : Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      data['statut'] ?? 'en attente',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: data['statut'] == 'confirmée'
                                            ? const Color(0xFF27AE60)
                                            : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
