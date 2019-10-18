USE: kernel

PROVIDE: libs/calendar
{ +files+ {
    "calendar.factor"
    { "os-unix.factor" [ unix? ] }
    { "os-winnt.factor" [ winnt? ] }
    { "os-wince.factor" [ wince? ] }
} }
{ +tests+ {
    "test/calendar.factor"
    { "test/os-winnt.factor" [ winnt? ] }
    { "test/os-wince.factor" [ wince? ] }
    { "test/os-unix.factor" [ unix? ] }
} } ;
