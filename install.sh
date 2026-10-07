#!/bin/sh
##################################################################################
#
# Install the abc2svgstuff tools by creating symbolic links in a directory
# of the PATH.
#
#   install.sh [-y] [<install_dir>]      (default: $HOME/bin)
#
#   -y  do not ask for confirmation
#
# Frédéric Boulanger                     frederic.softdev@gmail.com
#
##################################################################################
TOOLS="abc2svg
abc2svgabc
abc2svgbuild
abc2svghtml
abc2svgmei
abc2svgmidi
abc2svgpdf
abc2svgpdfcrop
abc2svgweb
abc2svgwpdf
abc2svgxml
abcflatten
abcrmtext
abctopdf"

ask=yes
if [ "${1:-}" = "-y" ]
then
  ask=
  shift
fi
INSTALLDIR=${1:-$HOME/bin}
CURDIR=$(cd "$(dirname "$0")" && pwd)

echo "Installing from ${CURDIR} to ${INSTALLDIR}"
if [ -n "$ask" ]
then
  printf 'Continue [y/n]? '
  read -r reply
  case $reply in
    [Yy]*) ;;
    *) exit 1 ;;
  esac
fi
mkdir -p "${INSTALLDIR}" || exit 1
for t in ${TOOLS}
do
  echo "ln -sf ${CURDIR}/$t ${INSTALLDIR}/$t"
  ln -sf "${CURDIR}/$t" "${INSTALLDIR}/$t"
done
case ":$PATH:" in
  *":${INSTALLDIR}:"*) ;;
  *) echo "Warning: ${INSTALLDIR} is not in your PATH" ;;
esac
