# AGENTS.md

## Repo purpose
This repo is a curated copy of the user's home-directory dotfiles. Treat changes here as edits to live personal tooling and environment config, not generic application code.

## Key areas
- **Emacs:** `config.org` is the main config; `init.el` bootstraps it; `early-init.el` is only for early startup concerns.
- **Shell:** `.bashrc`, `.bash_profile`
- **Git:** `.gitconfig`, `.gitignore_global`
- **ECA:** `.config/eca/`
- **Terminal/session:** `.tmux.conf`
- **R:** `.Rprofile`, `rPackages.csv`
- **X/desktop:** `.xinitrc`, `.Xresources`, `.Xmodmap`, `.config/i3/`, `.config/openbox/`, `xorg.conf.d/`

## Editing guidance
- Make the smallest safe change; preserve existing style, comments, ordering, and user conventions.
- Assume these files are used directly from `$HOME`; avoid renames or restructuring unless explicitly requested.
- Prefer `config.org` for normal Emacs behavior changes; use `init.el`/`early-init.el` only for bootstrap or startup-order issues.
- Be careful with host-specific conditionals, absolute paths, and any credentials/tokens.
- Some backup-like files are intentionally tracked; do not delete them unless asked.
- Do not mass-format, modernize, or clean unrelated sections.

## Validation
- For Emacs changes, use `emacsclient`; at minimum run `check-parens`, and byte-compile edited `.el` files when appropriate.
- For shell changes, run `bash -n` on edited shell files.
- For `.gitconfig`, validate with `git config -f .gitconfig --list >/dev/null`.
- For `.tmux.conf`, validate with `tmux -f .tmux.conf start-server` if syntax changed.
