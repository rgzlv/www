#!/bin/sh
set -eu

macros="changecom changequote decr divert divnum dnl dumpdef errprint eval ifdef ifelse include incr index len m4exit m4wrap maketemp mkstemp popdef pushdef shift sinclude substr syscmd sysval traceon traceoff translit undivert"

for macro in $macros; do
	# Strip the repetitive "m4" prefix from some macros
	if [ ! "${macro##m4*}" ]; then
		macro_upper="$(printf "${macro#m4}" | tr "[:lower:]" "[:upper:]")"
	else
		macro_upper="$(printf "$macro" | tr "[:lower:]" "[:upper:]")"
	fi
	echo "M4_DEFINE(M4_$macro_upper, M4_DEFN(\`$macro'))"
	echo "M4_UNDEFINE(\`$macro')"
done
