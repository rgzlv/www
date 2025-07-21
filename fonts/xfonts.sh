#!/bin/sh
set -e

usage() {
	printf "\
usage: xfonts.sh {sans | mono} zip
Extracts the needed sans or mono fonts from a Fira fonts zip archive available at
https://carrois.com/fira
" >&2
	exit 1
}

type="$1"
zip="$2"
[ ! "$type" ] && usage
[ ! "$zip" ] && usage

find_font() {
	[ ! "$1" ] && exit 1
	unzip -l "$zip" | grep -E "WEB.*\.woff2$" |
	    grep -viE "(compressed|condensed|macosx)" | grep -i -- "$1" |
	    awk '{print $4}'
}

if [ "$type" = "sans" ]; then
	names="regular -bold\. -ultra\. -italic\. -bolditalic ultraitalic"
elif [ "$type" = "mono" ]; then
	names="regular bold"
else
	usage
fi

mkdir -p tmp
for name in $names; do
	src="$(find_font $name)"
	name="$(printf -- "$name" | sed "s/[-\\.]//g")"
	dst="fira-$type-$name.woff2"
	unzip -d tmp "$zip" "$src" >/dev/null
	mv "tmp/$src" "$dst"
done
rm -rf tmp
