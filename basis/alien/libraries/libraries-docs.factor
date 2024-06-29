! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.syntax assocs help.markup help.syntax kernel
strings ;
IN: alien.libraries

HELP: add-library
{ $values { "name" string } { "path" string } { "abi" "one of " { $link cdecl } " or " { $link stdcall } } }
{ $description "Defines a new logical library named " { $snippet "name" } " located in the file system at " { $snippet "path" } " and the specified ABI. You can find the location of the library via words in " { $vocab-link "alien.libraries.finder" } ". The logical library name can then be used by a " { $link POSTPONE: LIBRARY: } " form to specify the logical library for subsequent " { $link POSTPONE: FUNCTION: } " definitions." }
{ $notes "Because the entire source file is parsed before top-level forms are executed, " { $link add-library } " must be placed within a " { $snippet "<< ... >>" } " parse-time evaluation block."
$nl
"This ensures that if the logical library is later used in the same file, for example by a " { $link POSTPONE: FUNCTION: } " definition. Otherwise, the " { $link add-library } " call will happen too late, after compilation, and the C function calls will not refer to the correct library."
$nl
"For details about parse-time evaluation, see " { $link "syntax-immediate" } "." }
{ $examples "Here is a typical usage of " { $link add-library } ":"
{ $code
    "<< \"sqlite\" \"sqlite3\" find-library cdecl add-library >>"
}
"You can also explicitly specify the library name by platform, if you prefer:"
{ $code
    "<< \"freetype\" {"
    "    { [ os macos? ] [ \"libfreetype.6.dylib\" cdecl add-library ] }"
    "    { [ os windows? ] [ \"freetype6.dll\" cdecl add-library ] }"
    "    [ drop ]"
    "} cond >>"
}
"Note the parse time evaluation with " { $link POSTPONE: << } "." } ;

HELP: deploy-library
{ $values { "name" string } }
{ $description "Specifies that the logical library named " { $snippet "name" } " should be included during " { $link "tools.deploy" } ". " { $snippet "name" } " must be the name of a library previously loaded with " { $link add-library } "." } ;

HELP: dlclose
{ $values { "dll" "a DLL handle" } }
{ $description "Closes a DLL handle created by " { $link dlopen } ". This word might not be implemented on all platforms." } ;

HELP: dlopen
{ $values { "path" "a pathname string" } { "dll" "a DLL handle" } }
{ $description "Opens a native library and outputs a handle which may be passed to " { $link dlsym } " or " { $link dlclose } "." }
{ $errors "Throws an error if the library could not be found, or if loading fails for some other reason." }
{ $notes "This is the low-level facility used to implement " { $link add-library } ". Use the latter instead." } ;

HELP: dlsym
{ $values { "name" "a C symbol name" } { "dll" "a DLL handle" } { "alien" { $maybe alien } } }
{ $description "Looks up a symbol in a native library. If " { $snippet "dll" } " is " { $link f } " looks for the symbol in the runtime executable. If the symbol was not found, outputs " { $link f } "." } ;

HELP: dlsym?
{ $values
  { "function" string }
  { "library" string }
  { "alien/f" { $maybe alien } }
}
{ $description "Outputs the alien dynamically loaded with the given name in the given library. If no symbol is loaded, output f." } ;

HELP: make-library
{ $values
    { "path" "a pathname string" } { "abi" "the ABI used by the library, either " { $link cdecl } " or " { $link stdcall } }
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
        { { $snippet "abi" } " - the ABI used by the library, either " { $link cdecl } " or " { $link stdcall } }
        { { $snippet "dll" } " - an instance of the " { $link dll } " class; only set if the library is loaded" }
    }
} ;

HELP: library-dll
{ $values { "obj" object } { "dll" "a DLL handle" } }
{ $description "Looks up a library by logical name and outputs a handle which may be passed to " { $link dlsym } " or " { $link dlclose } "." } ;

HELP: remove-library
{ $values { "name" string } }
{ $description "Unloads a library and removes it from the internal list of libraries. The " { $snippet "name" } " parameter should be a name that was previously passed to " { $link add-library } ". If no library with that name exists, this word does nothing." } ;

ARTICLE: "loading-libs" "Loading native libraries"
"Before calling a C library, you must associate its path name on disk with a logical name which Factor uses to identify the library:"
{ $subsections
    add-library
    remove-library
}
"Once a library has been defined, you can see if the library has correctly loaded:"
{ $subsections library-dll }
"If the compiler cannot load a library, or cannot resolve a symbol in a library, a linkage error is reported using the compiler error mechanism (see " { $link "compiler-errors" } "). Once you install the right library, reload the source file containing the " { $link add-library } " form to force the compiler to try loading the library again."
$nl
"Libraries that do not come standard with the operating system need to be included with deployed applications that use them. A word is provided to instruct " { $link "tools.deploy" } " that a library must be so deployed:"
{ $subsections
    deploy-library
} ;
