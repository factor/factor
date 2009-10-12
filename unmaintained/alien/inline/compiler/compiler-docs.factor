! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel strings words.symbol sequences ;
IN: alien.inline.compiler

HELP: C
{ $var-description "A symbol representing C source." } ;

HELP: C++
{ $var-description "A symbol representing C++ source." } ;

HELP: compile-to-library
{ $values
    { "lang" symbol } { "args" sequence } { "contents" string } { "name" string }
}
{ $description "Compiles and links " { $snippet "contents" } " into a shared library called " { $snippet "libname.suffix" }
  "in " { $snippet "resource:alien-inline-libs" } ". " { $snippet "suffix" } " is OS specific. "
  { $snippet "args" } " is a sequence of arguments for the linking stage." }
{ $notes
  { $list
    "C and C++ are the only supported languages."
    { "Source and object files are placed in " { $snippet "resource:temp" } "." } }
} ;

HELP: compiler
{ $values
    { "lang" symbol }
    { "str" string }
}
{ $description "Returns a compiler name based on OS and source language." }
{ $see-also compiler-descr } ;

HELP: compiler-descr
{ $values
    { "lang" symbol }
    { "descr" "a process description" }
}
{ $description "Returns a compiler process description based on OS and source language." }
{ $see-also compiler } ;

HELP: inline-library-file
{ $values
    { "name" string }
    { "path" "a pathname string" }
}
{ $description "Appends " { $snippet "name" } " to the " { $link inline-libs-directory } "." } ;

HELP: inline-libs-directory
{ $values
    { "path" "a pathname string" }
}
{ $description "The directory where libraries created using " { $snippet "alien.inline" } " are stored." } ;

HELP: library-path
{ $values
    { "str" string }
    { "path" "a pathname string" }
}
{ $description "Converts " { $snippet "name" } " into a full path to the corresponding inline library." } ;

HELP: library-suffix
{ $values
    { "str" string }
}
{ $description "The appropriate shared library suffix for the current OS." } ;

HELP: link-descr
{ $values
    { "lang" "a language" }
    { "descr" sequence }
}
{ $description "Returns part of a process description. OS dependent." } ;

ARTICLE: "alien.inline.compiler" "Inline C compiler"
{ $vocab-link "alien.inline.compiler" }
;

ABOUT: "alien.inline.compiler"
