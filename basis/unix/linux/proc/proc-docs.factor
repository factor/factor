USING: destructors help.markup help.syntax io.backend.unix kernel
strings ;
IN: unix.linux.proc

HELP: <proc-pid-directory>
{ $values { "pid" "a process ID or process directory name such as self" } { "fd" fd } }
{ $description "Opens a process directory for subsequent relative reads. The descriptor continues to identify that directory if the PID is reused. Reads can still fail if the process exits; this is not an atomic snapshot of its contents." }
{ $notes "Dispose of the descriptor after use, normally with " { $link with-disposal } "." } ;

HELP: proc-pid-contents
{ $values { "pid" "a process ID, process directory name, or open directory descriptor" } { "name" string } { "string" string } }
{ $description "Reads a UTF-8 process file. With an open directory descriptor, the filename is resolved relative to that descriptor using openat." } ;

HELP: string>pid-stat
{ $values { "string" string } { "stat" pid-stat } }
{ $description "Parses the contents of a process stat file, preserving spaces, newlines, and parentheses in its filename field. The filename includes the surrounding parentheses used by procfs." } ;
