USING: kernel modules namespaces sequences ;

"calendar"
[
    {
        { [ unix? macosx? not and ] [ "os-unix.factor" , "os-linux.factor" , ] }
        { [ macosx? ] [ "os-unix.factor" , "os-macosx.factor" , ] }
        { [ unix? ] [ "os-unix.factor" , ] }
        { [ win32? ] [ "os-win32.factor" , ] }
    } cond
    "calendar.factor" ,
] { } make

{ "test/calendar.factor" }
provide

