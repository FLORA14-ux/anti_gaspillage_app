import 'dart:io';
import 'dart:convert'; // Nécessaire pour l'encodage Base64
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:anti_gaspillage_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddInvenduScreen extends StatefulWidget {
  const AddInvenduScreen({Key? key}) : super(key: key);

  @override
  State<AddInvenduScreen> createState() => _AddInvenduScreenState();
}

class _AddInvenduScreenState extends State<AddInvenduScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixNormalController = TextEditingController();
  final _prixReduitController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _localisationController = TextEditingController();

  XFile? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final returnedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 600, // Réduit la largeur pour tenir dans Firestore
      imageQuality: 50, // Réduit la qualité pour réduire la taille du texte
    );

    if (returnedImage == null) return;

    setState(() {
      _selectedImage = returnedImage;
    });
  }

  Future<void> _publishInvendu() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une image.')),
        );
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Handle case where user is not logged in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous devez être connecté pour publier un invendu.'),
          ),
        );
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        print("--- DÉBUT PUBLICATION ---");

        // 1. Conversion de l'image en Base64 (Texte)
        print("Conversion de l'image en texte...");
        final bytes = await _selectedImage!.readAsBytes();
        final String base64Image = base64Encode(bytes);
        print("Conversion terminée.");

        // 2. Enregistrement dans Firestore
        print("Enregistrement Firestore en cours...");
        final firestoreService = FirestoreService();
        await firestoreService.addInvendu(
          titre: _titreController.text,
          description: _descriptionController.text,
          prixNormal: double.parse(_prixNormalController.text),
          prixReduit: double.parse(_prixReduitController.text),
          imageUrl:
              base64Image, // On envoie le code de l'image au lieu de l'URL
          quantite: int.parse(_quantiteController.text),
          localisation: _localisationController.text,
        );
        print("--- SUCCÈS ---");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invendu publié avec succès!')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        print("!!! ERREUR CRITIQUE : $e");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la publication: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _prixNormalController.dispose();
    _prixReduitController.dispose();
    _quantiteController.dispose();
    _localisationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publier un Invendu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Widget de sélection d'image
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: kIsWeb
                              ? Image.network(
                                  _selectedImage!.path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.add_a_photo,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text('Appuyer pour ajouter une image'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _prixNormalController,
                decoration: const InputDecoration(labelText: 'Prix Normal (€)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requis';
                  if (double.tryParse(value) == null) return 'Invalide';
                  return null;
                },
              ),
              TextFormField(
                controller: _prixReduitController,
                decoration: const InputDecoration(labelText: 'Prix Réduit (€)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requis';
                  final prix = double.tryParse(value);
                  if (prix == null) return 'Invalide';
                  // Validation optionnelle : le prix réduit doit être inférieur au normal
                  final normal = double.tryParse(_prixNormalController.text);
                  if (normal != null && prix >= normal) {
                    return 'Doit être inférieur au prix normal';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _quantiteController,
                decoration: const InputDecoration(labelText: 'Quantité'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une quantité';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre entier valide';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _localisationController,
                decoration: const InputDecoration(labelText: 'Localisation'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une localisation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isUploading ? null : _publishInvendu,
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Publier l\'Invendu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
