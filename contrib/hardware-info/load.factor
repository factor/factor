! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;

PROVIDE: contrib/hardware-info
{ +files+ {
    { "os-windows.factor" [ windows? ] }
    { "os-unix.factor" [ unix? ] }
    "cpuinfo.factor"
} }
{ +tests+ {
} } ;

