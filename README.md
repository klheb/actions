# GitHub Custom Actions Repository

![Actions Status](https://img.shields.io/badge/status-active-success)
![License](https://img.shields.io/badge/license-MIT-blue)

My central repository of custom GitHub Actions, reusable across all my projects.

## 📦 Available Actions

| Action | Description | Link |
|--------|-------------|------|
| `ghcr-versioning` | Automatic semantic versioning | [README](./actions/ghcr-versioning/README.md) |
| *(More coming soon...)* | | |

## 🚀 Usage

All actions are accessible via:

```yaml
uses: klheb/actions/actions/<ACTION_NAME>@main
```

### Basic Example

```yaml
steps:
  - uses: klheb/actions/actions/ghcr-versioning@main
    with:
      current_branch: ${{ github.ref_name }}
```

## 🏗 Repository Structure

```bash
actions/
  <action-name>/       # Per-action directory
    action.yml        # Action definition
    README.md         # Specific documentation
    tests/            # Automated tests (optional)
```

## 📚 Per-Action Documentation

Each action has its own documentation detailing:

- 📌 Purpose
- ⚙️ Input parameters
- 📤 Outputs
- 🛠 Usage examples
- 🔧 Edge cases

Consult the README in each action subdirectory.
