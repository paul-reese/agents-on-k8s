#!/usr/bin/env bash
# Delete the whole Colima profile (cluster, images, volumes).
source "$(dirname "$0")/lib.sh"
read -r -p "Delete Colima profile '$COLIMA_PROFILE' and everything in it? [y/N] " ans
[[ "$ans" == "y" ]] && colima delete "$COLIMA_PROFILE" --force
