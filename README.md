# anti_gaspillage_app

Une application mobile Flutter permettant de lutter contre le gaspillage alimentaire en mettant en relation des commerçants (boulangeries, restaurants, etc.) et des consommateurs.

## 🚀 Fonctionnalités

*   **Authentification** : Inscription et connexion par Email/Mot de passe (Rôles : Commerçant ou Consommateur).
*   **Commerçant** :
    *   Publication d'offres (Invendus) avec photo, prix normal/réduit et quantité.
    *   Gestion des stocks en temps réel.
    *   Suivi des réservations par produit.
    *   Validation du retrait des commandes.
    *   Modification et suppression des offres.
*   **Consommateur** :
    *   Consultation des offres disponibles (filtrage automatique des stocks épuisés).
    *   Réservation de paniers avec choix de la quantité.
    *   Historique des réservations ("Mes Réservations").
*   **Technique** :
    *   Images stockées en Base64 (directement dans Firestore) pour simplifier la configuration.
    *   Transactions Firestore pour garantir l'intégrité des stocks lors des réservations simultanées.

## 🛠 Prérequis

Avant de commencer, assurez-vous d'avoir installé :
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.10.0 ou supérieure)
*   [Git](https://git-scm.com/)
*   Un éditeur de code (VS Code ou Android Studio)

## ⚙️ Installation et Configuration

### 1. Cloner le projet
```bash
git clone https://github.com/VOTRE_NOM_UTILISATEUR/anti_gaspillage_app.git
cd anti_gaspillage_app
```

### 2. Installer les dépendances
```bash
flutter pub get
```

## 📱 Lancer l'application

**Sur Android / iOS :**
Connectez votre appareil ou lancez un émulateur.
```bash
flutter run
```

**Sur le Web (Chrome) :**
```bash
flutter run -d chrome
```
*Note : Sur le web, les images sont gérées, mais assurez-vous que votre projet Firebase supporte le web.*

## 📂 Structure du projet

```
lib/
├── models/            # Modèles de données (Invendu, Reservation)
├── screens/           # Écrans de l'application (UI)
│   ├── auth.dart                  # Connexion/Inscription
│   ├── home.dart                  # Accueil Consommateur
│   ├── merchant_home_screen.dart  # Accueil Commerçant
│   ├── add_invendu_screen.dart    # Formulaire d'ajout
│   ├── invendu_detail_screen.dart # Détail & Réservation
│   └── ...
├── services/          # Logique métier (Firebase Auth & Firestore)
└── main.dart          # Point d'entrée et routage
```

