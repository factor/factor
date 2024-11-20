! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs help.markup help.syntax io.streams.string kernel
libc sequences strings ;
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
    { $unchecked-example
        "USING: environment io ;"
        "\"USER\" os-env print"
        "jane"
    }
} ;

HELP: os-env?
{ $values { "key" string } { "?" boolean } }
{ $description "Returns " { $link t } " if the environment variable is set to a non-empty value." } ;

HELP: change-os-env
{ $values { "key" string } { "quot" { $quotation ( old -- new ) } } }
{ $description "Applies a quotation to change the value stored in an environment variable." }
{ $examples
    "This is an operating system-specific feature. On Unix, you can do:"
    { $unchecked-example
        "USING: environment io ;"
        "\"USER\" os-env print"
        "\"USER\" [ \"-doe\" append ] change-os-env"
        "\"USER\" os-env print"
        "jane\njane-doe"
    }
}
{ $side-effects "key" } ;

HELP: os-envs
{ $values { "assoc" "an association mapping strings to strings" } }
{ $description "Outputs the current set of environment variables." }
{ $notes
    "Names and values of environment variables are operating system-specific."
} ;

HELP: set-os-envs
{ $values { "assoc" "an association mapping strings to strings" } }
{ $description "Replaces the current set of environment variables." }
{ $warning "Leaks memory on Unix. If your program calls this function repeatedly, call " { $link set-os-envs-pointer } " with a malloced pointer and manage your memory instead." }
{ $notes
    "Names and values of environment variables are operating system-specific. Windows NT allows values up to 32766 characters in length."
} ;

HELP: set-os-envs-pointer
{ $values { "malloc" "a pointer to memory from the heap obtained through " { $link malloc } " or similar" } }
{ $description "Set then " { $snippet "environ" } " pointer. Factor must retain a pointer to this memory until exiting the program." }
{ $notes
    "Names and values of environment variables are operating system-specific."
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

HELP: with-os-env
{ $values { "value" string } { "key" string } { "quot" "quotation" } }
{ $description "Calls a quotation with the " { $snippet "key" } " environment variable set to " { $snippet "value" } ", resetting the environment variable afterwards to its previous value." } ;

{ os-env os-envs set-os-env unset-os-env set-os-envs set-os-envs-pointer change-os-env with-os-env } related-words


ARTICLE: "environment" "Environment variables"
"The " { $vocab-link "environment" } " vocabulary interfaces to the platform-dependent mechanism for setting environment variables." $nl
"Reading environment variables:"
{ $subsections
    os-env
    os-envs
}
"Writing environment variables:"
{ $subsections
    set-os-env
    unset-os-env
    set-os-envs
    change-os-env
}
"Leak-free setting of all environment variables on Unix:"
{ $subsections
    set-os-envs-pointer

} ;

ABOUT: "environment"
