USING: kernel modules namespaces sequences ;

"calendar"
[
    {
        { [ unix? ] [ "os-unix.factor" , ] }
        { [ win32? ] [ "os-win32.factor" , ] }
    } cond
    "calendar.factor" ,
] { } make
{ "test/calendar.factor" }
provide

