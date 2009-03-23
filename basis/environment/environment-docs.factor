! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs help.markup help.syntax io.streams.string sequences strings ;
IN: environment

HELP: (os-envs)
{ $values
    
     { "seq" sequence } }
{ $description "Returns a sequence of key/value pairs from the operating system." }
{ $notes "In most cases, use " { $link os-envs } " instead." } ;

HELP: (set-os-envs)
{ $values
     { "seq" sequence } }
{ $description "Low-level word for replacing the current set of environment variables." }
{ $notes "In most cases, use " { $link set-os-envs } " instead." } ;


HELP: os-env
{ $values { "key" string } { "value" string } }
{ $description "Looks up the value of a shell environment variable." }
{ $examples
    "This is an operating system-specific feature. On Unix, you can do:"
    { $unchecked-example "\"USER\" os-env print" "jane" }
} ;

HELP: os-envs
{ $values { "assoc" "an association mapping strings to strings" } }
{ $description "Outputs the current set of environment variables." }
{ $notes
    "Names and values of environment variables are operating system-specific."
} ;

HELP: set-os-envs
{ $values { "assoc" "an association mapping strings to strings" } }
{ $description "Replaces the current set of environment variables." }
{ $notes
    "Names and values of environment variables are operating system-specific. Windows NT allows values up to 32766 characters in length."
} ;

HELP: set-os-env
{ $values { "value" string } { "key" string } }
{ $description "Set an environment variable." }
{ $notes
    "Names and values of environment variables are operating system-specific."
} ;

HELP: unset-os-env
{ $values { "key" string } }
{ $description "Unset an environment variable." }
{ $notes
    "Names and values of environment variables are operating system-specific."
} ;

{ os-env os-envs set-os-env unset-os-env set-os-envs } related-words


ARTICLE: "environment" "Environment variables"
"The " { $vocab-link "environment" } " vocabulary interfaces to the platform-dependent mechanism for setting environment variables." $nl
"Windows CE has no concept of environment variables, so these words are undefined on that platform." $nl
"Reading environment variables:"
{ $subsection os-env }
{ $subsection os-envs }
"Writing environment variables:"
{ $subsection set-os-env }
{ $subsection unset-os-env }
{ $subsection set-os-envs } ;

ABOUT: "environment"
