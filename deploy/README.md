# Hébergement ISIF Consulting

- Site public : http://198.244.148.8/isifconsulting/
- Contact : http://198.244.148.8/isifconsulting/contact.html
- Dépôt public : https://github.com/GADIAGA-prog/isif-consulting
- Serveur : VPS OVH Windows, IIS.
- Site et pool IIS : `ISIF-Consulting`.
- Version initiale active : `C:\Sites\ISIF\releases\public-20260915`.
- Sauvegarde IIS : `ISIF-before-public-20260915`.

Le 15 septembre 2026, l’accueil, le contact, JavaScript, CSS et les images ont répondu HTTP 200 depuis une machine extérieure au VPS. Aucun accès ChatGPT n’est requis.

## Mettre à jour depuis le projet local

```powershell
npm run check
git add .
git commit -m "Mise à jour du site"
git push
powershell -NoProfile -File deploy/Publish.ps1 -Server parispromax-vps
```

La publication est manuelle : pousser sur GitHub ne modifie pas automatiquement le VPS. Le script de publication transmet le dossier local `site/` par SSH et conserve les anciennes versions sur le serveur.

## Domaine et certificat

L’adresse actuelle utilise HTTP, pas HTTPS. Aucun nom de domaine personnalisé n’a encore été confirmé. Une fois le domaine choisi et son DNS relié à `198.244.148.8`, il faudra configurer le certificat, sa reconduction et la redirection HTTPS.

## Contact

Le formulaire reste un préparateur d’e-mail. Le visiteur doit envoyer le message depuis sa messagerie ; aucune réception directe côté serveur n’est configurée.

## Retour à une version précédente

Les versions se trouvent dans `C:\Sites\ISIF\releases`. Dans le gestionnaire IIS, changer le chemin physique du site `ISIF-Consulting` vers le dossier de la version choisie, puis vérifier les pages. Ne pas supprimer une version utilisée par le site.
