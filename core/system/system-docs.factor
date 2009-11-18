USING: generic help.markup help.syntax kernel math memory
namespaces sequences kernel.private strings classes.singleton ;
IN: system

ABOUT: "system"

ARTICLE: "system" "System interface"
{ $subsections
    "cpu"
    "os"
}
"Getting the path to the Factor VM and image:"
{ $subsections
    vm
    image
}
"Getting the current time:"
{ $subsections
    system-micros
    system-micros
}
"Exiting the Factor VM:"
{ $subsections exit } ;

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
    freebsd
    linux
    macosx
    openbsd
    netbsd
    solaris
    wince
    winnt
}
"Operating system families:"
{ $subsections
    bsd
    unix
    windows
} ;


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
{ $values { "?" "a boolean" } }
{ $description "Tests if this Factor instance is embedded in another application." } ;

HELP: exit ( n -- )
{ $values { "n" "an integer exit code" } }
{ $description "Exits the Factor process." } ;

HELP: system-micros ( -- us )
{ $values { "us" integer } }
{ $description "Outputs the number of microseconds ellapsed since midnight January 1, 1970." }
{ $notes "This is a low-level word. The " { $vocab-link "calendar" } " vocabulary provides features for date/time arithmetic and formatting." } ;

HELP: system-millis ( -- ms )
{ $values { "ms" integer } }
{ $description "Outputs the number of milliseconds ellapsed since midnight January 1, 1970." }
{ $notes "This is a low-level word. The " { $vocab-link "calendar" } " vocabulary provides features for date/time arithmetic and formatting." } ;

HELP: image
{ $values { "path" "a pathname string" } }
{ $description "Outputs the pathname of the currently running Factor image." } ;

HELP: vm
{ $values { "path" "a pathname string" } }
{ $description "Outputs the pathname of the currently running Factor VM." } ;
