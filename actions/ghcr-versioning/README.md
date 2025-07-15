# GHCR Versioning Action

![GitHub Action](https://img.shields.io/badge/action-GitHub-blue)
![Versioning](https://img.shields.io/badge/version-semantic--versioning-orange)

GitHub Action for advanced semantic versioning with staging/production branch support and automatic GHCR publishing.

## Features

- 🚀 Automatic version generation (SemVer)
- 🌿 Staging/production workflow support
- 🏷️ Docker tag generation for GHCR
- 🔍 MAJOR/MINOR bump detection via commit messages
- 🛠️ Fully configurable

## Basic Usage

```yaml
- uses: klheb/actions/actions/ghcr-versioning@main
  with:
    current_branch: ${{ github.ref_name }}
    commit_message: ${{ github.event.head_commit.message }}
```

## Complete Configuration

```yaml
- uses: klheb/actions/actions/ghcr-versioning@main
  id: versioning
  with:
    current_branch: ${{ github.ref_name }}
    commit_message: ${{ github.event.head_commit.message }}
    prod_branch: 'main'                   # Optional
    staging_branch: 'staging'             # Optional
    prod_prefix: 'v'                      # Optional
    staging_prefix: 'staging-v'           # Optional
    major_trigger: '[MAJOR]'              # Optional
    minor_trigger: '[MINOR]'              # Optional
    rc_suffix: '-rc.'                     # Optional
    fallback_version: '0.0.0'             # Optional
    docker_repository: ${{ github.repository }} # Optional
```

## Outputs

| Name | Description | Example |
|------|-------------|---------|
| `new_version` | New version tag | `v1.2.3` or `staging-v1.2.3-rc.0` |
| `image_tag` | Complete Docker tag | `ghcr.io/org/repo:v1.2.3` |
| `additional_tag` | Additional tag | `latest` or `staging-latest` |

## Use Cases

### 1. Staging Versioning

On staging branch with commit message `[MINOR] New feature`:

```bash
staging-v0.1.0-rc.0
ghcr.io/org/repo:staging-v0.1.0-rc.0
ghcr.io/org/repo:staging-latest
```

### 2. Production Versioning

On main branch with last staging tag `staging-v1.2.3-rc.2`:

```bash
v1.2.3
ghcr.io/org/repo:v1.2.3
ghcr.io/org/repo:latest
```

### 3. Major Bump

Commit message `[MAJOR] Breaking change` on staging:

```bash
staging-v2.0.0-rc.0
```

### 4. Patch Bump

Standard commit on staging with prod version `v1.2.3`:

```bash
staging-v1.2.4-rc.0
```

## Advanced Configuration

### Custom Triggers

```yaml
with:
  major_trigger: '[BREAKING]'
  minor_trigger: '[FEAT]'
```

### Custom Prefixes

```yaml
with:
  prod_prefix: 'release-'
  staging_prefix: 'dev-'
```

## Complete Workflow Example

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

## Requirements

- Write access to Git tags
- `fetch-depth: 0` to access full tag history
