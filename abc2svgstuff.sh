##################################################################################
#
# Functions shared by the abc2svgstuff scripts. This file is sourced, not run.
#
# Each script locates this file with the following prelude, which follows
# symbolic links so that the scripts can be linked from another directory:
#
#   self=$0
#   while [ -L "$self" ]; do
#     link=$(readlink "$self")
#     case $link in /*) self=$link ;; *) self=$(dirname "$self")/$link ;; esac
#   done
#   STUFFDIR=$(cd "$(dirname "$self")" && pwd)
#   . "$STUFFDIR/abc2svgstuff.sh"
#
# Environment:
#   ABC2SVG_DIR  directory of the abc2svg installation (containing abcnode).
#                By default: the directory of "abcnode" if it is in the PATH,
#                else the "abc2svg" directory next to the abc2svgstuff directory.
#
# Frédéric Boulanger                     frederic.softdev@gmail.com
#
##################################################################################

# Get name of current script without the leading path without using basename
PROG=${0##*/}

die() {
  printf '%s: %s\n' "$PROG" "$*" >&2
  exit 1
}

warn() {
  printf '%s: %s\n' "$PROG" "$*" >&2
}

# Print a path with all symbolic links of its last component followed
resolve_link() {
  _p=$1
  while [ -L "$_p" ]
  do
    _l=$(readlink "$_p")
    case $_l in
      /*) _p=$_l ;;
      *)  _p=$(dirname "$_p")/$_l ;;
    esac
  done
  printf '%s\n' "$_p"
}

# Absolute version of a path, relative to the current directory
abspath() {
  case $1 in
    /*) printf '%s\n' "$1" ;;
    *)  printf '%s/%s\n' "$PWD" "$1" ;;
  esac
}

# Set ABC2SVG_DIR to the abc2svg installation directory
find_abc2svg() {
  if [ -z "${ABC2SVG_DIR:-}" ]
  then
    if _n=$(command -v abcnode 2>/dev/null) && [ -n "$_n" ]
    then
      ABC2SVG_DIR=$(dirname "$(resolve_link "$_n")")
    elif [ -f "$STUFFDIR/../abc2svg/abcnode" ]
    then
      ABC2SVG_DIR=$(cd "$STUFFDIR/../abc2svg" && pwd)
    fi
  fi
  [ -n "${ABC2SVG_DIR:-}" ] && [ -f "$ABC2SVG_DIR/abcnode" ] \
    || die "abc2svg not found: put abcnode in the PATH or set ABC2SVG_DIR"
}

# Run a script of the abc2svg installation (directly if it is executable)
abc2svg_script() {
  find_abc2svg
  _s=$ABC2SVG_DIR/$1
  shift
  [ -f "$_s" ] || die "$_s not found"
  if [ -x "$_s" ]; then "$_s" "$@"; else sh "$_s" "$@"; fi
}

# Run abc2svg with node (abcnode)
abc2svg_run() {
  abc2svg_script abcnode "$@"
}

# Run the abctopdf script of abc2svg
abc2svg_topdf() {
  abc2svg_script abctopdf "$@"
}

# Version of abc2svg, as "abc2svg-x.y.z"
abc2svg_version() {
  _v=$(abc2svg_run </dev/null 2>&1 | sed -n -e 's/.*\(abc2svg-[0-9][0-9.]*[0-9]\).*/\1/p' | head -n 1)
  printf '%s\n' "${_v:-abc2svg}"
}

# Create a temporary directory, removed when the script exits
make_tmpdir() {
  TMPD=$(mktemp -d "${TMPDIR:-/tmp}/abc2svgstuff.XXXXXX") || die "cannot create a temporary directory"
#  printf 'TMPD=%s\n' "$TMPD"
  mkdir "$TMPD/s"  # files named after the source file go here
  trap 'rm -rf "$TMPD"' EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM HUP
}

# abc_source <abc_file>
#   Check the source file, set SRC_DIR (absolute directory), SRC_NAME (name
#   without the .abc extension) and SRC (file name in SRC_DIR), and cd to SRC_DIR.
#   Output files are written in this directory, as in the previous versions.
abc_source() {
  [ -f "$1" ] && [ -r "$1" ] || die "cannot read $1"
  SRC_DIR=$(cd "$(dirname "$1")" && pwd) || die "cannot access the directory of $1"
  SRC=${1##*/}
  SRC_NAME=${SRC%.abc}
  cd "$SRC_DIR" || die "cannot cd to $SRC_DIR"
}

# abc_flatten <abc_file> <output_file>
#   Flatten the includes of an ABC file (see abcflatten)
abc_flatten() {
  sh "$STUFFDIR/abcflatten" "$1" > "$2" || die "could not process the includes of $1"
}

# Common awk code to walk through the tunes of an ABC file.
# A tune starts with an X: line and ends at the first empty line
# (outside of a %%begintext/%%endtext block).
ABC_TUNES_AWK='
function update_text() {
  if ($0 ~ /^%%begintext/) intext = 1
  else if ($0 ~ /^%%endtext/) intext = 0
}
{ sub(/\r$/, "") }
!intune && /^X:/ { intune = 1; n++ ; on_start(); next }
intune && !intext && /^[ \t]*$/ { intune = 0; on_end(); next }
{ update_text(); if (intune) on_tune(); else on_outside() }
'

# abc_tune_count <abc_file>: number of tunes
abc_tune_count() {
  awk '
    function on_start() {} function on_end() {}
    function on_tune() {} function on_outside() {}
    '"$ABC_TUNES_AWK"'
    END { print n + 0 }' "$1"
}

# abc_tune_x <abc_file> <index>: value of the X: field of the tune at <index> (from 1)
abc_tune_x() {
  awk -v want="$2" '
    function on_start(   x) { if (n == want) { x = $0; sub(/^X:[ \t]*/, "", x); sub(/[ \t%].*$/, "", x); print x } }
    function on_end() {} function on_tune() {} function on_outside() {}
    '"$ABC_TUNES_AWK" "$1"
}

# abc_tune <abc_file> <index>
#   Print the tune at <index> (from 1), preceded by the file header and by
#   the lines between the previous tunes that may change the settings
#   (fields and %% directives, but not text blocks and free text).
#   This avoids --select, whose regular expression "X:1" also matches X:10.
abc_tune() {
  awk -v want="$2" '
    function on_start() { if (n == want) print }
    function on_end()   { if (n == want) exit }
    function on_tune()  { if (n == want) print }
    function on_outside() {
      if (n >= want) return
      if (outtext || $0 ~ /^%%begintext/) { outtext = ($0 !~ /^%%endtext/); return }
      if ($0 ~ /^(%|[A-Za-z]:)/) print
    }
    '"$ABC_TUNES_AWK" "$1"
}
