import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final String invenduId;
  final String consommateurId;
  final String statut; // en_attente / confirmé
  final Timestamp createdAt;

  Reservation({
    required this.id,
    required this.invenduId,
    required this.consommateurId,
    required this.statut,
    required this.createdAt,
  });

  factory Reservation.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Reservation(
      id: doc.id,
      invenduId: data['invenduId'] ?? '',
      consommateurId: data['consommateurId'] ?? '',
      statut: data['statut'] ?? 'en_attente',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'invenduId': invenduId,
      'consommateurId': consommateurId,
      'statut': statut,
      'createdAt': createdAt,
    };
  }
}