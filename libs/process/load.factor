USE: kernel
PROVIDE: libs/process
{ +files+ {
    { "os-unix.factor" [ unix? ] }
    { "os-windows.factor" [ windows? ] }
} } ;
