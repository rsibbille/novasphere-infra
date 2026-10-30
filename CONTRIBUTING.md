# Conventions de contribution

- Une branche par changement.
- Toute modification passe par une pull request.
- Une pull request doit être relue avant merge sur main.
- Aucun secret ou credential ne doit être commité.
- Ne jamais commiter *.tfstate, *.tfvars, *.pem ou .env.
- Le fichier .gitignore ne doit jamais être affaibli.
- Toujours lire terraform plan avant terraform apply.
- Ne jamais utiliser terraform force-unlock sans vérifier qu'aucune opération Terraform n'est en cours.
- Détruire ou arrêter les ressources coûteuses en fin de séance.
- Un tag Git est créé à la fin de chaque séance.
