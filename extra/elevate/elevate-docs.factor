USING: arrays elevate elevate.private help.markup help.syntax
io.launcher kernel sequences strings system words ;
IN: elevate

<PRIVATE
: $resolve? ( children -- ) 
    first2 2dup swap lookup-word dup word? [ 2nip ($link) ] [ drop ":" glue $snippet ] if ; 
PRIVATE>

ABOUT: "elevate"

ARTICLE: "elevate" "Elevated permissions API"
    "The " { $vocab-link "elevate" } " vocabulary provides abstractions for running programs with elevated (administrator) privileges (permissions). It allows code to relaunch itself or other programs with administrator privileges after requiring a password."
    $nl
    "This vocabulary is inspired by and ported from " { $url "https://github.com/barneygale/elevate" "Barney Gale's elevate.py" } "."
    $nl
    { $subsections already-root? elevate elevated lowered }
    "However, there are many caveats: " { $link "elevate.bugs" } "." ;

ARTICLE: "elevate.bugs" "Elevate bugs and caveats"
    "There are many inherent platform-specific limitations and workarounds in the " { $vocab-link "elevate" } " elevated privileges API. This article explains and documents them for the curious, future maintainers, or those who run into problems."
    { $heading "macOS" }
    "On Apple macOS, an Applescript command is attempted for a graphical method before " { $snippet "sudo" } ". Sometimes, this command appears to execute incorrectly due to the group of the user owning the calling process. On macOS, " { $snippet "sudo" } " suffers the drawback mentioned below for applications which do not have a TTY connected."
    { $heading "Linux, *BSD and other Unix-likes" }
    "On Linux, " { $snippet "gksudo" } ", " { $snippet "kdesudo" } ", and " { $snippet "pkexec" } " are all attempted graphical methods before " { $snippet "sudo" } "."
    { $list
        { { $snippet "pkexec" } " is the preferred and most secure graphical authentication method on Linux. It is undesirable for Factor applications, because unless a certain rare global registry value is set, " { $snippet "pkexec" } " does not set the " { $snippet "$DISPLAY" } " environment variable for child processes, and thus cannot launch graphical applications despite being a graphical program itself. It is tried after " { $snippet "gksudo" } " and " { $snippet "kdesudo" } " but before " { $snippet "sudo" } "." }
        { { $snippet "gksudo" } " and " { $snippet "kdesudo" } " are deprecated, but still present on most GTK- and KDE-based systems, respectively. GTK is more widespread than KDE so " { $snippet "gksudo" } " is tried before " { $snippet "kdesudo" } ". These old-fashioned methods ensure that the launched application can be graphical, so they are preferred for Factor." }
        { { $snippet "sudo" } " is the final and most robust strategy tried on Linux. It is text-based, so it requires the calling process to have an active and accessible terminal (TTY) for user authentication. If the calling Factor application was started from the desktop graphical shell rather than from a TTY, this method will fail." }
    }
    "On other Unix-like or POSIX-like operating systems, " { $snippet "sudo" } " is the only consistently popular method of authentication, and it suffers the same drawback on other Unix-likes as on Linux." 
    { $heading "Windows" }
    { "On Windows, the FFI word " { $resolve? "windows.shell32" "ShellExecuteW" } " is used with the verb " { $snippet "runas" } " to force the new process to run with User Account Control. Windows provides no " { $snippet "exec" } " equivalent to replace a running process' image, so a new process will always be spawned, optionally killing the original Factor process." }
;

HELP: elevated
{ $values { "command" { $or array string } } { "replace?" boolean } { "win-console?" boolean } { "posix-graphical?" boolean } { "process" process } }
{ $description
    "Spawn a process from the command " { $slot "command" } " with superuser (administrator) privileges. If the calling process does not already have superuser privileges, it will request them by a number of platform-specific methods."
    $nl
    "If " { $slot "replace?" } " is " { $link t } ", the calling Factor process will be replaced with the command (but see Notes)."
    $nl
    { $link windows } ": if " { $slot "win-console?" } " is " { $link t } ", a new console window will " { $emphasis "always" } " be spawned for the resulting process, regardless of " { $slot "replace?" } "."
    $nl
    { $link unix } ": if " { $slot "posix-graphical?" } " is " { $link t } ", a graphical password method will be attempted before " { $snippet "sudo" } "."
    $nl
    "If the calling process is already run as superuser, nothing happens. The input command is left on the stack, placed into a " { $link process } " inside an " { $link array } "."
}
{ $notes
    { $list
        { "On " { $link windows } ", " { $slot "replace?" } " has the effect of ending (with " { $link exit } ") the calling Factor process after spawning the command because Windows provides no way to replace a running process' image, like " { $snippet "exec" } " does in POSIX." }
        { "On POSIX (" { $link unix } "), " { $slot "replace?" } " does not cause a graceful shutdown of the calling Factor VM or thread. Instead, the " { $emphasis "entire" } " executable program image will be immediately replaced in memory by the new command prefixed by a privilege elevation strategy. For more information, see " { $resolve? "unix.process" "exec-with-path" } " and the Unix " { $snippet "man" } " page for " { $resolve? "unix.process" "execvp" } " (" { $resolve? "unix.process" "exec" } ") in section 3." }
        { { $link "elevate.bugs" } " details problems and pitfalls of this word." }
    }
}
{ $errors
    { $link elevated-failed } " when all strategies fail."
    $nl
    "When " { $slot "replace?" } " is " { $link t } ":any errors thrown by " { $link run-process } "."
} ;

HELP: elevate
{ $values { "win-console?" boolean } { "posix-graphical?" boolean } }
{ $description "Relaunch the current Factor process with superuser privileges. See " { $link elevated } " for an explanation, as the semantics are identical." } ;

HELP: lowered
{ $description "Give up all superuser rights, returning the calling Factor process to normal userspace." }
{ $notes
    { $list 
        { "On " { $link windows } " this word is a no-op, because there Windows provides no " { $snippet "setuid" } " equivalent to change the access token of a running process. It does not throw an error, so that it may be used in cross-platform code." }  
        { "If the process is running as \"real superuser\", (not an impersonation), nothing happens." $nl "If the process is running as an unprivileged user, nothing happens." }
    } 
}
{ $errors { $link lowered-failed } " when giving up superuser rights failed." } ;

HELP: already-root? 
{ $values { "?" boolean } }
{ $description "Determine whether the current Factor process (on " { $link unix } ") or hardware thread {on " { $link windows } ") has administrator or elevated (root) privileges." } ; 
HELP: lowered-failed 
{ $error-description "Thrown by " { $link lowered } " when giving up elevated privileges resulted in an error or failure by the operating system." } ;
HELP: elevated-failed 
{ $error-description "Thrown by " { $link elevated } " when all strategies to elevating privileges failed. See " { $link elevated } "." } ;

