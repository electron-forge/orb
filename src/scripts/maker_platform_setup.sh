#!/bin/bash -xe

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
        "$(dirname $0)"/install_flatpak_dependencies.sh
        ;;
      "snap")
        "$(dirname $0)"/install_snap_dependencies.sh
        ;;
    esac
    ;;
  "Windows"|"MINGW"|"MSYS"*)
    if [[ "$MAKER" = "wix" ]]; then
      choco install wixtoolset
      echo 'export PATH="$PATH:/c/Program Files (x86)/WiX Toolset v3.11/bin"' >> "$BASH_ENV"
    fi
    ;;
esac
