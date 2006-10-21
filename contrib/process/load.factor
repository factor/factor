IN: process
USING: kernel ;
PROVIDE: contrib/process {
    { "os-unix.factor" [ unix? ] }
    { "os-windows.factor" [ windows? ] }
} ;
