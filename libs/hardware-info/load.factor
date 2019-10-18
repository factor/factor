! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;

PROVIDE: libs/hardware-info
{ +files+ {
    { "os-winnt.factor" [ winnt? ] }
    { "os-unix.factor" [ unix? ] }
    "cpuinfo.factor"
} }
{ +tests+ {
    { "os-winnt.factor" [ winnt? ] }
    { "os-unix.factor" [ unix? ] }
} } ;

