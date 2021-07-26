#!/bin/bash -xe

install_flatpak_app() {
    local arch="$1"
    local app="$2"
    local branch=$3
    install_flatpak "app/$app/$arch/$branch"
}

install_flatpak_runtime() {
    local arch="$1"
    local runtime="$2"
    local version="$3"
    install_flatpak "runtime/${runtime}/$arch/$version"
}

install_flatpak() {
    local ref="$1"
    if [[ ! -d "$HOME/.local/share/flatpak/$ref" ]]; then
        flatpak install --user --no-deps --assumeyes "$ref"
    fi
}

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
        ####
        # NOTE
        #
        # There do not appear to be flatpak app/runtime dependencies for arm64 as of 2021/07/21.
        # This script has support for it in the future, but for now is likely limited to x86_64.
        ####

        if [[ -z "$ARCH" ]]; then
          ARCH=x64
        fi

        case "$ARCH" in
          x64)
            flatpak_arch=x86_64
            ;;
          arm64)
            flatpak_arch=arm64
            ;;
          *)
            echo "ERROR: Unknown arch: '$ARCH'" >&2
            exit 1
            ;;
        esac
        sudo add-apt-repository -y ppa:alexlarsson/flatpak
        sudo apt-get update
        sudo apt-get install -y --no-install-recommends flatpak-builder elfutils
        flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

        install_flatpak_runtime "$flatpak_arch" org.freedesktop.Sdk 19.08
        install_flatpak_runtime "$flatpak_arch" org.freedesktop.Platform 19.08
        install_flatpak_app "$flatpak_arch" org.electronjs.Electron2.BaseApp stable
        ;;
      "snap")
        sudo apt-get update
        sudo apt-get install --yes --no-install-recommends snapcraft

        mkdir -p fakesnap/snap
        cp ci/snapcraft.yaml fakesnap/snap/
        pushd fakesnap
        snapcraft pull desktop-gtk3 electron-deps
        popd
        rm -rf fakesnap
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
