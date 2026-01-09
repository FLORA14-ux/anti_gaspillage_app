import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Créer un nouvel invendu
  Future<void> addInvendu({
    required String titre,
    required String description,
    required double prixNormal,
    required double prixReduit,
    required String imageUrl,
    required int quantite,
    required String localisation, // Added localisation
  }) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('Aucun utilisateur connecté.');
      throw Exception(
        'User not logged in',
      ); // Throw an exception to be handled by UI
    }

    try {
      await _db.collection('invendus').add({
        'titre': titre,
        'description': description,
        'prixNormal': prixNormal,
        'prixReduit': prixReduit,
        'imageUrl': imageUrl,
        'quantite': quantite,
        'commercantId': currentUser.uid,
        'localisation': localisation, // Added localisation
        'statut': 'disponible',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Invendu publié avec succès');
    } catch (e) {
      print('Erreur lors de la publication de l\'invendu: $e');
      rethrow; // Rethrow to be handled by UI
    }
  }

  // Réserver un invendu
  Future<void> reserveInvendu(String invenduId, int quantiteReservee) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('Aucun utilisateur connecté.');
      throw Exception('User not logged in');
    }

    // Check if the invendu is still available
    final invenduRef = _db.collection('invendus').doc(invenduId);
    return _db.runTransaction((transaction) async {
      final invenduSnapshot = await transaction.get(invenduRef);

      if (!invenduSnapshot.exists) {
        throw Exception('Invendu not found');
      }

      final data = invenduSnapshot.data() as Map<String, dynamic>;
      final currentStatut = data['statut'];
      final int currentQuantite = data['quantite'] ?? 0;

      if (currentStatut != 'disponible') {
        throw Exception('Invendu already reserved or not available');
      }

      if (currentQuantite < quantiteReservee) {
        throw Exception('Quantité insuffisante');
      }

      // 1. Create a reservation
      transaction.set(_db.collection('reservations').doc(), {
        'invenduId': invenduId,
        'consommateurId': currentUser.uid,
        'quantite': quantiteReservee,
        'statut': 'en_attente',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Update the invendu status and quantity
      int newQuantite = currentQuantite - quantiteReservee;
      if (newQuantite <= 0) {
        transaction.update(invenduRef, {'statut': 'réservé', 'quantite': 0});
      } else {
        transaction.update(invenduRef, {'quantite': newQuantite});
      }
    });
  }

  // Récupérer tous les invendus (pour le flux consommateur)
  Stream<QuerySnapshot> getInvendus() {
    return _db
        .collection('invendus')
        .where('statut', isEqualTo: 'disponible')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Récupérer les réservations pour un invendu spécifique
  Stream<QuerySnapshot> getReservationsForInvendu(String invenduId) {
    return _db
        .collection('reservations')
        .where('invenduId', isEqualTo: invenduId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Récupérer les invendus du commerçant connecté (pour son tableau de bord)
  Stream<QuerySnapshot> getInvendusForMerchant() {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }
    return _db
        .collection('invendus')
        .where('commercantId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // --- SPRINT 3 AJOUTS ---

  // Mettre à jour le statut d'une réservation (ex: "retirée")
  Future<void> updateReservationStatus(
    String reservationId,
    String newStatus,
  ) async {
    await _db.collection('reservations').doc(reservationId).update({
      'statut': newStatus,
    });
  }

  // Supprimer un invendu
  Future<void> deleteInvendu(String invenduId) async {
    await _db.collection('invendus').doc(invenduId).delete();
  }

  // Mettre à jour un invendu (Prix, Quantité, etc.)
  Future<void> updateInvendu(
    String invenduId,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('invendus').doc(invenduId).update(data);
  }

  // Récupérer les réservations du consommateur connecté
  Stream<QuerySnapshot> getReservationsForConsumer() {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return const Stream.empty();
    return _db
        .collection('reservations')
        .where('consommateurId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Helper pour récupérer un invendu spécifique (utile pour l'écran Mes Réservations)
  Future<DocumentSnapshot> getInvendu(String invenduId) {
    return _db.collection('invendus').doc(invenduId).get();
  }
}
