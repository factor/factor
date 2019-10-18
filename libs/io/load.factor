USING: kernel ;

REQUIRES: libs/calendar libs/shuffle ;

PROVIDE: libs/io
{ +files+ {
    "io.factor"
    "mmap.factor"
    "shell.factor"
    { "os-unix.factor" [ unix? ] }
    { "os-unix-shell.factor" [ unix? ] }
    { "mmap-os-unix.factor" [ unix? ] }

    { "os-winnt.factor" [ winnt? ] }
    { "os-winnt-shell.factor" [ winnt? ] }
    { "mmap-os-winnt.factor" [ winnt? ] }

    { "os-wince.factor" [ wince? ] }
} }
{ +tests+ {
    "test/io.factor"
    "test/mmap.factor"
} } ;

