USING: kernel modules sequences ;
"calendar"

{
    { [ win32? ] [ { "os-win32.factor" } ] }
    { [ t ] [ { "os-unix.factor" } ] }
} cond
{
    "calendar.factor" 
} append

{ "test/calendar.factor" }
provide

