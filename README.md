# abc2svgstuff
Various things that are useful when working with [abc2svg](https://chiselapp.com/user/moinejf/repository/abc2svg/doc/trunk/README.md)

Requires `coreutils` (for `realpath`):
* `brew install coreutils` with MacOS
* `apt-get install coreutils` with Linux

## Some resources:
* Jean-François Moine's page (abc2svg) <http://moinejf.free.fr/>
* Seymour Shlien's page (abc2midi and others) <https://ifdo.ca/~seymour/runabc/top.html>
* The ABC plus project (documentation) <http://abcplus.sourceforge.net/>
* The ABC notation standard <http://abcnotation.com/wiki/abc:standard:v2.2>

## Explanations
* `Makefile.abc2svg` is a Makefile that you can use to convert ABC files to PDF, static or dynamic HTML, MIDI, and MusicXML.
  It relies only on an installation of abc2svg and the abcflatten and abcrmtext scripts.
* `abc2svg` is a wrapper script for using abc2svg with node when it is not installed by npm
* `abc2svgabc` is a helper script for abc2svg toabc.js
* `abc2svghtml` uses abc2svg to generate a static HTML page (no JavaScript required) from an ABC source file
* `abc2svgmei` uses abc2svg to convert an ABC source file to [MEI](https://music-encoding.org/)
* `abc2svgmidi` uses abc2svg and abc2midi to convert an ABC source file into MIDI files
* `abc2svgpdf` uses abc2svg to generate a PDF file from an ABC source file
* `abc2svgweb` uses abc2svg to generate a dynamic HTML page with MIDI playback (JavaScript required) from an ABC source file
* `abc2svgxml` uses abc2svg and abc2xml to convert an ABC source file into [MusicXML](https://www.musicxml.com/) files
* `abcflatten` is a helper script for processing includes in an ABC file
* `abcrmtext` is a helper script for suppressing text block from an ABC file
* `abctopdf` is a wrapper script for running abctopdf when abc2svg is not installed by npm
