USING: classes.singleton help.markup help.syntax init kernel math ;
IN: system

ABOUT: "system"

ARTICLE: "system" "System interface"
{ $subsections
    "cpu"
    "os"
    "ctrl-break"
}
"Getting the path to the Factor VM and image:"
{ $subsections
    vm-path
    image-path
}
"Getting a monotonically increasing nanosecond count:"
{ $subsections nano-count }
"Exiting the Factor VM:"
{ $subsections exit quit } ;

ARTICLE: "cpu" "Processor detection"
"Processor detection:"
{ $subsections cpu }
"Supported processors:"
{ $subsections
    x86.32
    x86.64
    ppc
    arm
}
"Processor families:"
{ $subsections x86 } ;

ARTICLE: "os" "Operating system detection"
"Operating system detection:"
{ $subsections os }
"Supported operating systems:"
{ $subsections
    linux
    macosx
    windows
}
"Operating system families:"
{ $subsections
    unix
    windows
} ;

ARTICLE: "ctrl-break" "Ctrl-Break handler"
"There is one global handler available per Factor VM, disabled by default. When enabled, it starts a separate native thread and polls the keyboard for the Ctrl-Break combination. If user presses Ctrl-Break with one of the Factor windows active, the handler causes an exception to be thrown in the main thread, which allows user to interrupt a VM stuck in a busy loop."
$nl
"Due to specific implementation requirements, this facility is only available on Windows platforms. Namely, it needs the ability to poll the keyboard state while the input focus belongs to another thread."
$nl
"While the handler is active, it can interrupt any code in Factor VM, including sensitive or low-level functions. If this happens, chances are VM won't be able to recover. To prevent crashes, only enable the handler while user code is running in the foreground. Don't enable it in the background threads before yielding, don't have it enabled while GC is working, etc. Always make sure you can catch the exception it would produce."
$nl
"The listener can activate the Ctrl-Break handler while it's compiling and running user code interactively, so that user could interrupt an infinite loop. To allow the listener use this facility, add the following code to your " { $link ".factor-rc" } ":"
{ $code
    "USING: listener namespaces ;"
    "t handle-ctrl-break set-global"
}
$nl
"Managing the Ctrl-Break handler:"
{ $subsections enable-ctrl-break disable-ctrl-break } ;

HELP: cpu
{ $values { "class" singleton-class } }
{ $description
    "Outputs a singleton class with the name of the current CPU architecture."
} ;

HELP: os
{ $values { "class" singleton-class } }
{ $description
    "Outputs a singleton class with the name of the current operating system family."
} ;

HELP: embedded?
{ $values { "?" boolean } }
{ $description "Tests if this Factor instance is embedded in another application." } ;

HELP: exit
{ $values { "n" "an integer exit code" } }
{ $description "Runs all " { $link shutdown-hooks } " and then exits the Factor process. If an error occurs when the shutdown hooks runs, or when the process is about to terminate, the error is ignored and the process exits with status 255." } ;

HELP: quit
{ $description "Calls " { $link exit } " with a 0 exit code." } ;

HELP: nano-count
{ $values { "ns" integer } }
{ $description "Outputs a monotonically increasing count of nanoseconds elapsed since an arbitrary starting time. The difference of two calls to this word allows timing. This word is unaffected by system clock changes." }
{ $notes "This is a low-level word. The " { $vocab-link "tools.time" } " vocabulary defines words to time code execution time." } ;

HELP: image-path
{ $values { "path" "a pathname string" } }
{ $description "Outputs the pathname of the currently running Factor image." } ;

HELP: vm-path
{ $values { "path" "a pathname string" } }
{ $description "Outputs the pathname of the currently running Factor VM." } ;

HELP: enable-ctrl-break
{ $description "Enables the global Ctrl-Break handler. There is only one handler per Factor VM. If it is enabled, additional calls to enable-ctrl-break have no effect." }
{ $see-also disable-ctrl-break } ;

HELP: disable-ctrl-break
{ $description "Disables the global Ctrl-Break handler. There is one handler per Factor VM. If it is disabled, additional calls to disable-ctrl-break have no effect." }
{ $see-also enable-ctrl-break } ;
