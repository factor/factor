USING: classes.singleton help.markup help.syntax init kernel math ;
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
"Getting a monotonically increasing nanosecond count:"
{ $subsections nano-count }
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
    linux
    macosx
    windows
}
"Operating system families:"
{ $subsections
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
{ $values { "?" boolean } }
{ $description "Tests if this Factor instance is embedded in another application." } ;

HELP: exit
{ $values { "n" "an integer exit code" } }
{ $description "Runs all " { $link shutdown-hooks } " and then exits the Factor process. If an error occurs when the shutdown hooks runs, or when the process is about to terminate, the error is ignored and the process exits with status 255." } ;

HELP: nano-count
{ $values { "ns" integer } }
{ $description "Outputs a monotonically increasing count of nanoseconds elapsed since an arbitrary starting time. The difference of two calls to this word allows timing. This word is unaffected by system clock changes." }
{ $notes "This is a low-level word. The " { $vocab-link "tools.time" } " vocabulary defines words to time code execution time." } ;

HELP: image
{ $values { "path" "a pathname string" } }
{ $description "Outputs the pathname of the currently running Factor image." } ;

HELP: vm
{ $values { "path" "a pathname string" } }
{ $description "Outputs the pathname of the currently running Factor VM." } ;
