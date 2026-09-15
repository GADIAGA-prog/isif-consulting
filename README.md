# ISIF Consulting

Site indépendant en français : accueil, expertises, formations et formulaire de contact interactif. Le site s’ouvre sans compte ChatGPT et peut être hébergé sur un serveur web standard.

## Ouvrir dans Visual Studio Code

Ouvrir `isif-consulting.code-workspace`, puis **Terminal > Nouveau terminal**.

```powershell
npm run dev
```

Ouvrir http://127.0.0.1:4173. Node.js 20 ou supérieur suffit ; aucune installation de dépendances n’est nécessaire.

## Modifier

- `site/index.html` : page d’accueil et prestations.
- `site/contact.html` : page Contact.
- `site/contact.js` : sélection du service, validation et préparation du message.
- `site/styles.css` : apparence et adaptation mobile.
- `site/hero.png`, `site/plaquette.png` : visuels.

```powershell
npm run check
```

## Hébergement

Le répertoire public est **site/** uniquement. Ne pas exposer le dépôt entier. Le code ne dépend ni de Sites, ni de Vercel, ni de ChatGPT. Les polices utilisent Google Fonts, avec une police de secours si le réseau est indisponible.

Le dossier `deploy/` contient les éléments d’installation et les informations du serveur une fois le déploiement réalisé. Les accès SSH, clés privées et mots de passe ne doivent jamais être ajoutés au dépôt.

### Publier une modification sur Windows Server / IIS

Après modification et vérification, enregistrer le code dans GitHub :

```powershell
git add .
git commit -m "Description de la modification"
git push
```

Puis publier sur un serveur déjà autorisé dans votre configuration SSH :

```powershell
powershell -NoProfile -File deploy/Publish.ps1 -Server VOTRE_ALIAS_SSH
```

Sur la machine où le projet a été installé, l’alias configuré est `parispromax-vps`.

La publication transfère uniquement `site/`, crée une version dans `C:\Sites\ISIF\releases`, puis met à jour le site IIS `ISIF-Consulting`. Les versions précédentes sont conservées. Un échec de la vérification locale du serveur rétablit le chemin précédent lorsqu’il existe. Le service IIS redémarre avec Windows ; VS Code et la machine de développement peuvent être fermés.

Le script n’arrête aucun site préexistant. Sur un serveur sans IIS, il installe le rôle web et arrête uniquement le site de démonstration créé par cette installation. Il ouvre le port HTTP 80 pour le site public. [Documentation IIS](https://learn.microsoft.com/en-us/powershell/module/webadministration/new-website).

## Formulaire

Le formulaire prépare un e-mail à `contact@isifconsulting.com` dans la messagerie du visiteur. Il **n’envoie pas directement** de message et ne stocke pas les demandes. Pour un envoi direct depuis le site, un service d’envoi ou un serveur SMTP devra être configuré séparément.

## Domaine et HTTPS

Le nom de domaine définitif doit être relié à l’adresse publique du VPS. Le certificat HTTPS se configure sur le serveur. Les adresses canoniques de l’ancien hébergement ont été retirées pour ne pas renvoyer le référencement vers ChatGPT.
