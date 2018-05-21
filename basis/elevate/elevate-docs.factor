USING: arrays elevate.private help.markup help.syntax
io.launcher kernel strings system words ;
IN: elevate

: $say-shexw ( children -- )
    drop "ShellExecuteW" dup "windows.shell32" lookup-word [ ($link) ] [ $snippet ] if ;

ABOUT: elevate

ARTICLE: "elevate" "Elevated permissions API"
    "The " { $vocab-link "elevate" } " vocabulary provides abstractions for running programs with elevated (administrator) privileges (permissions). It allows code to relaunch itself or other programs with administrator privileges after requiring a password."
    $nl
     "This vocabulary is inspired by and ported from " { $url "https://github.com/barneygale/elevate" "Barney Gale's elevate.py" } "."
    { $subsections elevate elevated lowered }
    
    "However, there are many caveats: " { $link "elevate.bugs" }
;

ARTICLE: "elevate.bugs" "Elevate bugs and caveats"
    "There are many inherent platform-specific limitations and workarounds in the " { $vocab-link "elevate" } " elevated privileges API. This article explains and documents them for the curious, future maintainers, or those who run into problems."
    { $heading "macOS" }
    "On Apple macOS, an Applescript command is attempted for a graphical method before " { $snippet "sudo" } ". Sometimes, this command appears to execute incorrectly due to the group of the user owning the calling process. On macOS, " { $snippet "sudo" } " suffers the drawback mentioned below for applications which do not have a TTY connected."
    { $heading "Linux, *BSD and other Unix-likes" }
    "On Linux, " { $snippet "gksudo" } ", " { $snippet "kdesudo" } ", and " { $snippet "pkexec" } " are all attempted graphical methods before " { $snippet "sudo" } "."
    { $list 
        { { $snippet "pkexec" } " is the preferred and most secure graphical authentication method on Linux. It is undesirable for Factor applications, because unless a certain rare global registry value is set, " { $snippet "pkexec" } " does not set the " { $snippet "$DISPLAY" } " environment variable, and thus cannot launch graphical applications despite being a graphical program itself. It is tried after " { $snippet "gksudo" } " and " { $snippet "kdesudo" } " but before " { $snippet "sudo" } "." }
        { { $snippet "gksudo" } " and " { $snippet "kdesudo" } " are deprecated, but still present on most GTK- and KDE-based systems, respectively. GTK is more widespread than KDE so " { $snippet "gksudo" } " is tried before " { $snippet "kdesudo" } ". These old-fashioned methods ensure that the launched application can be graphical, so they are preferred for Factor." }
        { { $snippet "sudo" } " is the final and most robust strategy tried on Linux. It is text-based, so it requires the calling process to have an active and accessible terminal (TTY) for user authentication. If the calling Factor application was started from the desktop graphical shell rather than from a TTY, this method will fail." }
    }
    "On other Unix-like or POSIX-like operating systems, " { $snippet "sudo" } " is the only consistently popular method of authentication, and it suffers the same drawback on other Unix-likes as on Linux." 
    { $heading "Windows" }
    { "On Windows, the FFI word " { $say-shexw } " is used with the verb " { $snippet "runas" } " to force the new process to run with User Account Control." } 
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
