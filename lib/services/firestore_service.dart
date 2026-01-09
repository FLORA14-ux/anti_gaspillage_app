import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Créer un nouvel invendu
  Future<void> addInvendu({
    required String titre,
    required String description,
    required double prix,
    required int quantite,
    required String localisation, // Added localisation
  }) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('Aucun utilisateur connecté.');
      throw Exception('User not logged in'); // Throw an exception to be handled by UI
    }

    try {
      await _db.collection('invendus').add({
        'titre': titre,
        'description': description,
        'prix': prix,
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
  Future<void> reserveInvendu(String invenduId) async {
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

      final currentStatut = invenduSnapshot.get('statut');
      if (currentStatut != 'disponible') {
        throw Exception('Invendu already reserved or not available');
      }

      // 1. Create a reservation
      transaction.set(
        _db.collection('reservations').doc(),
        {
          'invenduId': invenduId,
          'consommateurId': currentUser.uid,
          'statut': 'en_attente',
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      // 2. Update the invendu status
      transaction.update(invenduRef, {'statut': 'réservé'});
    });
  }

  // Récupérer tous les invendus (pour le flux consommateur)
  Stream<QuerySnapshot> getInvendus() {
    return _db.collection('invendus').where('statut', isEqualTo: 'disponible').orderBy('createdAt', descending: true).snapshots();
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
}
