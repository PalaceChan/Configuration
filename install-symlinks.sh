#!/usr/bin/env bash

set -uo pipefail

usage()
{
    cat <<'EOF'
Usage: ./install-symlinks.sh [--dry-run]

Create home-directory symlinks to the managed files in this dotfiles
checkout. Existing paths are replaced only when they are byte-identical to
the tracked source or differ only by whitespace. Different files,
directories, and foreign symlinks are left untouched for manual review.

Options:
  --dry-run  Report what would change without modifying anything.
  --help     Show this help text.

For isolated testing, DOTFILES_TARGET_HOME may override the destination home
directory. Sources are always resolved relative to this script's checkout.
EOF
}

DRY_RUN=0

while (($#)); do
    case "$1" in
        --dry-run)
            DRY_RUN=1
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            printf 'Unknown option: %s\n\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
    shift
done

SCRIPT_PATH=$(readlink -f -- "${BASH_SOURCE[0]}")
DOTFILES_DIR=$(dirname -- "$SCRIPT_PATH")
TARGET_HOME=${DOTFILES_TARGET_HOME:-$HOME}

if [[ -z "$TARGET_HOME" || "$TARGET_HOME" != /* || "$TARGET_HOME" == / ]]; then
    printf 'Refusing unsafe target home: %s\n' "$TARGET_HOME" >&2
    exit 2
fi

if [[ ! -d "$TARGET_HOME" ]]; then
    printf 'Target home does not exist: %s\n' "$TARGET_HOME" >&2
    exit 2
fi

TARGET_HOME=$(readlink -f -- "$TARGET_HOME")

# Each entry is SOURCE_RELATIVE_TO_REPO|DESTINATION_RELATIVE_TO_HOME.
MAPPINGS=(
    '.Rprofile|.Rprofile'
    '.Xresources|.Xresources'
    '.bash_profile|.bash_profile'
    '.bashrc|.bashrc'
    '.config/eca/config.json|.config/eca/config.json'
    '.config/eca/commands|.config/eca/commands'
    '.config/eca/prompts|.config/eca/prompts'
    '.config/eca/rules|.config/eca/rules'
    '.config/eca/skills/elpy|.config/eca/skills/elpy'
    '.config/eca/skills/ess|.config/eca/skills/ess'
    '.config/eca/skills/gcalcli|.config/eca/skills/gcalcli'
    '.config/openbox/rc.xml|.config/openbox/rc.xml'
    '.gdbinit|.gdbinit'
    '.gitignore_global|.gitignore_global'
    '.ssh/config|.ssh/config'
    '.tmux.conf|.tmux.conf'
    '.xinitrc|.xinitrc'
    'early-init.el|.emacs.d/early-init.el'
    'init.el|.emacs.d/init.el'
    'config.org|.emacs.d/config.org'
    'dump_history.sh|history/dump_history.sh'
)

linked=0
planned=0
already=0
skipped=0
errors=0
PENDING_BACKUP=
PENDING_DESTINATION=

cleanup()
{
    local status=$?

    trap - EXIT INT TERM
    if [[ -n "$PENDING_BACKUP" && (-e "$PENDING_BACKUP" || -L "$PENDING_BACKUP") && ! -e "$PENDING_DESTINATION" && ! -L "$PENDING_DESTINATION" ]]; then
        mv -- "$PENDING_BACKUP" "$PENDING_DESTINATION" 2>/dev/null || true
    fi
    exit "$status"
}
trap cleanup EXIT INT TERM

ensure_parent()
{
    local destination=$1
    local parent

    parent=$(dirname -- "$destination")
    if [[ -d "$parent" ]]; then
        return 0
    fi
    if [[ -e "$parent" || -L "$parent" ]]; then
        printf '[error] parent is not a directory: %s\n' "$parent" >&2
        return 1
    fi

    if ((DRY_RUN)); then
        return 0
    fi

    if [[ "$parent" == "$TARGET_HOME/.ssh" ]]; then
        mkdir -m 700 -p -- "$parent"
    else
        mkdir -p -- "$parent"
    fi
}

link_missing_path()
{
    local source=$1
    local destination=$2

    if ((DRY_RUN)); then
        printf '[would-link] %s -> %s (destination missing)\n' "$destination" "$source"
        planned=$((planned + 1))
        return 0
    fi

    if ! ensure_parent "$destination"; then
        errors=$((errors + 1))
        return 1
    fi
    if ln -s -- "$source" "$destination"; then
        printf '[linked] %s -> %s (destination missing)\n' "$destination" "$source"
        linked=$((linked + 1))
        return 0
    fi

    printf '[error] could not create symlink: %s\n' "$destination" >&2
    errors=$((errors + 1))
    return 1
}

replace_with_link()
{
    local source=$1
    local destination=$2
    local reason=$3
    local backup="${destination}.dotfiles-link-backup.$$"

    if ((DRY_RUN)); then
        printf '[would-link] %s -> %s (%s)\n' "$destination" "$source" "$reason"
        planned=$((planned + 1))
        return 0
    fi

    while [[ -e "$backup" || -L "$backup" ]]; do
        backup=${backup}.next
    done

    PENDING_BACKUP=$backup
    PENDING_DESTINATION=$destination

    if ! mv -- "$destination" "$backup"; then
        printf '[error] could not stage existing path: %s\n' "$destination" >&2
        PENDING_BACKUP=
        PENDING_DESTINATION=
        errors=$((errors + 1))
        return 1
    fi

    if ! ln -s -- "$source" "$destination"; then
        printf '[error] could not create symlink, restoring: %s\n' "$destination" >&2
        mv -- "$backup" "$destination" 2>/dev/null || true
        PENDING_BACKUP=
        PENDING_DESTINATION=
        errors=$((errors + 1))
        return 1
    fi

    if ! rm -rf -- "$backup"; then
        printf '[error] symlink created but backup cleanup failed: %s\n' "$backup" >&2
        PENDING_BACKUP=
        PENDING_DESTINATION=
        errors=$((errors + 1))
        return 1
    fi

    PENDING_BACKUP=
    PENDING_DESTINATION=
    printf '[linked] %s -> %s (%s)\n' "$destination" "$source" "$reason"
    linked=$((linked + 1))
}

paths_equivalent()
{
    local source=$1
    local destination=$2

    if [[ -f "$source" && -f "$destination" ]]; then
        if cmp -s -- "$source" "$destination"; then
            EQUIVALENCE_REASON='identical file'
            return 0
        fi
        if diff -q -w -- "$source" "$destination" >/dev/null 2>&1; then
            EQUIVALENCE_REASON='whitespace-only file difference'
            return 0
        fi
        return 1
    fi

    if [[ -d "$source" && -d "$destination" ]]; then
        if diff -q -r -w -- "$source" "$destination" >/dev/null 2>&1; then
            EQUIVALENCE_REASON='equivalent directory'
            return 0
        fi
        return 1
    fi

    return 1
}

for mapping in "${MAPPINGS[@]}"; do
    source_relative=${mapping%%|*}
    destination_relative=${mapping#*|}
    source=$DOTFILES_DIR/$source_relative
    destination=$TARGET_HOME/$destination_relative

    if [[ ! -e "$source" && ! -L "$source" ]]; then
        printf '[error] source is missing: %s\n' "$source" >&2
        errors=$((errors + 1))
        continue
    fi

    if [[ -L "$destination" ]]; then
        current_target=$(readlink -- "$destination")
        if [[ "$current_target" == "$source" ]]; then
            printf '[already-linked] %s -> %s\n' "$destination" "$source"
            already=$((already + 1))
        elif [[ -e "$destination" && $(readlink -f -- "$destination") == "$source" ]]; then
            printf '[already-linked] %s -> %s\n' "$destination" "$source"
            already=$((already + 1))
        else
            printf '[skipped] foreign symlink: %s -> %s\n' "$destination" "$current_target"
            skipped=$((skipped + 1))
        fi
        continue
    fi

    if [[ ! -e "$destination" ]]; then
        link_missing_path "$source" "$destination"
        continue
    fi

    EQUIVALENCE_REASON=
    if paths_equivalent "$source" "$destination"; then
        replace_with_link "$source" "$destination" "$EQUIVALENCE_REASON"
    else
        printf '[skipped] existing path differs: %s\n' "$destination"
        skipped=$((skipped + 1))
    fi
done

printf '\nSummary: linked=%d already-linked=%d skipped=%d errors=%d' "$linked" "$already" "$skipped" "$errors"
if ((DRY_RUN)); then
    printf ' would-link=%d' "$planned"
fi
printf '\n'

if ((errors)); then
    exit 1
fi
