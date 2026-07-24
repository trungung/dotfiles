# Dotfiles

An elegant, minimal setup for my macOS development environment. This repository is organized using **GNU Stow**; each top-level directory directly mirrors paths relative to `$HOME`.

---

## 🚀 Fresh Machine Setup

### 1. Prerequisite
Install Apple Command Line Tools:
```sh
xcode-select --install
```

### 2. Clone the Repository
```sh
git clone https://github.com/trungung/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. Run the Installer
```sh
./install.sh
```
This automatically installs Homebrew (if missing), bundles all apps/CLI packages from `Brewfile`, configures directory structures, and links your dotfiles to `$HOME` via `stow`.

*(Pi configuration in `pi/.pi/agent/` is stowed; see [Pi Configuration](#pi-configuration) below.)*

### 4. Create Local-Only Configs
Create your local environment files and customize them (do not commit these):
```sh
cp ~/.zshrc.private.example ~/.zshrc.private
cp ~/.config/git/work.gitconfig.example ~/.config/git/work.gitconfig
```
*Note: Your personal Git details are already defined globally in `git/.gitconfig`—you only need to fill in `work.gitconfig` for work machines.*

### 5. Sign In & Manual Application Setup
*   **Bitwarden**: Install from App Store, log in, and enable SSH agent / biometric extensions.
*   **CLIs & Services**: Log in to GitHub CLI (`gh auth login`), Pi, VS Code, Claude, Codex, OpenCode, and Copilot.
*   **Pi Packages**: Already tracked in `pi/.pi/agent/settings.json`; reinstall local packages if needed (`pi install npm:pi-web-access`).
*   **System Apps**: Configure AltTab, Raycast shortcuts, and browser profiles.
*   **Cloud Providers**: Re-authenticate credentials for Azure, AWS, Docker/OrbStack, or Kubernetes.

### 6. Apply macOS Defaults (Optional)
Review and run the macOS quality-of-life defaults script:
```sh
./scripts/macos.sh
```

---

## 📂 Expected Local-Only Files
The following files are expected to exist only on the local machine and are ignored by Git:
*   `~/.zshrc.private` — Shell variables, API tokens, and machine-specific pathways.
*   `~/.config/git/work.gitconfig` — Work email and signing keys for enterprise commits.

---

## 🤖 Pi Configuration

Pi settings (`~/.pi/agent/`) are now managed via stow from `pi/.pi/agent/`. The following files are tracked in git:

| File | Purpose |
|------|---------|
| `settings.json` | Theme, models, packages, compaction settings |
| `themes/gruvbox.json` | Custom Gruvbox theme |
| `prompts/*.md` | Custom `/` slash-commands (debug, explain, implement, plan, etc.) |

The following are **local-only** and excluded by `pi/.pi/agent/.gitignore`:

| File | Reason |
|------|--------|
| `auth.json` | Provider API keys and authentication tokens |
| `trust.json` | Project trust decisions (machine-specific) |
| `sessions/` | Session history (machine-specific, potentially large) |
| `npm/` | Locally installed pi npm packages with dependencies |

On first install, `install.sh` automatically backs up your existing local-only files, sets up the stow symlinks, and restores them. After that, changes via `/settings` or theme edits land directly in the tracked dotfiles.

## 🔍 Sanity Checklist
Once setup is complete, verify everything is working as expected:

```sh
git config --show-origin user.email
gh auth status
ssh -T git@github.com
brew bundle check --file ~/dotfiles/Brewfile
pi --version
pi list
```

Then, open **Ghostty** and ensure:
*   [ ] Font size and theme (Gruvbox) are rendering correctly.
*   [ ] Shell autocomplete menu works dynamically as you type.
*   [ ] `nvim` loads instantly with LSP/formatting.
