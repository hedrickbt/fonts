#!/bin/sh
# Runs inside a clean ubuntu container: install the real
# ttf-mscorefonts-installer (downloads from SourceForge), then replace it with
# the bundled package via apt and via dpkg -i. The original's prerm deletes
# the fonts in the shared directory, so check ours survive the swap.
set -e
export DEBIAN_FRONTEND=noninteractive
FONTDIR=/usr/share/fonts/truetype/msttcorefonts
DEB=$(ls /dist/ttf-mscorefonts-bundled_*_all.deb)

sed -i 's/^Components: .*/Components: main restricted universe multiverse/' \
    /etc/apt/sources.list.d/ubuntu.sources
apt-get update -qq
apt-get install -y -qq fontconfig >/dev/null
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" \
    | debconf-set-selections

install_original() {
    apt-get install -y -qq ttf-mscorefonts-installer >/dev/null
    [ -s /var/lib/msttcorefonts/ms-fonts ] || { echo "original failed to download fonts"; exit 1; }
}

check_bundled() {
    dpkg -s ttf-mscorefonts-bundled | grep -q '^Status: install ok installed'
    if dpkg -s ttf-mscorefonts-installer 2>/dev/null | grep -q '^Status: .* installed$'; then
        echo "original still installed"; exit 1
    fi
    [ "$(find $FONTDIR -type f -name '*.ttf' | wc -l)" -eq 30 ]
    [ "$(find $FONTDIR -type l -name '*.ttf' | wc -l)" -eq 30 ]
    dpkg -S $FONTDIR/Arial.ttf | grep -q '^ttf-mscorefonts-bundled:'
    [ "$(fc-match -f '%{file}' Arial)" = "$FONTDIR/Arial.ttf" ]
}

echo "== swap with apt"
install_original
apt-get install -y -qq "$DEB" >/dev/null
check_bundled

echo "== swap back to original, then swap with dpkg -i"
apt-get install -y -qq ttf-mscorefonts-installer >/dev/null
[ -s /var/lib/msttcorefonts/ms-fonts ]
dpkg -s ttf-mscorefonts-bundled >/dev/null 2>&1 && { echo "bundled not removed"; exit 1; }
dpkg -i --auto-deconfigure "$DEB"
check_bundled

echo "SWAP TESTS PASSED"
