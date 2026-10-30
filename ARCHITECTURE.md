# Décisions d'architecture — NovaSphere

## Objectif

NovaSphere fournit deux environnements AWS isolés, DEV et PROD, reproductibles avec Terraform et déployés par GitHub Actions.

## Réseau et haute disponibilité

Chaque environnement possède un VPC `10.0.0.0/16` et deux subnets publics répartis entre `us-east-1a` et `us-east-1b`.

L'application est exposée par un Application Load Balancer.

Les serveurs web appartiennent à un Auto Scaling Group utilisant un Launch Template :

- minimum : 2 instances
- désiré : 2 instances
- maximum : 4 instances

Les instances n'acceptent le trafic HTTP que depuis le Security Group de l'ALB.

Le NAT Gateway a été écarté afin de limiter les coûts du laboratoire et parce qu'il n'est pas nécessaire au périmètre demandé.

## Terraform et state

DEV et PROD partagent le code mais pas le state.

Les deux states sont stockés dans S3 :

- `novasphere/dev/terraform.tfstate`
- `novasphere/prod/terraform.tfstate`

Le bucket est versionné et utilise le verrouillage natif S3 de Terraform.

Le VPC utilise le module public `terraform-aws-modules/vpc/aws`.

Un module Terraform EC2 réutilisable a également été créé et versionné pendant les séances consacrées aux modules.

## Configuration

Les instances utilisent Debian 12.

Le bootstrap :

1. installe nginx et AWS CLI
2. récupère le secret depuis Parameter Store
3. crée la configuration applicative locale
4. démarre nginx

IMDSv2 est imposé avec `http_tokens = "required"`.

## Secrets

Le secret applicatif est stocké dans Parameter Store sous forme de SecureString.

Terraform utilise une variable `ephemeral` et `value_wo` afin que la valeur ne soit pas enregistrée dans le state.

Le stockage d'un secret dans un fichier tfvars, dans user_data ou dans Git a été écarté.

## IAM

La solution cible prévoyait un rôle IAM EC2 dédié donnant uniquement accès au chemin SSM nécessaire.

AWS Academy interdit `iam:CreateRole`.

Le projet utilise donc `LabInstanceProfile`, fourni par le Learner Lab.

Dans un environnement AWS standard, un rôle dédié suivant le principe du moindre privilège serait utilisé.

## CI/CD

Une Pull Request déclenche formatage, validation et plan Terraform avec publication du plan.

Après merge sur `main`, DEV est déployé automatiquement.

PROD utilise l'environnement GitHub protégé `prod`.

Un job de détection de dérive est également disponible.

GitHub OIDC était l'architecture cible. La création du rôle nécessaire étant interdite dans AWS Academy, les credentials temporaires de la session Learner Lab sont utilisés comme dérogation pédagogique.
