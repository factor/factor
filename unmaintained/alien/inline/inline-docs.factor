! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel strings effects quotations ;
IN: alien.inline

<PRIVATE
: $binding-note ( x -- )
    drop
    { "This word requires that certain variables are correctly bound. "
        "Call " { $link POSTPONE: define-c-library } " to set them up." } print-element ;
PRIVATE>

HELP: compile-c-library
{ $description "Writes, compiles, and links code generated since last invocation of " { $link POSTPONE: define-c-library } ". "
  "Also calls " { $snippet "add-library" } ". "
  "This word does nothing if the shared library is younger than the factor source file." }
{ $notes $binding-note } ;

HELP: c-use-framework
{ $values
    { "str" string }
}
{ $description "OS X only. Adds " { $snippet "-framework name" } " to linker command." }
{ $notes $binding-note }
{ $see-also c-link-to c-link-to/use-framework } ;

HELP: define-c-function
{ $values
    { "function" "function name" } { "types" "a sequence of C types" } { "effect" effect } { "body" string }
}
{ $description "Defines a C function and a factor word which calls it." }
{ $notes
  { $list
    { "The number of " { $snippet "types" } " must match the " { $snippet "in" } " count of the " { $snippet "effect" } "." }
    { "There must be only one " { $snippet "out" } " element. It must be a legal C return type with dashes (-) instead of spaces." }
    $binding-note
  }
}
{ $see-also POSTPONE: define-c-function' } ;

HELP: define-c-function'
{ $values
    { "function" "function name" } { "effect" effect } { "body" string }
}
{ $description "Defines a C function and a factor word which calls it. See " { $link define-c-function } " for more information." }
{ $notes
  { $list
    { "Each effect element must be a legal C type with dashes (-) instead of spaces. "
      "C argument names will be generated alphabetically, starting with " { $snippet "a" } "." }
    $binding-note
  }
}
{ $see-also define-c-function } ;

HELP: c-include
{ $values
    { "str" string }
}
{ $description "Appends an include line to the C library in scope." }
{ $notes $binding-note } ;

HELP: define-c-library
{ $values
    { "name" string }
}
{ $description "Starts a new C library scope. Other " { $snippet "alien.inline" } " words can be used after this one." } ;

HELP: c-link-to
{ $values
    { "str" string }
}
{ $description "Adds " { $snippet "-lname" } " to linker command." }
{ $notes $binding-note }
{ $see-also c-use-framework c-link-to/use-framework } ;

HELP: c-link-to/use-framework
{ $values
    { "str" string }
}
{ $description "Equivalent to " { $link c-use-framework } " on OS X and " { $link c-link-to } " everywhere else." }
{ $notes $binding-note }
{ $see-also c-link-to c-use-framework } ;

HELP: define-c-struct
{ $values
    { "name" string } { "fields" "type/name pairs" }
}
{ $description "Defines a C struct and factor words which operate on it." }
{ $notes $binding-note } ;

HELP: define-c-typedef
{ $values
    { "old" "C type" } { "new" "C type" }
}
{ $description "Define C and factor typedefs." }
{ $notes $binding-note } ;

HELP: delete-inline-library
{ $values
    { "name" string }
}
{ $description "Delete the shared library file corresponding to " { $snippet "name" } "." }
{ $notes "Must be executed in the vocabulary where " { $snippet "name" } " is defined. " } ;

HELP: with-c-library
{ $values
    { "name" string } { "quot" quotation }
}
{ $description "Calls " { $link define-c-library } ", then the quotation, then " { $link compile-c-library } ", then sets all variables bound by " { $snippet "define-c-library" } " to " { $snippet "f" } "." } ;

HELP: raw-c
{ $values { "str" string } }
{ $description "Insert a string into the generated source file. Useful for macros and other details not implemented in " { $snippet "alien.inline" } "." } ;
