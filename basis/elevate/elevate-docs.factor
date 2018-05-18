USING: arrays elevate.private help.markup help.syntax
io.launcher kernel strings system ;

IN: elevate

ABOUT: elevate

ARTICLE: "elevate" "Elevated permissions API"
    "Ported from " { $url "https://github.com/barneygale/elevate" "Barney Gale's implementation" } " in Python."
    { $subsections elevate elevated lowered }
;

HELP: elevated
{ $values { "command" { $or array string } } { "replace?" boolean } { "win-console?" boolean } { "posix-graphical" boolean } }
{ $description
    "Spawn a process from the command " { $snippet "command" } " with superuser (administrator) privileges. If the calling process does not already have superuser privileges, it will request them by a number of platform-specific methods."
    $nl
    "If " { $snippet "replace?" } " is " { $link t } ", the calling Factor process will be replaced with the command (but see Notes)."
    $nl
    "Windows-specific: If " { $snippet "win-console?" } " is " { $link t } ", a new console window will " { $emphasis "always" } " be spawned for the resulting process, regardless of " { $snippet "replace?" } "."
    $nl
    "Mac and Linux-specific: If " { $snippet "posix-graphical?" } " is " { $link t } ", a graphical password method will be attempted before " { $snippet "sudo" } "."
    $nl
    "If the calling process is already run as superuser, nothing happens. The input command is left on the stack, placed into a "{ $link process } " inside an "{ $link array } "."
}
{ $notes
    { $list
        { "On Windows, " { $snippet "replace?" } " has the effect of killing (with " { $link exit } ") the calling process after spawning the command because there is no " { $snippet "exec" } " equivalent in Windows." }
    }
}
{ $errors
    { $link elevated-failed } " when all strategies fail."
    $nl
    "Any errors thrown by " { $link run-process } "."
} ;

HELP: elevate
{ $values { "win-console?" boolean } { "posix-graphical" boolean } }
{ $description "Relaunch the current Factor process with superuser privileges. See " { $link elevated } " for an explanation, as the semantics are identical." } ;

HELP: lowered
{ $description "Give up all superuser rights, returning a process to normal userspace."
{ $notes "If the process is running as \"real superuser\", (not an impersonation), nothing happens." $nl "If the process is running as an unprivileged user, nothing happens." }
}
{ $errors { $link lowered-failed } " when giving up superuser rights failed." } ;
