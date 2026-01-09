import 'package:cloud_firestore/cloud_firestore.dart';

class Invendu {
  final String id;
  final String titre;
  final String description;
  final double prix;
  final int quantite;
  final String commercantId;
  final String statut;
  final Timestamp createdAt;
  final String localisation;

  Invendu({
    required this.id,
    required this.titre,
    required this.description,
    required this.prix,
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
      prix: (data['prix'] ?? 0).toDouble(),
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
      'prix': prix,
      'quantite': quantite,
      'commercantId': commercantId,
      'statut': statut,
      'createdAt': createdAt,
      'localisation': localisation,
    };
  }
}
