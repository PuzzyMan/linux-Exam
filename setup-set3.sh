#!/usr/bin/env bash
# Worksheet set 3 (Technical College): User / Group / File permissions
#
#   sudo bash setup-set3.sh           prepare the machine before item 1
#   sudo bash setup-set3.sh --reset   remove everything this worksheet creates
#
# Use on a lab VM only.

BASE=/srv/college
LAB_USERS="anong kitti fah bank ploy collbak"
LAB_GROUPS="registar registrar lecturers deans"
LAB_GIDS="8999 8001 8002 8003"

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
    groupadd -g 8999 registar
    useradd -m -s /bin/bash -c 'Anong Meesri' -G registar anong
    useradd -m -s /bin/bash -c 'Kitti Panya' kitti
    printf '%s:College@2026\n' anong kitti | chpasswd
    mkdir -p "$BASE"

    echo "Setup complete."
    id anong
    id kitti
}

case "${1:-}" in
    "")      setup_lab ;;
    --reset) reset_lab ;;
    *)       echo "Usage: sudo bash $0 [--reset]" >&2; exit 1 ;;
esac
