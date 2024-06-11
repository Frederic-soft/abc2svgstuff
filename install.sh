#!/bin/sh
INSTALLDIR="$HOME/bin"
TOOLS="abc2svg \
	  abc2svgabc \
	  abc2svghtml \
	  abc2svgmei \
	  abc2svgmidi \
	  abc2svgpdf \
	  abc2svgpdfcrop \
	  abc2svgweb \
	  abc2svgxml \
	  abcflatten \
	  abcrmtext \
	  abctopdf"

ME=`realpath $0`
CURDIR=`dirname ${ME}`

echo "Installing from ${CURDIR} to ${INSTALLDIR}"
read -p "Continue [y/n]? " -r
if [[ ! ${REPLY} =~ ^[Yy]$ ]]
then
	exit 1
fi
if [[ ! -d "${INSTALLDIR}" ]]
then
	mkdir -p "${INSTALLDIR}"
fi
for t in ${TOOLS}
do
	echo "ln -s ${CURDIR}/$t ${INSTALLDIR}/$t"
	ln -s "${CURDIR}/$t" "${INSTALLDIR}/$t"
done