USE: kernel
PROVIDE: contrib/process
{ +files+ {
    { "os-unix.factor" [ unix? ] }
    { "os-windows.factor" [ windows? ] }
} } ;
