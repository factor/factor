USING: generic help.markup help.syntax kernel math memory
namespaces sequences kernel.private strings ;
IN: system

ARTICLE: "os" "System interface"
"Operating system detection:"
{ $subsection os }
"Processor detection:"
{ $subsection cpu }
"Reading environment variables:"
{ $subsection os-env }
{ $subsection os-envs }
"Getting the path to the Factor VM and image:"
{ $subsection vm }
{ $subsection image }
"Getting the current time:"
{ $subsection millis }
"Exiting the Factor VM:"
{ $subsection exit }
{ $see-also "io.files" "io.mmap" "io.monitors" "network-streams" "io.launcher" } ;

ABOUT: "os"

HELP: cpu
{ $values { "cpu" string } }
{ $description
    "Outputs a singleton class with the name of the current CPU architecture. Currently, this set of descriptors is:"
    { $code x86.32 x86.64 ppc arm }
} ;

HELP: os
{ $values { "os" string } }
{ $description
    "Outputs a singleton class with the name of the current operating system family. Currently, this set of descriptors is:"
    { $code
        freebsd
        linux
        macosx
        openbsd
        netbsd
        solaris
        wince
        winnt
    }
} ;

HELP: embedded?
{ $values { "?" "a boolean" } }
{ $description "Tests if this Factor instance is embedded in another application." } ;

HELP: exit ( n -- )
{ $values { "n" "an integer exit code" } }
{ $description "Exits the Factor process." } ;

HELP: millis ( -- n )
{ $values { "n" integer } }
{ $description "Outputs the number of milliseconds ellapsed since midnight January 1, 1970." }
{ $notes "This is a low-level word. The " { $vocab-link "calendar" } " vocabulary provides features for date/time arithmetic and formatting." } ;

HELP: os-env ( key -- value )
{ $values { "key" string } { "value" string } }
{ $description "Looks up the value of a shell environment variable." }
{ $examples 
    "This is an operating system-specific feature. On Unix, you can do:"
    { $unchecked-example "\"USER\" os-env print" "jane" }
}
{ $errors "Windows CE has no concept of environment variables, so this word throws an error there." } ;

HELP: os-envs
{ $values { "assoc" "an association mapping strings to strings" } }
{ $description "Outputs the current set of environment variables." }
{ $notes 
    "Names and values of environment variables are operating system-specific."
}
{ $errors "Windows CE has no concept of environment variables, so this word throws an error there." } ;

HELP: set-os-envs
{ $values { "assoc" "an association mapping strings to strings" } }
{ $description "Replaces the current set of environment variables." }
{ $notes
    "Names and values of environment variables are operating system-specific."
}
{ $errors "Windows CE has no concept of environment variables, so this word throws an error there." } ;

{ os-env os-envs set-os-envs } related-words

HELP: image
{ $values { "path" "a pathname string" } }
{ $description "Outputs the pathname of the currently running Factor image." } ;

HELP: vm
{ $values { "path" "a pathname string" } }
{ $description "Outputs the pathname of the currently running Factor VM." } ;
