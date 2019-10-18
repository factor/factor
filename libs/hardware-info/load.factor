! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;

PROVIDE: libs/hardware-info
{ +files+ {
    { "os-windows.factor" [ windows? ] }
    { "os-unix.factor" [ unix? ] }
    "cpuinfo.factor"
} }
{ +tests+ {
} } ;

