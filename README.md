# GitHub Custom Actions Repository

![Actions Status](https://img.shields.io/badge/status-active-success)
![License](https://img.shields.io/badge/license-MIT-blue)

Mon référentiel central d'actions GitHub personnalisées, réutilisables dans tous mes projets.

## 📦 Liste des Actions Disponibles

| Action | Description | Lien |
|--------|-------------|------|
| `ghcr-versioning` | Versioning sémantique automatique | [README](./actions/ghcr-versioning/README.md) |
| *(D'autres à venir...)* | | |

## 🚀 Utilisation

Toutes les actions sont accessibles via :

```yaml
uses: klheb/actions/actions/<NOM_ACTION>@main
```

### Exemple Basique

```yaml
steps:
  - uses: klheb/actions/actions/ghcr-versioning@main
    with:
      current_branch: ${{ github.ref_name }}
```

## 🏗 Structure du Repository

```bash
actions/
  <nom-action>/          # Dossier par action
    action.yml           # Définition de l'action
    README.md            # Documentation spécifique
    tests/               # Tests automatisés (optionnel)
```

## 📚 Documentation par Action

Chaque action possède sa propre documentation détaillant :

- 📌 Son objectif
- ⚙️ Ses paramètres d'entrée
- 📤 Ses sorties
- 🛠 Exemples d'utilisation
- 🔧 Cas particuliers

Consultez le README dans chaque sous-dossier d'action.
