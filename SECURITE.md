# Registre de sécurité — NovaSphere

## Gestion des secrets

Le mot de passe applicatif est stocké dans AWS Systems Manager Parameter Store sous forme de `SecureString`.

Chemin DEV :

`/novasphere/dev/db_password`

Le secret est fourni à Terraform via la variable d'environnement `TF_VAR_db_password`.

La variable Terraform est déclarée avec `ephemeral = true` et le paramètre SSM utilise l'attribut write-only `value_wo`. La valeur du secret n'est donc pas conservée dans le state Terraform.

Vérification effectuée :

`terraform state pull | grep -F -c -- "$TF_VAR_db_password"`

Résultat obtenu : `0`.

Le projet initial ne contenait pas de mot de passe applicatif avant cette étape. Le mécanisme sécurisé a donc été mis en place directement sans reproduire volontairement une fuite de secret.

## IAM et AWS Academy

L'architecture prévue initialement utilisait un rôle IAM dédié aux instances EC2 avec uniquement l'autorisation suivante :

`ssm:GetParameter`

sur le chemin correspondant à l'environnement :

`/novasphere/dev/*`

Cependant, AWS Academy Learner Lab interdit à l'utilisateur du laboratoire l'action `iam:CreateRole`.

Terraform a retourné une erreur `AccessDenied` lors de la tentative de création du rôle.

Le projet utilise donc le profil d'instance fourni par AWS Academy :

`LabInstanceProfile`

Cette dérogation est imposée par les restrictions de l'environnement pédagogique et ne représente pas la configuration IAM recommandée pour un environnement de production.

Dans un environnement AWS standard, un rôle dédié suivant le principe du moindre privilège serait utilisé.

## Protection des métadonnées EC2

Les Launch Templates imposent IMDSv2 :

`http_tokens = "required"`

Cela empêche l'utilisation d'IMDSv1 par les instances.

## Réseau

L'Application Load Balancer est accessible publiquement en HTTP sur le port 80.

Les instances EC2 du groupe Auto Scaling n'acceptent le trafic HTTP que depuis le Security Group de l'ALB.

Les instances ne sont donc pas directement exposées en HTTP à Internet.

## Analyse statique

L'infrastructure Terraform est analysée avec Checkov.

Les alertes pertinentes sont corrigées lorsque cela est compatible avec les contraintes du projet et de l'environnement AWS Academy.

Les éventuelles exceptions conservées sont documentées avec leur justification.

## Résultat Checkov DEV

Scan Checkov effectué sur `envs/dev`.

Résultat :
- 26 checks réussis
- 11 checks en échec
- 1 check ignoré avec justification

Corrections réalisées :
- `CKV_AWS_23` : ajout des descriptions manquantes sur les Security Groups et leurs règles.
- `CKV_AWS_131` : activation de `drop_invalid_header_fields` sur l'Application Load Balancer.

Exception documentée :
- `CKV_AWS_260` : l'ALB est volontairement exposé publiquement sur HTTP/80 dans le cadre du laboratoire. Cette exception est explicitement annotée dans le code Terraform.

Les autres alertes concernent notamment HTTPS/TLS, WAF, journalisation ALB, KMS CMK et deletion protection. Elles sont identifiées mais ne sont pas implémentées dans le périmètre actuel du laboratoire.
