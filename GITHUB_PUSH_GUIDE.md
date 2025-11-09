# 📤 Guide pour Pousser vers GitHub

## ✅ Étapes Complétées

1. ✅ Dépôt Git initialisé localement
2. ✅ Fichier `.gitignore` configuré (exclut les fichiers sensibles Firebase)
3. ✅ Premier commit créé avec tous les fichiers
4. ✅ Branche principale renommée en `main`

---

## 🚀 Prochaines Étapes

### 1️⃣ Créer un Nouveau Dépôt sur GitHub

Allez sur GitHub et créez un nouveau dépôt :

🔗 **https://github.com/new**

**Paramètres recommandés :**
- **Nom du dépôt** : `bookswap-flutter-app` ou `book_new`
- **Description** : "Application mobile Flutter de partage de livres avec Firebase"
- **Visibilité** : Public ou Private (votre choix)
- ⚠️ **NE PAS** cocher "Add a README file"
- ⚠️ **NE PAS** ajouter .gitignore (on l'a déjà)
- ⚠️ **NE PAS** ajouter une licence pour l'instant

Cliquez sur **"Create repository"**

---

### 2️⃣ Connecter votre Dépôt Local à GitHub

Une fois le dépôt créé, GitHub vous montrera des commandes. Utilisez celles-ci :

#### Option A : Si vous avez créé un dépôt vide (recommandé)

```powershell
# Remplacez YOUR_USERNAME par votre nom d'utilisateur GitHub
git remote add origin https://github.com/YOUR_USERNAME/bookswap-flutter-app.git

# Pousser votre code
git push -u origin main
```

#### Option B : Avec SSH (si vous avez configuré les clés SSH)

```powershell
git remote add origin git@github.com:YOUR_USERNAME/bookswap-flutter-app.git
git push -u origin main
```

---

### 3️⃣ Commandes Complètes à Exécuter

**Exemple concret (remplacez YOUR_USERNAME) :**

```powershell
# Ajouter le remote GitHub
git remote add origin https://github.com/YOUR_USERNAME/bookswap-flutter-app.git

# Vérifier que le remote est bien ajouté
git remote -v

# Pousser vers GitHub
git push -u origin main
```

**Si on vous demande de vous authentifier :**
- Username : Votre nom d'utilisateur GitHub
- Password : Utilisez un **Personal Access Token** (pas votre mot de passe)

---

### 4️⃣ Créer un Personal Access Token (si nécessaire)

Si GitHub vous demande un token :

1. Allez sur : https://github.com/settings/tokens
2. Cliquez sur **"Generate new token"** → **"Generate new token (classic)"**
3. Donnez-lui un nom : `BookSwap Flutter App`
4. Sélectionnez les scopes :
   - ✅ `repo` (tous les sous-items)
5. Cliquez sur **"Generate token"**
6. **COPIEZ LE TOKEN** (vous ne pourrez plus le revoir !)
7. Utilisez ce token comme mot de passe lors du push

---

## 📋 Commandes Git Utiles

### Vérifier l'état
```powershell
git status
git log --oneline
```

### Voir les remotes
```powershell
git remote -v
```

### Ajouter des changements futurs
```powershell
git add .
git commit -m "Description des changements"
git push
```

### Créer une nouvelle branche
```powershell
git checkout -b feature/nouvelle-fonctionnalite
```

---

## 🔒 Fichiers Exclus (Sécurité)

Ces fichiers **NE SERONT PAS** poussés vers GitHub (protégés par `.gitignore`) :

- ❌ `android/app/google-services.json` (clés Firebase Android)
- ❌ `lib/firebase_options.dart` (configuration Firebase)
- ❌ `firestore.rules` (règles de sécurité)
- ❌ `storage.rules` (règles de stockage)
- ❌ `*.ps1` (scripts PowerShell)
- ❌ Dossier `build/` (fichiers compilés)

**C'est important pour la sécurité !** 🔐

---

## 📝 Structure du Projet Poussé

```
bookswap-flutter-app/
├── lib/
│   ├── main.dart
│   ├── models/
│   ├── providers/
│   ├── screens/
│   └── services/
├── android/
├── ios/
├── web/
├── pubspec.yaml
├── README.md
└── .gitignore
```

---

## 🎯 Après le Push

Une fois poussé, vous pourrez :

1. ✅ Voir votre code sur GitHub
2. ✅ Collaborer avec d'autres développeurs
3. ✅ Utiliser GitHub Actions pour CI/CD
4. ✅ Créer des Issues et des Pull Requests
5. ✅ Documenter votre projet avec le README

---

## 🐛 Résolution de Problèmes

### Erreur : "remote origin already exists"
```powershell
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/repo-name.git
```

### Erreur : "failed to push some refs"
```powershell
# Récupérer d'abord les changements du remote
git pull origin main --rebase

# Puis pousser
git push -u origin main
```

### Erreur : Authentication failed
- Utilisez un **Personal Access Token** au lieu du mot de passe
- Ou configurez SSH keys

---

## 📚 Ressources

- [GitHub Docs - Push](https://docs.github.com/en/get-started/using-git/pushing-commits-to-a-remote-repository)
- [Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [Git Basics](https://git-scm.com/book/en/v2/Git-Basics-Working-with-Remotes)

---

## 🎉 Félicitations !

Une fois le push réussi, votre projet BookSwap Flutter sera sur GitHub ! 🚀

Votre URL sera : `https://github.com/YOUR_USERNAME/bookswap-flutter-app`
