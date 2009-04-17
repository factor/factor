USING: byte-arrays arrays help.syntax help.markup
alien.syntax compiler definitions math libc eval
debugger parser io io.backend system alien.accessors
alien.libraries ;
IN: alien

HELP: alien
{ $class-description "The class of alien pointers. See " { $link "syntax-aliens" } " for syntax and " { $link "c-data" } " for general information." } ;

HELP: dll
{ $class-description "The class of native library handles. See " { $link "syntax-aliens" } " for syntax and " { $link "dll.private" } " for general information." } ;

HELP: dll-valid? ( dll -- ? )
{ $values { "dll" dll } { "?" "a boolean" } }
{ $description "Returns true if the library exists and is loaded." } ;

HELP: expired?
{ $values { "c-ptr" c-ptr } { "?" "a boolean" } }
{ $description "Tests if the alien is a relic from an earlier session. A byte array is never considered to have expired, whereas passing " { $link f } " always yields true." } ;

HELP: <bad-alien>
{ $values  { "alien" c-ptr } }
{ $description "Constructs an invalid alien pointer that has expired." } ;

HELP: <displaced-alien> ( displacement c-ptr -- alien )
{ $values { "displacement" "an integer" } { "c-ptr" c-ptr } { "alien" "a new alien" } }
{ $description "Creates a new alien address object, wrapping a raw memory address. The alien points to a location in memory which is offset by " { $snippet "displacement" } " from the address of " { $snippet "c-ptr" } "." }
{ $notes "Passing a value of " { $link f } " for " { $snippet "c-ptr" } " creates an alien with an absolute address; this is how " { $link <alien> } " is implemented."
$nl
"Passing a zero absolute address does not construct a new alien object, but instead makes the word output " { $link f } "." } ;

{ <alien> <displaced-alien> alien-address } related-words

HELP: alien-address ( c-ptr -- addr )
{ $values { "c-ptr" c-ptr } { "addr" "a non-negative integer" } }
{ $description "Outputs the address of an alien." }
{ $notes "Taking the address of a " { $link byte-array } " is explicitly prohibited since byte arrays can be moved by the garbage collector between the time the address is taken, and when it is accessed. If you need to pass pointers to C functions which will persist across alien calls, you must allocate unmanaged memory instead. See " { $link "malloc" } "." } ;

HELP: <alien>
{ $values { "address" "a non-negative integer" } { "alien" "a new alien address" } }
{ $description "Creates an alien object, wrapping a raw memory address." }
{ $notes "Alien objects are invalidated between image saves and loads." } ;

HELP: c-ptr
{ $class-description "Class of objects consisting of aliens, byte arrays and " { $link f } ". These objects can convert to pointer C types, which are all aliases of " { $snippet "void*" } "." } ;

HELP: alien-invoke
{ $values { "..." "zero or more objects passed to the C function" } { "return" "a C return type" } { "library" "a logical library name" } { "function" "a C function name" } { "parameters" "a sequence of C parameter types" } }
{ $description "Calls a C library function with the given name. Input parameters are taken from the data stack, and the return value is pushed on the data stack after the function returns. A return type of " { $snippet "\"void\"" } " indicates that no value is to be expected." }
{ $notes "C type names are documented in " { $link "c-types-specs" } "." }
{ $errors "Throws an " { $link alien-invoke-error } " if the word calling " { $link alien-invoke } " was not compiled with the optimizing compiler." } ;

HELP: alien-indirect-error
{ $error-description "Thrown if the word calling " { $link alien-indirect } " was not compiled with the optimizing compiler. This may be a result of one of several failure conditions:"
    { $list
        { "This can happen when experimenting with " { $link alien-indirect } " in this listener. To fix the problem, place the " { $link alien-indirect } " call in a word; word definitions are automatically compiled with the optimizing compiler." }
        { "The return type or parameter list references an unknown C type." }
        { "One of the three inputs to " { $link alien-indirect } " is not a literal value." }
    }
} ;

HELP: alien-indirect
{ $values { "..." "zero or more objects passed to the C function" } { "funcptr" "a C function pointer" } { "return" "a C return type" } { "parameters" "a sequence of C parameter types" } { "abi" "one of " { $snippet "\"cdecl\"" } " or " { $snippet "\"stdcall\"" } } }
{ $description
    "Invokes a C function pointer passed on the data stack. Input parameters are taken from the data stack following the function pointer, and the return value is pushed on the data stack after the function returns. A return type of " { $snippet "\"void\"" } " indicates that no value is to be expected."
}
{ $notes "C type names are documented in " { $link "c-types-specs" } "." }
{ $errors "Throws an " { $link alien-indirect-error } " if the word calling " { $link alien-indirect } " is not compiled." } ;

HELP: alien-callback-error
{ $error-description "Thrown if the word calling " { $link alien-callback } " was not compiled with the optimizing compiler. This may be a result of one of several failure conditions:"
    { $list
        { "This can happen when experimenting with " { $link alien-callback } " in this listener. To fix the problem, place the " { $link alien-callback } " call in a word; word definitions are automatically compiled with the optimizing compiler." }
        { "The return type or parameter list references an unknown C type." }
        { "One of the four inputs to " { $link alien-callback } " is not a literal value." }
    }
} ;

HELP: alien-callback
{ $values { "return" "a C return type" } { "parameters" "a sequence of C parameter types" } { "abi" "one of " { $snippet "\"cdecl\"" } " or " { $snippet "\"stdcall\"" } } { "quot" "a quotation" } { "alien" alien } }
{ $description
    "Defines a callback from C to Factor which accepts the given set of parameters from the C caller, pushes them on the data stack, calls the quotation, and passes a return value back to the C caller. A return type of " { $snippet "\"void\"" } " indicates that no value is to be returned."
    $nl
    "When a compiled reference to this word is called, it pushes the callback's alien address on the data stack. This address can be passed to any C function expecting a C function pointer with the correct signature. The callback is actually generated when the word calling " { $link alien-callback } " is compiled."
    $nl
    "Callback quotations run with freshly-allocated stacks. This means the data stack contains the values passed by the C function, and nothing else. It also means that if the callback throws an error which is not caught, the Factor runtime will halt. See " { $link "errors" } " for error handling options."
}
{ $notes "C type names are documented in " { $link "c-types-specs" } "." }
{ $examples
    "A simple example, showing a C function which returns the difference of two given integers:"
    { $code
        ": difference-callback ( -- alien )"
        "    \"int\" { \"int\" \"int\" } \"cdecl\" [ - ] alien-callback ;"
    }
}
{ $errors "Throws an " { $link alien-callback-error } " if the word calling " { $link alien-callback } " is not compiled." } ;

{ alien-invoke alien-indirect alien-callback } related-words

ARTICLE: "alien-expiry" "Alien expiry"
"When an image is loaded, any alien objects which persisted from the previous session are marked as having expired. This is because the C pointers they contain are almost certainly no longer valid."
$nl
"For this reason, the " { $link POSTPONE: ALIEN: } " word should not be used in source files, since loading the source file then saving the image will result in the literal becoming expired. Use " { $link <alien> } " instead, and ensure the word calling " { $link <alien> } " is not declared " { $link POSTPONE: flushable } "."
{ $subsection expired? } ;

ARTICLE: "aliens" "Alien addresses"
"Instances of the " { $link alien } " class represent pointers to C data outside the Factor heap:"
{ $subsection <alien> }
{ $subsection <displaced-alien> }
{ $subsection alien-address }
"Anywhere that a " { $link alien } " instance is accepted, the " { $link f } " singleton may be passed in to denote a null pointer."
$nl
"Usually alien objects do not have to created and dereferenced directly; instead declaring C function parameters and return values as having a pointer type such as " { $snippet "void*" } " takes care of the details."
{ $subsection "syntax-aliens" }
{ $subsection "alien-expiry" }
"When higher-level abstractions won't do:"
{ $subsection "reading-writing-memory" }
{ $see-also "c-data" "c-types-specs" } ;

ARTICLE: "reading-writing-memory" "Reading and writing memory directly"
"Numerical values can be read from memory addresses and converted to Factor objects using the various typed memory accessor words:"
{ $subsection alien-signed-1 }
{ $subsection alien-unsigned-1 }
{ $subsection alien-signed-2 }
{ $subsection alien-unsigned-2 }
{ $subsection alien-signed-4 }
{ $subsection alien-unsigned-4 }
{ $subsection alien-signed-cell }
{ $subsection alien-unsigned-cell }
{ $subsection alien-signed-8 }
{ $subsection alien-unsigned-8 }
{ $subsection alien-float }
{ $subsection alien-double }
"Factor numbers can also be converted to C values and stored to memory:"
{ $subsection set-alien-signed-1 }
{ $subsection set-alien-unsigned-1 }
{ $subsection set-alien-signed-2 }
{ $subsection set-alien-unsigned-2 }
{ $subsection set-alien-signed-4 }
{ $subsection set-alien-unsigned-4 }
{ $subsection set-alien-signed-cell }
{ $subsection set-alien-unsigned-cell }
{ $subsection set-alien-signed-8 }
{ $subsection set-alien-unsigned-8 }
{ $subsection set-alien-float }
{ $subsection set-alien-double } ;

ARTICLE: "alien-invoke" "Calling C from Factor"
"The easiest way to call into a C library is to define bindings using a pair of parsing words:"
{ $subsection POSTPONE: LIBRARY: }
{ $subsection POSTPONE: FUNCTION: }
"The above parsing words create word definitions which call a lower-level word; you can use it directly, too:"
{ $subsection alien-invoke }
"Sometimes it is necessary to invoke a C function pointer, rather than a named C function:"
{ $subsection alien-indirect }
"There are some details concerning the conversion of Factor objects to C values, and vice versa. See " { $link "c-data" } "." ;

HELP: alien-invoke-error
{ $error-description "Thrown if the word calling " { $link alien-invoke } " was not compiled with the optimizing compiler. This may be a result of one of several failure conditions:"
    { $list
        { "This can happen when experimenting with " { $link alien-invoke } " in this listener. To fix the problem, place the " { $link alien-invoke } " call in a word; word definitions are automatically compiled with the optimizing compiler." }
        { "The return type or parameter list references an unknown C type." }
        { "The symbol or library could not be found." }
        { "One of the four inputs to " { $link alien-invoke } " is not a literal value. To call functions which are not known at compile-time, use " { $link alien-indirect } "." }
    }
} ;

ARTICLE: "alien-callback-gc" "Callbacks and code GC"
"A callback consits of two parts; the callback word, which pushes the address of the callback on the stack when executed, and the callback body itself. If the callback word is redefined, removed from the dictionary using " { $link forget } ", or recompiled, the callback body will not be reclaimed by the garbage collector, since potentially C code may be holding a reference to the callback body."
$nl
"This is the safest approach, however it can lead to code heap leaks when repeatedly reloading code which defines callbacks. If you are " { $emphasis "completely sure" } " that no running C code is holding a reference to any callbacks, you can blow them all away:"
{ $code "USE: alien callbacks get clear-hash gc" }
"This will reclaim all callback bodies which are otherwise unreachable from the dictionary (that is, their associated callback words have since been redefined, recompiled or forgotten)." ;

ARTICLE: "alien-callback" "Calling Factor from C"
"Callbacks can be defined and passed to C code as function pointers; the C code can then invoke the callback and run Factor code:"
{ $subsection alien-callback }
"There are some caveats concerning the conversion of Factor objects to C values, and vice versa. See " { $link "c-data" } "."
{ $subsection "alien-callback-gc" }
{ $see-also "byte-arrays-gc" } ;

ARTICLE: "dll.private" "DLL handles"
"DLL handles are a built-in class of objects which represent loaded native libraries. DLL handles are instances of the " { $link dll } " class, and have a literal syntax used for debugging prinouts; see " { $link "syntax-aliens" } "."
$nl
"Usually one never has to deal with DLL handles directly; the C library interface creates them as required. However if direct access to these operating system facilities is required, the following primitives can be used:"
{ $subsection dlopen }
{ $subsection dlsym }
{ $subsection dlclose }
{ $subsection dll-valid? } ;

ARTICLE: "embedding-api" "Factor embedding API"
"The Factor embedding API is defined in " { $snippet "vm/master.h" } "."
$nl
"The " { $snippet "F_CHAR" } " type is an alias for the character type used for path names by the operating system; " { $snippet "char" } " on Unix and " { $snippet "wchar_t" } " on Windows."
$nl
"Including this header file into a C compilation unit will declare the following functions:"
{ $table
    { {
        { $code "void init_factor_from_args("
            "    F_CHAR *image, int argc, F_CHAR **argv, bool embedded"
            ")" }
        "Initializes Factor."
        $nl
        "If " { $snippet "image" } " is " { $snippet "NULL" } ", Factor will load an image file whose name is obtained by suffixing the executable name with " { $snippet ".image" } "."
        $nl
        "The " { $snippet "argc" } " and " { $snippet "argv" } " parameters are interpreted just like normal command line arguments when running Factor stand-alone; see " { $link "cli" } "."
        $nl
        "The " { $snippet "embedded" } " flag ensures that this function returns as soon as Factor has been initialized. Otherwise, Factor will start up normally."
    } }
    { {
        { $code "char *factor_eval_string(char *string)" }
        "Evaluates a piece of code in the embedded Factor instance by passing the string to " { $link eval>string } " and returning the result. The result must be explicitly freed by a call to " { $snippet "factor_eval_free" } "."
    } }
    { {
        { $code "void factor_eval_free(char *result)" }
        "Frees a string returned by " { $snippet "factor_eval_string()" } "."
    } }
    { {
        { $code "void factor_yield(void)" }
        "Gives all Factor threads a chance to run."
    } }
    { {
        { $code "void factor_sleep(long us)" }
        "Gives all Factor threads a chance to run for " { $snippet "us" } " microseconds."
    } }
} ;

ARTICLE: "embedding-restrictions" "Embedding API restrictions" 
"The Factor VM is not thread safe, and does not support multiple instances. There must only be one Factor instance per process, and this instance must be consistently accessed from the same thread for its entire lifetime. Once initialized, a Factor instance cannot be destroyed other than by exiting the process." ;

ARTICLE: "embedding-factor" "What embedding looks like from Factor"
"Factor code will run inside an embedded instance in the same way it would run in a stand-alone instance."
$nl
"One exception is that the global " { $link input-stream } " and " { $link output-stream } " streams are not bound by default, to avoid conflicting with any I/O the host process might perform. The " { $link init-stdio } " words must be called explicitly to initialize terminal streams."
$nl
"There is a word which can detect when Factor is embedded:"
{ $subsection embedded? }
"No special support is provided for calling out from Factor into the owner process. The C library inteface works fine for this task - see " { $link "alien" } "." ;

ARTICLE: "embedding" "Embedding Factor into C applications"
"The Factor " { $snippet "Makefile" } " builds the Factor VM both as an executable and a library. The library can be used by other applications. File names for the library on various operating systems:"
{ $table
    { "OS" "Library name" "Shared?" }
    { "Windows XP/Vista" { $snippet "factor.dll" } "Yes" }
    ! { "Windows CE" { $snippet "factor-ce.dll" } "Yes" }
    { "Mac OS X" { $snippet "libfactor.dylib" } "Yes" }
    { "Other Unix" { $snippet "libfactor.a" } "No" }
}
"An image file must be supplied; a minimal image can be built, however the compiler must be included for the embedding API to work (see " { $link "bootstrap-cli-args" } ")."
{ $subsection "embedding-api" }
{ $subsection "embedding-factor" }
{ $subsection "embedding-restrictions" } ;

ARTICLE: "alien" "C library interface"
"Factor can directly call C functions in native libraries. It is also possible to compile callbacks which run Factor code, and pass them to native libraries as function pointers."
$nl
"The C library interface is entirely self-contained; there is no C code which one must write in order to wrap a library."
$nl
"C library interface words are found in the " { $vocab-link "alien" } " vocabulary."
{ $warning "C does not perform runtime type checking, automatic memory management or array bounds checks. Incorrect usage of C library functions can lead to crashes, data corruption, and security exploits." }
{ $subsection "loading-libs" }
{ $subsection "aliens" }
{ $subsection "alien-invoke" }
{ $subsection "alien-callback" }
{ $subsection "c-data" }
{ $subsection "dll.private" }
{ $subsection "embedding" } ;

ABOUT: "alien"
