! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.syntax assocs help.markup
help.syntax io.backend kernel namespaces ;
IN: alien.libraries

HELP: <library>
{ $values
     { "path" "a pathname string" } { "abi" "the ABI used by the library, either " { $snippet "cdecl" } " or " { $snippet "stdcall" } }
     { "library" library } }
{ $description "Opens a C library using the path and ABI parameters and outputs a library tuple." }
{ $notes "User code should use " { $link add-library } " so that the opened library is added to a global hashtable, " { $link libraries } "." } ;

HELP: libraries
{ $description "A global hashtable that keeps a list of open libraries. Use the " { $link add-library } " word to construct a library and add it with a single call." } ;

HELP: library
{ $values { "name" "a string" } { "library" "a hashtable" } }
{ $description "Looks up a library by its logical name. The library object is a hashtable with the following keys:"
    { $list
        { { $snippet "name" } " - the full path of the C library binary" }
        { { $snippet "abi" } " - the ABI used by the library, either " { $snippet "cdecl" } " or " { $snippet "stdcall" } }
        { { $snippet "dll" } " - an instance of the " { $link dll } " class; only set if the library is loaded" }
    }
} ;

HELP: dlopen ( path -- dll )
{ $values { "path" "a pathname string" } { "dll" "a DLL handle" } }
{ $description "Opens a native library and outputs a handle which may be passed to " { $link dlsym } " or " { $link dlclose } "." }
{ $errors "Throws an error if the library could not be found, or if loading fails for some other reason." }
{ $notes "This is the low-level facility used to implement " { $link load-library } ". Use the latter instead." } ;

HELP: dlsym ( name dll -- alien )
{ $values { "name" "a C symbol name" } { "dll" "a DLL handle" } { "alien" "an alien pointer" } }
{ $description "Looks up a symbol in a native library. If " { $snippet "dll" } " is " { $link f } " looks for the symbol in the runtime executable." }
{ $errors "Throws an error if the symbol could not be found." } ;

HELP: dlclose ( dll -- )
{ $values { "dll" "a DLL handle" } }
{ $description "Closes a DLL handle created by " { $link dlopen } ". This word might not be implemented on all platforms." } ;

HELP: load-library
{ $values { "name" "a string" } { "dll" "a DLL handle" } }
{ $description "Loads a library by logical name and outputs a handle which may be passed to " { $link dlsym } " or " { $link dlclose } ". If the library is already loaded, returns the existing handle." } ;

HELP: add-library
{ $values { "name" "a string" } { "path" "a string" } { "abi" "one of " { $snippet "\"cdecl\"" } " or " { $snippet "\"stdcall\"" } } }
{ $description "Defines a new logical library named " { $snippet "name" } " located in the file system at " { $snippet "path" } "and the specified ABI." }
{ $notes "Because the entire source file is parsed before top-level forms are executed, " { $link add-library } " cannot be used in the same file as " { $link POSTPONE: FUNCTION: } " definitions from that library. The " { $link add-library } " call will happen too late, after compilation, and the alien calls will not work."
$nl
"Instead, " { $link add-library } " calls must either be placed in different source files from those that use that library, or alternatively, " { $link "syntax-immediate" } " can be used to load the library before compilation." }
{ $examples "Here is a typical usage of " { $link add-library } ":"
{ $code
    "<< \"freetype\" {"
    "    { [ os macosx? ] [ \"libfreetype.6.dylib\" \"cdecl\" add-library ] }"
    "    { [ os windows? ] [ \"freetype6.dll\" \"cdecl\" add-library ] }"
    "    [ drop ]"
    "} cond >>"
}
"Note the parse time evaluation with " { $link POSTPONE: << } "." } ;

ARTICLE: "loading-libs" "Loading native libraries"
"Before calling a C library, you must associate its path name on disk with a logical name which Factor uses to identify the library:"
{ $subsection add-library }
"Once a library has been defined, you can try loading it to see if the path name is correct:"
{ $subsection load-library }
"If the compiler cannot load a library, or cannot resolve a symbol in a library, a linkage error is reported using the compiler error mechanism (see " { $link "compiler-errors" } "). Once you install the right library, reload the source file containing the " { $link add-library } " form to force the compiler to try loading the library again." ;
