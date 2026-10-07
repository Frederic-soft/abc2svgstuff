# abc2svgstuff
Various things that are useful when working with [abc2svg](https://chiselapp.com/user/moinejf/repository/abc2svg/doc/trunk/README.md)

The scripts are POSIX shell and awk scripts: they work with the `/bin/sh` and `awk`
of macOS and Linux, and need nothing else than abc2svg (and abc2midi, abc2xml,
pdfcrop or mscore for some of them).

## Some resources:
* Jean-François Moine's page (abc2svg) <https://moinejf.pages-perso.free.fr/>
* Seymour Shlien's page (abc2midi and others) <https://ifdo.ca/~seymour/runabc/top.html>
* The ABC plus project (documentation) <http://abcplus.sourceforge.net/>
* The ABC notation standard <http://abcnotation.com/wiki/abc:standard:v2.2>

## Installation
`./install.sh [-y] [<dir>]` creates symbolic links to the tools in `<dir>`
(default: `$HOME/bin`), which should be in your `PATH`.

The scripts look for abc2svg in this order:
1. the directory given by the `ABC2SVG_DIR` environment variable;
2. the directory of `abcnode` if it is in the `PATH` (this is the case in the
   Docker image of [docker_abc2svg](../docker_abc2svg));
3. the `abc2svg` directory next to the `abc2svgstuff` directory.

## Includes
All the scripts process includes with `abcflatten` before calling abc2svg:
* `%%abc-include`, `I:abc-include` and `#include` are recognized, the file name
  may be between double quotes and may be followed by a `%` comment;
* includes are processed recursively, without limit of depth (loops are detected);
* an included file is searched relative to the directory of the file that includes it,
  then relative to the directory of the main file, then in the directories of `$ABCPATH`;
* in `%%header` and `%%footer` lines, `$d` is replaced by the date of the most recent
  file among the main file and its includes;
* a missing include is an error.

`abcflatten -l file.abc` lists the file and its includes, and `abcflatten -M targets file.abc`
prints the corresponding make dependencies.

Files with several tunes are split by the scripts themselves when they produce one file per
tune (MIDI, MusicXML, MEI), instead of using `--select X:n`, whose regular expression
`X:1` also matches `X:10`. Each tune keeps the file header and the settings that precede it.

## Explanations
* `abcsvgintex` contains a LaTeX package to include ABC notation in LaTeX documents.
* `Makefile.abc2svg` is a Makefile that you can use to convert ABC files to PDF, static or dynamic HTML, MIDI, and MusicXML.
  It relies on the scripts below, and tracks the dependencies on included files at any depth.
* `abc2svg` is a wrapper script for using abc2svg with node (`abcnode`)
* `abctopdf` is a wrapper script for running the `abctopdf` script of abc2svg
* `abc2svgabc` is a helper script for abc2svg toabc.js
* `abc2svgbuild` generates a web page, a PDF file, and MusicXML and MuseScore files from an ABC source file
* `abc2svghtml` uses abc2svg to generate a static HTML page (no JavaScript required) from an ABC source file
* `abc2svgmei` uses abc2svg to convert an ABC source file to [MEI](https://music-encoding.org/)
* `abc2svgmidi` uses abc2svg and abc2midi to convert an ABC source file into MIDI files
* `abc2svgpdf` uses abc2svg to generate a PDF file from an ABC source file
* `abc2svgpdfcrop` does the same, and crops the PDF file to the size of the music (with pdfcrop)
* `abc2svgweb` uses abc2svg to generate a dynamic HTML page with MIDI playback (JavaScript required) from an ABC source file
* `abc2svgwpdf` generates a PDF file by printing the dynamic HTML page with Chrome
* `abc2svgxml` uses abc2svg and abc2xml to convert an ABC source file into [MusicXML](https://www.musicxml.com/) files
* `abcflatten` is a helper script for processing includes in an ABC file
* `abcrmtext` is a helper script for suppressing text blocks from an ABC file
* `abc2svgstuff.sh` contains the functions shared by the scripts

Output files are written next to the ABC file. When an output file or base name is given
explicitly (`abc2svgweb -o`, `abc2svgxml -o`, `abc2svgmidi <base>`, `abc2svghtml <file>`,
`abc2svgabc <dst>`), it is relative to the current directory.

## Environment variables
| Variable | Used by | Default |
|---|---|---|
| `ABC2SVG_DIR` | all | see Installation |
| `ABC2SVG_JSURL` | `abc2svgweb` (and `Makefile.abc2svg`) | `http://moinejf.free.fr/js` |
| `ABCPATH` | `abcflatten` (and abc2svg) | |
| `ABCFLATTEN_DATEFMT` | `abcflatten` | `%Y-%m-%d %H:%M` |
| `ABC2MIDI` | `abc2svgmidi` | `abc2midi` |
| `ABC2XML` | `abc2svgxml` | `abc2xml` |
| `PDFCROP` | `abc2svgpdfcrop` | `pdfcrop`, or the copy in this directory |
| `BROWSER` | `abc2svgwpdf` | `google-chrome`, `chromium` or Google Chrome.app |
| `MSCORE` | `abc2svgbuild` | `mscore` |
| `ABC2SVG_NO_REFRESH` | `abc2svghtml` | unset: reload the page in Chrome on macOS |
