Put the 30 extracted Microsoft core font .ttf files here.

Either naming works (case-insensitive), see ../debian/expected-fonts.txt:
  short names:  arial.ttf, arialbd.ttf, ...       (as extracted from the .exe)
  long names:   Arial.ttf, Arial_Bold.ttf, ...    (as installed by ttf-mscorefonts-installer)

Optionally also add the EULA as licen.txt or READ_ME!.gz.

From an Ubuntu machine that already has ttf-mscorefonts-installer:
  scp 'host:/usr/share/fonts/truetype/msttcorefonts/[A-Z]*.ttf' .
  scp 'host:/usr/share/doc/ttf-mscorefonts-installer/READ_ME!.gz' .
