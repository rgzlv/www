divert(-1)
dnl Preliminary redefinitions used by the script to generate the rest
define(M4_DEFINE, defn(`define'))
undefine(`define')
M4_DEFINE(M4_DEFN, defn(`defn'))
undefine(`defn')
M4_DEFINE(M4_UNDEFINE, M4_DEFN(`undefine'))
M4_UNDEFINE(`undefine')
dnl Uses the above macros
include(m4/redef.m4)

M4_DEFINE(M4_HTML, `M4_INCLUDE(include/html/'$1`.html)')
M4_DIVERT(0)M4_DNL
