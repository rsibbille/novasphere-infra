# NovaSphere Infrastructure

Projet Terraform Bac+5 déployant une infrastructure AWS en deux environnements : DEV et PROD.

## Architecture

Chaque environnement contient :

- un VPC `10.0.0.0/16`
- deux subnets publics sur `us-east-1a` et `us-east-1b`
- un Application Load Balancer
- un Launch Template EC2 Debian 12
- un Auto Scaling Group de 2 à 4 instances
- nginx configuré automatiquement au démarrage
- un secret applicatif stocké dans AWS Systems Manager Parameter Store

DEV et PROD utilisent le même code mais possèdent des states Terraform séparés :

- DEV : `novasphere/dev/terraform.tfstate`
- PROD : `novasphere/prod/terraform.tfstate`

Le backend utilise S3 avec versioning et verrouillage natif `use_lockfile = true`.

## Prérequis

- Terraform >= 1.14
- AWS CLI v2
- Git
- accès AWS Academy Learner Lab
- credentials AWS valides
- région AWS : `us-east-1`

## Backend

Bucket utilisé :

    novasphere-tfstate-rsi-2026

Les backends sont déclarés dans :

    envs/dev/backend.tf
    envs/prod/backend.tf

## Déploiement DEV

Définir les variables :

    export TF_VAR_owner="rsi"
    export TF_VAR_environment="dev"
    export TF_VAR_aws_region="us-east-1"
    export TF_VAR_instance_type="t3.micro"
    export TF_VAR_db_password="$(openssl rand -base64 32)"

Puis :

    terraform -chdir=envs/dev init
    terraform -chdir=envs/dev validate
    terraform -chdir=envs/dev plan
    terraform -chdir=envs/dev apply

Tester l'ALB :

    curl "http://$(terraform -chdir=envs/dev output -raw alb_dns_name)"

## Déploiement PROD

Définir les variables :

    export TF_VAR_owner="rsi"
    export TF_VAR_environment="prod"
    export TF_VAR_aws_region="us-east-1"
    export TF_VAR_instance_type="t3.small"
    export TF_VAR_db_password="$(openssl rand -base64 32)"

Puis :

    terraform -chdir=envs/prod init
    terraform -chdir=envs/prod validate
    terraform -chdir=envs/prod plan
    terraform -chdir=envs/prod apply

Tester l'ALB :

    curl "http://$(terraform -chdir=envs/prod output -raw alb_dns_name)"

## Gestion des secrets

Le mot de passe applicatif est stocké dans Parameter Store :

- `/novasphere/dev/db_password`
- `/novasphere/prod/db_password`

La variable Terraform `db_password` est déclarée `ephemeral`.

La ressource SSM utilise `value_wo`, ce qui évite de conserver la valeur du secret dans le state Terraform.

Les instances récupèrent le secret au démarrage avec `aws ssm get-parameter --with-decryption`.

Aucun secret n'est présent en clair dans le bootstrap ou dans le dépôt Git.

## CI/CD

Le workflow `.github/workflows/terraform-pr.yml` s'exécute sur les Pull Requests :

- terraform fmt
- terraform init
- terraform validate
- terraform plan
- publication du plan en commentaire de la PR

Le workflow `.github/workflows/terraform-apply.yml` s'exécute après merge sur `main` :

- déploiement automatique de DEV
- déploiement de PROD via l'environnement GitHub `prod`
- détection programmée ou manuelle de dérive

## Authentification AWS dans GitHub Actions

La solution cible du cours utilise GitHub OIDC.

AWS Academy Learner Lab interdit cependant la création du rôle IAM nécessaire avec `iam:CreateRole`.

La CI utilise donc temporairement les credentials de session AWS Academy stockés dans GitHub Actions Secrets :

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`

Dans un environnement AWS standard, ces credentials seraient remplacés par un rôle IAM assumé avec GitHub OIDC.

## Sécurité

Principales mesures :

- IMDSv2 obligatoire
- EC2 accessibles en HTTP uniquement depuis le Security Group de l'ALB
- aucun state Terraform dans Git
- aucun fichier `.tfvars` versionné
- Parameter Store SecureString
- analyse Checkov
- secrets exclus du code et du state

Voir également :

- `ARCHITECTURE.md`
- `SECURITE.md`
- `CONTRIBUTING.md`

## Destruction

DEV :

    terraform -chdir=envs/dev destroy

PROD :

    terraform -chdir=envs/prod destroy

Les variables Terraform nécessaires doivent être définies avant la destruction.
