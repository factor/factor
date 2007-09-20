USING: generic help.markup help.syntax kernel math memory
namespaces sequences kernel.private io.files ;
IN: system

ARTICLE: "os" "System interface"
"Operating system detection:"
{ $subsection os }
{ $subsection unix? }
{ $subsection macosx? }
{ $subsection solaris? }
{ $subsection windows? }
{ $subsection winnt? }
{ $subsection win32? }
{ $subsection win64? }
{ $subsection wince? }
"Processor detection:"
{ $subsection cpu }
"Processor cell size:"
{ $subsection cell }
{ $subsection cells }
{ $subsection cell-bits }
"Reading environment variables:"
{ $subsection os-env }
"Getting the path to the Factor VM and image:"
{ $subsection vm }
{ $subsection image }
"Exiting the Factor VM:"
{ $subsection exit } ;

ABOUT: "os"

HELP: cpu
{ $values { "cpu" "a string" } }
{ $description
    "Outputs a string descriptor of the current CPU architecture. Currently, this set of descriptors is:"
    { $code "x86.32" "x86.64" "ppc" "arm" }
} ;

HELP: os
{ $values { "os" "a string" } }
{ $description
    "Outputs a string descriptor of the current operating system family. Currently, this set of descriptors is:"
    { $code
        "freebsd"
        "linux"
        "macosx"
        "openbsd"
        "solaris"
        "windows"
    }
} ;

HELP: embedded?
{ $values { "?" "a boolean" } }
{ $description "Tests if this Factor instance is embedded in another application." } ;

HELP: windows?
{ $values { "?" "a boolean" } }
{ $description "Tests if Factor is running on Windows." } ;

HELP: winnt?
{ $values { "?" "a boolean" } }
{ $description "Tests if Factor is running on Windows XP or Vista." } ;

HELP: wince?
{ $values { "?" "a boolean" } }
{ $description "Tests if Factor is running on Windows CE." } ;

HELP: macosx?
{ $values { "?" "a boolean" } }
{ $description "Tests if Factor is running on Mac OS X." } ;

HELP: linux?
{ $values { "?" "a boolean" } }
{ $description "Tests if Factor is running on Linux." } ;

HELP: solaris?
{ $values { "?" "a boolean" } }
{ $description "Tests if Factor is running on Solaris." } ;

HELP: bsd?
{ $values { "?" "a boolean" } }
{ $description "Tests if Factor is running on FreeBSD/OpenBSD/NetBSD." } ;

HELP: exit ( n -- )
{ $values { "n" "an integer exit code" } }
{ $description "Exits the Factor process." } ;

HELP: millis ( -- n )
{ $values { "n" "an integer" } }
{ $description "Outputs the number of milliseconds ellapsed since midnight January 1, 1970." } ;

HELP: os-env ( key -- value )
{ $values { "key" "a string" } { "value" "a string" } }
{ $description "Looks up the value of a shell environment variable." }
{ $examples 
    "This is an operating system-specific feature. On Unix, you can do:"
    { $unchecked-example "\"USER\" os-env print" "jane" }
}
{ $errors "Windows CE has no concept of ``environment variables'', so this word throws an error there." } ;

HELP: win32?
{ $values { "?" "a boolean" } }
{ $description "Tests if Factor is running on 32-bit Windows." } ;

HELP: win64?
{ $values { "?" "a boolean" } }
{ $description "Tests if Factor is running on 64-bit Windows." } ;

HELP: image
{ $values { "path" "a pathname string" } }
{ $description "Outputs the pathname of the currently running Factor image." } ;

HELP: vm
{ $values { "path" "a pathname string" } }
{ $description "Outputs the pathname of the currently running Factor VM." } ;

HELP: unix?
{ $values { "?" "a boolean" } }
{ $description "Tests if Factor is running on a Unix-like system. While this is a rather vague notion, one can use it to make certain assumptions about system calls and file structure which are not valid on Windows." } ;

HELP: cell
{ $values { "n" "a positive integer" } }
{ $description "Outputs the pointer size in bytes of the current CPU architecture." } ;

HELP: cells
{ $values { "m" "an integer" } { "n" "an integer" } }
{ $description "Computes the number of bytes used by " { $snippet "m" } " CPU operand-sized cells." } ;

HELP: cell-bits
{ $values { "n" "an integer" } }
{ $description "Outputs the number of bits in one CPU operand-sized cell." } ;

HELP: bootstrap-cell
{ $values { "n" "a positive integer" } }
{ $description "Outputs the pointer size in bytes for the target image (if bootstrapping) or the current CPU architecture (otherwise)." } ;

HELP: bootstrap-cells
{ $values { "m" "an integer" } { "n" "an integer" } }
{ $description "Computes the number of bytes used by " { $snippet "m" } " cells in the target image (if bootstrapping) or the current CPU architecture (otherwise)." } ;

HELP: bootstrap-cell-bits
{ $values { "n" "an integer" } }
{ $description "Outputs the number of bits in one cell in the target image (if bootstrapping) or the current CPU architecture (otherwise)." } ;
