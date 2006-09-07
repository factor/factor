USE: kernel

PROVIDE: contrib/calendar {
    { "os-unix.factor" [ unix? ] }
    { "os-win32.factor" [ windows? ] }
    "calendar.factor"
} { "test/calendar.factor" } ;

