! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.syntax assocs help.markup
help.syntax io.backend kernel namespaces strings ;
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
{ $values { "name" string } { "library" assoc } }
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
{ $values { "name" "a C symbol name" } { "dll" "a DLL handle" } { "alien" { $maybe alien } } }
{ $description "Looks up a symbol in a native library. If " { $snippet "dll" } " is " { $link f } " looks for the symbol in the runtime executable. If the symbol was not found, outputs " { $link f } "." } ;

HELP: dlclose ( dll -- )
{ $values { "dll" "a DLL handle" } }
{ $description "Closes a DLL handle created by " { $link dlopen } ". This word might not be implemented on all platforms." } ;

HELP: load-library
{ $values { "name" string } { "dll" "a DLL handle" } }
{ $description "Loads a library by logical name and outputs a handle which may be passed to " { $link dlsym } " or " { $link dlclose } ". If the library is already loaded, returns the existing handle." } ;

HELP: add-library
{ $values { "name" string } { "path" string } { "abi" "one of " { $snippet "\"cdecl\"" } " or " { $snippet "\"stdcall\"" } } }
{ $description "Defines a new logical library named " { $snippet "name" } " located in the file system at " { $snippet "path" } " and the specified ABI. The logical library name can then be used by a " { $link POSTPONE: LIBRARY: } " form to specify the logical library for subsequent " { $link POSTPONE: FUNCTION: } " definitions." }
{ $notes "Because the entire source file is parsed before top-level forms are executed, " { $link add-library } " must be placed within a " { $snippet "<< ... >>" } " parse-time evaluation block."
$nl
"This ensures that if the logical library is later used in the same file, for example by a " { $link POSTPONE: FUNCTION: } " definition. Otherwise, the " { $link add-library } " call will happen too late, after compilation, and the C function calls will not refer to the correct library."
$nl
"For details about parse-time evaluation, see " { $link "syntax-immediate" } "." }
{ $examples "Here is a typical usage of " { $link add-library } ":"
{ $code
    "<< \"freetype\" {"
    "    { [ os macosx? ] [ \"libfreetype.6.dylib\" \"cdecl\" add-library ] }"
    "    { [ os windows? ] [ \"freetype6.dll\" \"cdecl\" add-library ] }"
    "    [ drop ]"
    "} cond >>"
}
"Note the parse time evaluation with " { $link POSTPONE: << } "." } ;

HELP: remove-library
{ $values { "name" string } }
{ $description "Unloads a library and removes it from the internal list of libraries. The " { $snippet "name" } " parameter should be a name that was previously passed to " { $link add-library } ". If no library with that name exists, this word does nothing." } ;

ARTICLE: "loading-libs" "Loading native libraries"
"Before calling a C library, you must associate its path name on disk with a logical name which Factor uses to identify the library:"
{ $subsections
    add-library
    remove-library
}
"Once a library has been defined, you can try loading it to see if the path name is correct:"
{ $subsections load-library }
"If the compiler cannot load a library, or cannot resolve a symbol in a library, a linkage error is reported using the compiler error mechanism (see " { $link "compiler-errors" } "). Once you install the right library, reload the source file containing the " { $link add-library } " form to force the compiler to try loading the library again." ;
