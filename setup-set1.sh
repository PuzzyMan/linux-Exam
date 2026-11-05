#!/usr/bin/env bash
# Worksheet set 1 (Speed Logistics): User / Group / File permissions
#
#   sudo bash setup-set1.sh           prepare the machine before item 1
#   sudo bash setup-set1.sh --reset   remove everything this worksheet creates
#
# Use on a lab VM only.

BASE=/srv/logi
LAB_USERS="somchai wipa nok pong mana logibak"
LAB_GROUPS="ofice office drivers managers"
LAB_GIDS="6999 6001 6002 6003"

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root: sudo bash $0" >&2
    exit 1
fi

reset_lab() {
    for u in $LAB_USERS; do
        if id "$u" >/dev/null 2>&1; then
            userdel -r "$u" 2>/dev/null
            echo "removed user  $u"
        fi
    done
    for g in $LAB_GROUPS; do
        if getent group "$g" >/dev/null; then
            groupdel "$g"
            echo "removed group $g"
        fi
    done
    rm -rf "$BASE"
    echo "Reset complete. Run 'sudo bash $0' to set up again."
}

setup_lab() {
    for u in $LAB_USERS; do
        if id "$u" >/dev/null 2>&1; then
            echo "User '$u' already exists. Run 'sudo bash $0 --reset' first." >&2
            exit 1
        fi
    done
    for g in $LAB_GROUPS $LAB_GIDS; do
        if getent group "$g" >/dev/null; then
            echo "Group '$g' already exists. Run 'sudo bash $0 --reset' first." >&2
            exit 1
        fi
    done

    set -e
    groupadd -g 6999 ofice
    useradd -m -s /bin/bash -c 'Somchai Dee' -G ofice somchai
    useradd -m -s /bin/bash -c 'Wipa Srisuk' wipa
    printf '%s:Logi@2026\n' somchai wipa | chpasswd
    mkdir -p "$BASE"

    echo "Setup complete."
    id somchai
    id wipa
}

case "${1:-}" in
    "")      setup_lab ;;
    --reset) reset_lab ;;
    *)       echo "Usage: sudo bash $0 [--reset]" >&2; exit 1 ;;
esac
