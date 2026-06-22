# Dotfiles

Memo for bootstrapping my macOS development environment. This repo is organized for GNU Stow: each top-level directory mirrors paths relative to `$HOME`.

## Fresh Machine Order

1. Install Apple command line tools.

   ```sh
   xcode-select --install
   ```

2. Clone this repo.

   ```sh
   git clone https://github.com/trungung/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

3. Run the installer.

   ```sh
   ./install.sh
   ```

   This installs Homebrew if needed, runs `brew bundle --file Brewfile`, prepares local config directories, and stows the dotfiles into `$HOME`.

   Pi config is intentionally not stowed; keep `~/.pi/agent` local to each machine.

4. Create local-only config.

   ```sh
   cp ~/.zshrc.private.example ~/.zshrc.private
   cp ~/.config/git/work.gitconfig.example ~/.config/git/work.gitconfig
   ```

   Edit these with machine/work-specific values. Do not commit the real files.

5. Sign in and finish app setup.

   - Install Bitwarden from the App Store, then log in and enable the SSH agent/biometric extension if needed.
   - Log in to GitHub/GitHub CLI, pi, VS Code, Claude/Codex/OpenCode/Copilot, Microsoft apps, Slack, Obsidian sync, and browser profiles.
   - Reinstall any local pi packages you want on that machine, for example `pi install npm:pi-web-access`.
   - Configure AltTab and Raycast shortcuts.
   - Re-auth cloud/dev CLIs as needed: Azure, AWS, Kubernetes, Terraform, Docker/OrbStack.
   - Clone only the repos currently needed.

6. Optionally apply macOS defaults after reviewing them.

   ```sh
   ./scripts/macos.sh
   ```

## Notes

- Stow links files from this repo into `$HOME`; it does not copy secrets into the repo by itself.
- If Stow reports an existing-file conflict, inspect the local file and move it aside before rerunning `./install.sh`.
- Keep secrets and machine-specific state local. Expected local-only files include:

  ```text
  ~/.zshrc.private
  ~/.config/git/work.gitconfig
  ~/.pi/agent/
  ```

## Sanity Checklist

```sh
git config --show-origin user.email
gh auth status
ssh -T git@github.com
brew bundle check --file ~/dotfiles/Brewfile
pi --version
pi list
```

Then open Ghostty and check the shell prompt, font/theme, shell plugins, `nvim`, and local pi setup.
