# GHCR Versioning Action

![GitHub Action](https://img.shields.io/badge/action-GitHub-blue)
![Versioning](https://img.shields.io/badge/version-semantic--versioning-orange)

Action GitHub pour un versioning sémantique avancé avec support des branches staging/production et publication automatique sur GHCR.

## Fonctionnalités

- 🚀 Génération automatique de versions (SemVer)
- 🌿 Support des workflows staging/production
- 🏷️ Génération de tags Docker pour GHCR
- 🔍 Détection des bumps MAJOR/MINOR via messages de commit
- 🛠️ Entièrement configurable

## Utilisation Basique

```yaml
- uses: klheb/actions/actions/ghcr-versioning@main
  with:
    current_branch: ${{ github.ref_name }}
    commit_message: ${{ github.event.head_commit.message }}
```

## Configuration Complète

```yaml
- uses: klheb/actions/actions/ghcr-versioning@main
  id: versioning
  with:
    current_branch: ${{ github.ref_name }}
    commit_message: ${{ github.event.head_commit.message }}
    prod_branch: 'main'                   # Optionnel
    staging_branch: 'staging'             # Optionnel
    prod_prefix: 'v'                      # Optionnel
    staging_prefix: 'staging-v'           # Optionnel
    major_trigger: '[MAJOR]'              # Optionnel
    minor_trigger: '[MINOR]'              # Optionnel
    rc_suffix: '-rc.'                     # Optionnel
    fallback_version: '0.0.0'             # Optionnel
    docker_repository: ${{ github.repository }} # Optionnel
```

## Outputs

| Nom | Description | Exemple |
|------|-------------|---------|
| `new_version` | Nouveau tag de version | `v1.2.3` ou `staging-v1.2.3-rc.0` |
| `image_tag` | Tag Docker complet | `ghcr.io/org/repo:v1.2.3` |
| `additional_tag` | Tag additionnel | `latest` ou `staging-latest` |

## Cas d'Usage

### 1. Versioning Staging

Sur la branche staging avec commit message `[MINOR] New feature` :

```bash
staging-v0.1.0-rc.0
ghcr.io/org/repo:staging-v0.1.0-rc.0
ghcr.io/org/repo:staging-latest
```

### 2. Versioning Production

Sur la branche main avec dernier tag staging `staging-v1.2.3-rc.2` :

```bash
v1.2.3
ghcr.io/org/repo:v1.2.3
ghcr.io/org/repo:latest
```

### 3. Bump Major

Commit message `[MAJOR] Breaking change` sur staging :

```bash
staging-v2.0.0-rc.0
```

### 4. Bump Patch

Commit standard sur staging avec version prod `v1.2.3` :

```bash
staging-v1.2.4-rc.0
```

## Configuration Avancée

### Triggers personnalisés

```yaml
with:
  major_trigger: '[BREAKING]'
  minor_trigger: '[FEAT]'
```

### Préfixes personnalisés

```yaml
with:
  prod_prefix: 'release-'
  staging_prefix: 'dev-'
```

## Workflow Complet Exemple

```yaml
name: Build and Version
on:
  push:
    branches: [main, staging]

jobs:
  version:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - uses: klheb/actions/actions/ghcr-versioning@main
        id: versioning
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          tags: |
            ${{ steps.versioning.outputs.image_tag }}
            ${{ steps.versioning.outputs.additional_tag }}
          push: true
```

## Dépendances

- Accès en écriture aux tags Git
- `fetch-depth: 0` pour accéder à l'historique des tags
