#!/bin/sh
# Runs inside a clean ubuntu container: install, check fonts, check that the
# package satisfies dependents of ttf-mscorefonts-installer, then remove.
set -e
export DEBIAN_FRONTEND=noninteractive
FONTDIR=/usr/share/fonts/truetype/msttcorefonts

sed -i 's/^Components: .*/Components: main restricted universe multiverse/' \
    /etc/apt/sources.list.d/ubuntu.sources
apt-get update -qq

echo "== install"
apt-get install -y -qq fontconfig /dist/ttf-mscorefonts-bundled_*_all.deb

echo "== fonts on disk"
[ "$(find $FONTDIR -type f -name '*.ttf' | wc -l)" -eq 30 ]
[ "$(find $FONTDIR -type l -name '*.ttf' | wc -l)" -eq 30 ]

echo "== fontconfig sees them"
for family in "Andale Mono" "Arial" "Arial Black" "Comic Sans MS" "Courier New" \
              "Georgia" "Impact" "Times New Roman" "Trebuchet MS" "Verdana" "Webdings"; do
    fc-list : family | grep -qx "$family" || { echo "not found: $family"; exit 1; }
done
[ "$(fc-match -f '%{file}' Arial)" = "$FONTDIR/Arial.ttf" ]

echo "== Provides satisfies ttf-mscorefonts-installer dependents"
if apt-cache show ubuntu-restricted-extras >/dev/null 2>&1; then
    if apt-get install -s ubuntu-restricted-extras | grep -q '^Inst ttf-mscorefonts-installer'; then
        echo "ubuntu-restricted-extras would pull in ttf-mscorefonts-installer"; exit 1
    fi
else
    echo "(ubuntu-restricted-extras not available on this arch; skipped)"
fi
if apt-get install -s ttf-mscorefonts-installer | grep -q '^Remv ttf-mscorefonts-bundled'; then
    echo "ok: installing the original would replace this package (Conflicts works)"
fi

echo "== remove"
apt-get remove -y -qq ttf-mscorefonts-bundled
[ ! -e $FONTDIR ]

echo "ALL TESTS PASSED"
