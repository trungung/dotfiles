# Dotfiles

Personal macOS development environment. This repo is organized for GNU Stow: each top-level package mirrors paths relative to `$HOME`.

## Fresh Install

```sh
xcode-select --install
git clone https://github.com/trungung/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The install script runs:

```sh
install Homebrew if missing
brew bundle --file Brewfile
stow --restow --target="$HOME" zsh git nvim ghostty lazygit starship opencode
```

## Manual Step

Install Bitwarden from the App Store so the biometric extension works correctly.

Optionally review and run macOS UI/defaults tweaks:

```sh
./scripts/macos.sh
```

This is not run automatically because macOS preferences are personal and can change across OS versions.

## Secrets And Local Config

Do not commit secrets to this repo.

Use local-only files for machine-specific settings:

```text
~/.zshrc.private
~/.config/git/work.gitconfig
```

Start from:

```sh
cp ~/.zshrc.private.example ~/.zshrc.private
cp ~/.config/git/work.gitconfig.example ~/.config/git/work.gitconfig
```

## Git Identity

Shared Git behavior lives in `git/.gitconfig`.

Identities are path-specific:

```text
~/Code/trungung/ -> ~/.config/git/personal.gitconfig
~/Code/work/     -> ~/.config/git/work.gitconfig
~/go/            -> ~/.config/git/personal.gitconfig
```

Set `~/.config/git/work.gitconfig` after corporate enrollment.

## Packages

- `zsh`: shell, plugins, private config example
- `git`: Git, global ignore, personal/work identity split
- `nvim`: Neovim config
- `ghostty`: terminal config
- `lazygit`: lazygit config
- `starship`: Gruvbox shell prompt
- `opencode`: opencode config

## New Machine Sanity Check

After `./install.sh`, expect to spend some time logging in and reconnecting services. The dotfiles restore configuration, not account state.

Things to do manually:

- Install Bitwarden from the App Store, log in, and enable the SSH agent/biometric extension if needed.
- Create `~/.zshrc.private` from `~/.zshrc.private.example` and add machine-specific values.
- Create `~/.config/git/work.gitconfig` from the example and set the corporate Git identity.
- Log in to GitHub/GitHub CLI, VS Code, Claude/Codex/OpenCode/Copilot, Microsoft apps, Slack, Obsidian sync, and any browser profiles.
- Re-auth cloud CLIs as needed: Azure, AWS, Kubernetes, Terraform, Docker/OrbStack.
- Confirm SSH works for GitHub and work Git remotes.
- Open Ghostty and check the font/theme, prompt, shell plugins, and `nvim`.
- Clone only the repos you actually need; do not blindly restore old worktrees.

Useful checks:

```sh
git config --show-origin user.email
gh auth status
ssh -T git@github.com
brew bundle check --file ~/dotfiles/Brewfile
```
