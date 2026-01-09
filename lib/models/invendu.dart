import 'package:cloud_firestore/cloud_firestore.dart';

class Invendu {
  final String id;
  final String titre;
  final String description;
  final double prixNormal;
  final double prixReduit;
  final String imageUrl;
  final int quantite;
  final String commercantId;
  final String statut;
  final Timestamp createdAt;
  final String localisation;

  Invendu({
    required this.id,
    required this.titre,
    required this.description,
    required this.prixNormal,
    required this.prixReduit,
    required this.imageUrl,
    required this.quantite,
    required this.commercantId,
    required this.statut,
    required this.createdAt,
    required this.localisation,
  });

  // Factory pour créer un Invendu depuis un DocumentSnapshot
  factory Invendu.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Invendu(
      id: doc.id,
      titre: data['titre'] ?? '',
      description: data['description'] ?? '',
      prixNormal: (data['prixNormal'] ?? 0).toDouble(),
      prixReduit: (data['prixReduit'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      quantite: data['quantite'] ?? 0,
      commercantId: data['commercantId'] ?? '',
      statut: data['statut'] ?? 'disponible',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      localisation: data['localisation'] ?? '',
    );
  }

  // Méthode pour convertir un Invendu en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'titre': titre,
      'description': description,
      'prixNormal': prixNormal,
      'prixReduit': prixReduit,
      'imageUrl': imageUrl,
      'quantite': quantite,
      'commercantId': commercantId,
      'statut': statut,
      'createdAt': createdAt,
      'localisation': localisation,
    };
  }
}
