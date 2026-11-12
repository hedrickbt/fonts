# ttf-mscorefonts-bundled

Offline replacement for Ubuntu's `ttf-mscorefonts-installer`. Instead of
downloading the `.exe` cabinets from SourceForge at install time, the
extracted `.ttf` files are shipped inside the `.deb`.

- `Provides: ttf-mscorefonts-installer (= 3.8.1), msttcorefonts`, so
  dependents such as `ubuntu-restricted-extras` are satisfied.
- `Conflicts`/`Replaces` the original, so installing this package removes it.
- No network access, debconf EULA prompt, `wget` or `cabextract` needed.
- Font cache is refreshed by fontconfig's dpkg trigger; no maintainer scripts.

## Build (on macOS or Linux, needs Docker)

1. Copy the 30 core-font `.ttf` files into `fonts/` (see `fonts/README.txt`;
   short `arial.ttf` or long `Arial.ttf` names both work). Optionally add the
   EULA as `licen.txt` or `READ_ME!.gz`.
2. `make` builds `dist/ttf-mscorefonts-bundled_1.0_all.deb` inside an
   `ubuntu:24.04` container. The build fails if any font is missing.

Other targets:

| target       | what it does                                                   |
|--------------|----------------------------------------------------------------|
| `make lint`  | run lintian on the built package                               |
| `make test`  | install in a clean container, check fontconfig, Provides, removal |
| `make test-swap` | replace a real installed `ttf-mscorefonts-installer` (needs network) |
| `make clean` | remove `dist/`                                                 |

Use `make FONTS=/some/dir` to build from fonts kept outside the tree.

## Install

```sh
sudo apt install ./ttf-mscorefonts-bundled_1.0_all.deb
```

If `ttf-mscorefonts-installer` is installed, apt removes it first and then
installs this package. Run `sudo apt purge ttf-mscorefonts-installer`
afterwards to clear its leftover debconf state.

## Layout

Fonts go in the same directory and layout as the original,
`/usr/share/fonts/truetype/msttcorefonts/`: long-name files (`Arial.ttf`) plus
short-name symlinks (`arial.ttf`), so applications that hard-code those paths
keep working. Here the files are owned by dpkg, so `dpkg -S` reports them.

The original package's `prerm` deletes the fonts in that directory. During a
swap, dpkg runs the conflicting package's `prerm remove in-favour` *before*
unpacking this package, so that deletion finishes before these files arrive.
`make test-swap` checks this for both `apt install` and `dpkg -i`. It needs
network access because it installs the real original first.

## Licensing

The fonts are covered by Microsoft's EULA, which allows redistribution only in
the original `.exe` form. This package is for private/internal use. Do not
upload it to a public archive or PPA.
