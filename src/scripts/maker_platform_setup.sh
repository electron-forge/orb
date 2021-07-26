#!/bin/bash -xe

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)"

case "$(uname -s)" in
  "Linux")
    case "$MAKER" in
      "deb")
        sudo apt-get install --yes --no-install-recommends fakeroot dpkg
        ;;
      "rpm")
        sudo apt-get update
        sudo apt-get install --yes --no-install-recommends rpm
        ;;
      "flatpak")
        "$DIR"/install_flatpak_dependencies.sh
        ;;
      "snap")
        "$DIR"/install_snap_dependencies.sh
        ;;
    esac
    ;;
  "Windows"|"MINGW"|"MSYS"*)
    if [[ "$MAKER" = "wix" ]]; then
      choco install wixtoolset
      # WHY: We don't want to expand this, we want this in BASH_ENV verbatim
      # shellcheck disable=SC2016
      echo 'export PATH="$PATH:/c/Program Files (x86)/WiX Toolset v3.11/bin"' >> "$BASH_ENV"
    fi
    ;;
esac
