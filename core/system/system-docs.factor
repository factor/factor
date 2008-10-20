USING: generic help.markup help.syntax kernel math memory
namespaces sequences kernel.private strings classes.singleton ;
IN: system

ABOUT: "system"

ARTICLE: "system" "System interface"
{ $subsection "cpu" }
{ $subsection "os" }
"Getting the path to the Factor VM and image:"
{ $subsection vm }
{ $subsection image }
"Getting the current time:"
{ $subsection millis }
"Exiting the Factor VM:"
{ $subsection exit } ;

ARTICLE: "cpu" "Processor detection"
"Processor detection:"
{ $subsection cpu }
"Supported processors:"
{ $subsection x86.32 }
{ $subsection x86.64 }
{ $subsection ppc }
{ $subsection arm }
"Processor families:"
{ $subsection x86 } ;

ARTICLE: "os" "Operating system detection"
"Operating system detection:"
{ $subsection os }
"Supported operating systems:"
{ $subsection freebsd }
{ $subsection linux }
{ $subsection macosx }
{ $subsection openbsd }
{ $subsection netbsd }
{ $subsection solaris }
{ $subsection wince }
{ $subsection winnt }
"Operating system families:"
{ $subsection bsd }
{ $subsection unix }
{ $subsection windows } ;


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

HELP: millis ( -- n )
{ $values { "n" integer } }
{ $description "Outputs the number of milliseconds ellapsed since midnight January 1, 1970." }
{ $notes "This is a low-level word. The " { $vocab-link "calendar" } " vocabulary provides features for date/time arithmetic and formatting." } ;

HELP: image
{ $values { "path" "a pathname string" } }
{ $description "Outputs the pathname of the currently running Factor image." } ;

HELP: vm
{ $values { "path" "a pathname string" } }
{ $description "Outputs the pathname of the currently running Factor VM." } ;
