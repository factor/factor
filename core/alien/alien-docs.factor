USING: byte-arrays arrays help.syntax help.markup
alien.syntax alien.c-types compiler definitions math libc
debugger parser io io.backend system bit-arrays float-arrays ;
IN: alien

HELP: alien
{ $class-description "The class of alien pointers. See " { $link "syntax-aliens" } " for syntax and " { $link "c-data" } " for general information." } ;

HELP: dll
{ $class-description "The class of native library handles. See " { $link "syntax-aliens" } " for syntax and " { $link "dll.private" } " for general information." } ;

HELP: expired? ( c-ptr -- ? )
{ $values { "c-ptr" "an alien, byte array, or " { $link f } } { "?" "a boolean" } }
{ $description "Tests if the alien is a relic from an earlier session. When an image is loaded, any alien objects which persisted in the image are marked as being expired."
$nl
"A byte array is never considered to be expired, whereas passing " { $link f } " always yields true." } ;

HELP: <displaced-alien> ( displacement c-ptr -- alien )
{ $values { "displacement" "an integer" } { "c-ptr" "an alien, byte array, or " { $link f } } { "alien" "a new alien" } }
{ $description "Creates a new alien address object, wrapping a raw memory address. The alien points to a location in memory which is offset by " { $snippet "displacement" } " from the address of " { $snippet "c-ptr" } "." }
{ $notes "Passing a value of " { $link f } " for " { $snippet "c-ptr" } " creates an alien with an absolute address; this is how " { $link <alien> } " is implemented."
$nl
"Passing a zero absolute address does not construct a new alien object, but instead makes the word output " { $link f } "." } ;

{ <alien> <displaced-alien> alien-address } related-words

HELP: alien-address ( c-ptr -- addr )
{ $values { "c-ptr" "an alien or " { $link f } } { "addr" "a non-negative integer" } }
{ $description "Outputs the address of an alien." }
{ $notes "Taking the address of a " { $link byte-array } " is explicitly prohibited since byte arrays can be moved by the garbage collector between the time the address is taken, and when it is accessed. If you need to pass pointers to C functions which will persist across alien calls, you must allocate unmanaged memory instead. See " { $link "malloc" } "." } ;

HELP: <alien>
{ $values { "address" "a non-negative integer" } { "alien" "a new alien address" } }
{ $description "Creates an alien object, wrapping a raw memory address." }
{ $notes "Alien objects are invalidated between image saves and loads." } ;

HELP: c-ptr
{ $class-description "Class of objects consisting of aliens, byte arrays and " { $link f } ". These objects can convert to pointer C types, which are all aliases of " { $snippet "void*" } "." } ;

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
{ $description "Loads a library by logical name and outputs a handle which may be passed to " { $link dlsym } " or " { $link dlclose } ". If the library is already loaded, returns the existing handle." }
{ $errors "Throws an error if the library could not be found, or if loading fails for some other reason." } ;

HELP: add-library
{ $values { "name" "a string" } { "path" "a string" } { "abi" "one of " { $snippet "\"cdecl\"" } " or " { $snippet "\"stdcall\"" } } }
{ $description "Defines a new logical library named " { $snippet "name" } " located in the file system at " { $snippet "path" } "and the specified ABI." }
{ $examples { $code "\"gif\" \"libgif.so\" \"cdecl\" add-library" } } ;

HELP: alien-invoke-error
{ $error-description "Thrown if the word calling " { $link alien-invoke } " was not compiled with the optimizing compiler. This may be a result of one of several failure conditions:"
    { $list
        { "This can happen when experimenting with " { $link alien-invoke } " in this listener. To fix the problem, place the " { $link alien-invoke } " call in a word and then call " { $link recompile } ". See " { $link "compiler" } "." }
        { "The return type or parameter list references an unknown C type." }
        { "The symbol or library could not be found." }
        { "One of the four inputs to " { $link alien-invoke } " is not a literal value. To call functions which are not known at compile-time, use " { $link alien-indirect } "." }
    }
} ;

HELP: alien-invoke
{ $values { "..." "zero or more objects passed to the C function" } { "return" "a C return type" } { "library" "a logical library name" } { "function" "a C function name" } { "parameters" "a sequence of C parameter types" } }
{ $description "Calls a C library function with the given name. Input parameters are taken from the data stack, and the return value is pushed on the data stack after the function returns. A return type of " { $snippet "\"void\"" } " indicates that no value is to be expected." }
{ $notes "C type names are documented in " { $link "c-types-specs" } "." }
{ $errors "Throws an " { $link alien-invoke-error } " if the word calling " { $link alien-invoke } " was not compiled with the optimizing compiler." } ;

HELP: alien-indirect-error
{ $error-description "Thrown if the word calling " { $link alien-indirect } " was not compiled with the optimizing compiler. This may be a result of one of several failure conditions:"
    { $list
        { "This can happen when experimenting with " { $link alien-indirect } " in this listener. To fix the problem, place the " { $link alien-indirect } " call in a word and then call " { $link recompile } ". See " { $link "compiler" } "." }
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
        { "This can happen when experimenting with " { $link alien-callback } " in this listener. To fix the problem, place the " { $link alien-callback } " call in a word and then call " { $link recompile } ". See " { $link "compiler" } "." }
        { "The return type or parameter list references an unknown C type." }
        { "One of the four inputs to " { $link alien-callback } " is not a literal value." }
    }
} ;

HELP: alien-callback
{ $values { "return" "a C return type" } { "parameters" "a sequence of C parameter types" } { "abi" "one of " { $snippet "\"cdecl\"" } " or " { $snippet "\"stdcall\"" } } { "quot" "a quotation" } { "alien" c-ptr } }
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

ARTICLE: "aliens" "Alien addresses"
"Instances of the " { $link alien } " class represent pointers to C data outside the Factor heap:"
{ $subsection <alien> }
{ $subsection <displaced-alien> }
{ $subsection alien-address }
{ $subsection expired? }
"Anywhere that a " { $link alien } " instance is accepted, the " { $link f } " singleton may be passed in to denote a null pointer."
$nl
"Usually alien objects do not have to created and dereferenced directly; instead declaring C function parameters and return values as having a pointer type such as " { $snippet "void*" } " takes care of the details. See " { $link "c-types-specs" } "." ;

ARTICLE: "c-structs" "C structure types"
"A " { $snippet "struct" } " in C is essentially a block of memory with the value of each structure field stored at a fixed offset from the start of the block. The C library interface provides some utilities to define words which read and write structure fields given a base address."
{ $subsection POSTPONE: C-STRUCT: }
"Great care must be taken when working with C structures since no type or bounds checking is possible."
$nl
"An example:"
{ $code
    "C-STRUCT: XVisualInfo"
    "    { \"Visual*\" \"visual\" }"
    "    { \"VisualID\" \"visualid\" }"
    "    { \"int\" \"screen\" }"
    "    { \"uint\" \"depth\" }"
    "    { \"int\" \"class\" }"
    "    { \"ulong\" \"red_mask\" }"
    "    { \"ulong\" \"green_mask\" }"
    "    { \"ulong\" \"blue_mask\" }"
    "    { \"int\" \"colormap_size\" }"
    "    { \"int\" \"bits_per_rgb\" } ;"
}
"C structure objects can be allocated by calling " { $link <c-object> } " or " { $link malloc-object } "."
$nl
"Arrays of C structures can be created by calling " { $link <c-array> } " or " { $link malloc-array } ". Elements can be read and written using words named " { $snippet { $emphasis "type" } "-nth" } " and " { $snippet "set-" { $emphasis "type" } "-nth" } "; these words are automatically generated by " { $link POSTPONE: C-STRUCT: } "." ;

ARTICLE: "c-unions" "C unions"
"A " { $snippet "union" } " in C defines a type large enough to hold its largest member. This is usually used to allocate a block of memory which can hold one of several types of values."
{ $subsection POSTPONE: C-UNION: }
"C structure objects can be allocated by calling " { $link <c-object> } " or " { $link malloc-object } "."
$nl
"Arrays of C unions can be created by calling " { $link <c-array> } " or " { $link malloc-array } ". Elements can be read and written using words named " { $snippet { $emphasis "type" } "-nth" } " and " { $snippet "set-" { $emphasis "type" } "-nth" } "; these words are automatically generated by " { $link POSTPONE: C-UNION: } "." ;

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

ARTICLE: "loading-libs" "Loading native libraries"
"Before calling a C library, you must associate its path name on disk with a logical name which Factor uses to identify the library:"
{ $subsection add-library }
"Once a library has been defined, you can try loading it to see if the path name is correct:"
{ $subsection load-library } ;

ARTICLE: "alien-invoke" "Calling C from Factor"
"The easiest way to call into a C library is to define bindings using a pair of parsing words:"
{ $subsection POSTPONE: LIBRARY: }
{ $subsection POSTPONE: FUNCTION: }
"The above parsing words create word definitions which call a lower-level word; you can use it directly, too:"
{ $subsection alien-invoke }
"Sometimes it is necessary to invoke a C function pointer, rather than a named C function:"
{ $subsection alien-indirect }
"There are some details concerning the conversion of Factor objects to C values, and vice versa. See " { $link "c-data" } "."
$nl
"Don't forget to compile your binding word after defining it; C library calls cannot be made from an interpreted definition. Words defined in source files are automatically compiled when the source file is loaded, but words defined in the listener are not; when interactively testing C libraries, use " { $link compile } " or " { $link recompile } " to compile binding words." ;

ARTICLE: "alien-callback-gc" "Callbacks and code GC"
"A callback consits of two parts; the callback word, which pushes the address of the callback on the stack when executed, and the callback body itself. If the callback word is redefined, removed from the dictionary using " { $link forget } ", or recompiled, the callback body will not be reclaimed by the garbage collector, since potentially C code may be holding a reference to the callback body."
$nl
"This is the safest approach, however it can lead to code heap leaks when repeatedly reloading code which defines callbacks. If you are " { $emphasis "completely sure" } " that no running C code is holding a reference to any callbacks, you can blow them all away:"
{ $code "USE: alien callbacks get clear-hash code-gc" }
"This will reclaim all callback bodies which are otherwise unreachable from the dictionary (that is, their associated callback words have since been redefined, recompiled or forgotten)." ;

ARTICLE: "alien-callback" "Calling Factor from C"
"Callbacks can be defined and passed to C code as function pointers; the C code can then invoke the callback and run Factor code:"
{ $subsection alien-callback }
"There are some details concerning the conversion of Factor objects to C values, and vice versa. See " { $link "c-data" } "."
{ $subsection "alien-callback-gc" } ;

ARTICLE: "dll.private" "DLL handles"
"DLL handles are a built-in class of objects which represent loaded native libraries. DLL handles are instances of the " { $link dll } " class, and have a literal syntax used for debugging prinouts; see " { $link "syntax-aliens" } "."
$nl
"Usually one never has to deal with DLL handles directly; the C library interface creates them as required. However if direct access to these operating system facilities is required, the following primitives can be used:"
{ $subsection dlopen }
{ $subsection dlsym }
{ $subsection dlclose } ;

ARTICLE: "c-types-specs" "C type specifiers"
"C types are identified by strings, and type names occur as parameters to the " { $link alien-invoke } ", " { $link alien-indirect } " and " { $link alien-callback } " words, as well as " { $link POSTPONE: C-STRUCT: } ", " { $link POSTPONE: C-UNION: } " and " { $link POSTPONE: TYPEDEF: } "."
$nl
"The following numerical types are available; a " { $snippet "u" } " prefix denotes an unsigned type:"
{ $table
    { "C type" "Notes" }
    { { $snippet "char" } "always 1 byte" }
    { { $snippet "uchar" } { } }
    { { $snippet "short" } "always 2 bytes" }
    { { $snippet "ushort" } { } }
    { { $snippet "int" } "always 4 bytes" }
    { { $snippet "uint" } { } }
    { { $snippet "long" } { "same size as CPU word size and " { $snippet "void*" } ", except on 64-bit Windows, where it is 4 bytes" } }
    { { $snippet "ulong" } { } }
    { { $snippet "longlong" } "always 8 bytes" }
    { { $snippet "ulonglong" } { } }
    { { $snippet "float" } { } }
    { { $snippet "double" } { "same format as " { $link float } " objects" } }
}
"When making alien calls, Factor numbers are converted to and from the above types in a canonical way. Converting a Factor number to a C value may result in a loss of precision."
$nl
"Pointer types are specified by suffixing a C type with " { $snippet "*" } ", for example " { $snippet "float*" } ". One special case is " { $snippet "void*" } ", which denotes a generic pointer; " { $snippet "void" } " by itself is not a valid C type specifier. With the exception of strings (see " { $link "c-strings" } "), all pointer types are identical to " { $snippet "void*" } " as far as the C library interface is concerned."
$nl
"Fixed-size array types are supported; the syntax consists of a C type name followed by dimension sizes in brackets; the following denotes a 3 by 4 array of integers:"
{ $code "int[3][4]" }
"Fixed-size arrays differ from pointers in that they are allocated inside structures and unions; however when used as function parameters they behave exactly like pointers and thus the dimensions only serve as documentation."
$nl
"Structure and union types are specified by the name of the structure or union." ;

ARTICLE: "c-byte-arrays" "Passing data in byte arrays"
"Instances of the " { $link byte-array } ", " { $link bit-array } " and " { $link float-array } " class can be passed to C functions; the C function receives a pointer to the first element of the array."
$nl
"Byte arrays can be allocated directly with a byte count using the " { $link <byte-array> } " word. However in most cases, instead of computing a size in bytes directly, it is easier to use a higher-level word which expects C type and outputs a byte array large enough to hold that type:"
{ $subsection <c-object> }
{ $subsection <c-array> }
{ $warning
"The Factor garbage collector can move byte arrays around, and it is only safe to pass byte arrays to C functions if the function does not store a pointer to the byte array in some global structure, or retain it in any way after returning."
$nl
"Long-lived data for use by C libraries can be allocated manually, just as when programming in C. See " { $link "malloc" } "." }
{ $see-also "c-arrays" } ;

ARTICLE: "malloc" "Manual memory management"
"Sometimes data passed to C functions must be allocated at a fixed address, and so garbage collector managed byte arrays cannot be used. See the warning at the bottom of " { $link "c-byte-arrays" } " for a description of when this is the case."
$nl
"Allocating a C datum with a fixed address:"
{ $subsection malloc-object }
{ $subsection malloc-array }
{ $subsection malloc-byte-array }
"There is a set of words in the " { $vocab-link "libc" } " vocabulary which directly call C standard library memory management functions:"
{ $subsection malloc }
{ $subsection calloc }
{ $subsection realloc }
"The return value of the above three words must always be checked for a memory allocation failure:"
{ $subsection check-ptr }
"You must always free pointers returned by any of the above words when the block of memory is no longer in use:"
{ $subsection free }
"You can unsafely copy a range of bytes from one memory location to another:"
{ $subsection memcpy }
"A wrapper for temporarily allocating a block of memory:"
{ $subsection with-malloc } ;

ARTICLE: "c-strings" "C strings"
"The C library interface defines two types of C strings:"
{ $table
    { "C type" "Notes" }
    { { $snippet "char*" } "8-bit per character null-terminated ASCII" }
    { { $snippet "ushort*" } "16-bit per character null-terminated UCS-2" }
}
"Passing a Factor string to a C function expecting a C string allocates a " { $link byte-array } " in the Factor heap; the string is then converted to the requested format and a raw pointer is passed to the function. If the conversion fails, for example if the string contains null bytes or characters with values higher than 255, a " { $link c-string-error. } " is thrown."
"Sometimes a C function has a parameter type of " { $snippet "void*" } ", and various data types, among them strings, can be passed in. In this case, strings are not automatically converted to aliens, and instead you must call one of these words:"
{ $subsection string>char-alien }
{ $subsection string>u16-alien }
{ $subsection malloc-char-string }
{ $subsection malloc-u16-string }
"The first two allocate " { $link byte-array } "s, and the latter allocates manually-managed memory which is not moved by the garbage collector and has to be explicitly freed by calling " { $link free } "."
$nl
"Finally, a set of words can be used to read and write " { $snippet "char*" } " and " { $snippet "ushort*" } " strings at arbitrary addresses:"
{ $subsection alien>char-string }
{ $subsection alien>u16-string }
{ $subsection memory>string }
{ $subsection string>memory } ;

ARTICLE: "c-arrays-factor" "Converting C arrays to and from Factor arrays"
"Each primitive C type has a pair of words, " { $snippet ">" { $emphasis "type" } "-array" } " and " { $snippet { $emphasis "type" } "-array>" } ", for converting an array of Factor objects to and from a " { $link byte-array } " of C values. This set of words consists of:"
{ $subsection >c-bool-array      }
{ $subsection >c-char-array      }
{ $subsection >c-double-array    }
{ $subsection >c-float-array     }
{ $subsection >c-int-array       }
{ $subsection >c-long-array      }
{ $subsection >c-longlong-array  }
{ $subsection >c-short-array     }
{ $subsection >c-uchar-array     }
{ $subsection >c-uint-array      }
{ $subsection >c-ulong-array     }
{ $subsection >c-ulonglong-array }
{ $subsection >c-ushort-array    }
{ $subsection >c-void*-array     }
{ $subsection c-bool-array>      }
{ $subsection c-char*-array>     }
{ $subsection c-char-array>      }
{ $subsection c-double-array>    }
{ $subsection c-float-array>     }
{ $subsection c-int-array>       }
{ $subsection c-long-array>      }
{ $subsection c-longlong-array>  }
{ $subsection c-short-array>     }
{ $subsection c-uchar-array>     }
{ $subsection c-uint-array>      }
{ $subsection c-ulong-array>     }
{ $subsection c-ulonglong-array> }
{ $subsection c-ushort*-array>   }
{ $subsection c-ushort-array>    }
{ $subsection c-void*-array>     } ;

ARTICLE: "c-arrays-get/set" "Reading and writing elements in C arrays"
"Each C type has a pair of words, " { $snippet { $emphasis "type" } "-nth" } " and " { $snippet "set-" { $emphasis "type" } "-nth" } ", for reading and writing values of this type stored in an array. This set of words includes but is not limited to:"
{ $subsection char-nth }
{ $subsection set-char-nth }
{ $subsection uchar-nth }
{ $subsection set-uchar-nth }
{ $subsection short-nth }
{ $subsection set-short-nth }
{ $subsection ushort-nth }
{ $subsection set-ushort-nth }
{ $subsection int-nth }
{ $subsection set-int-nth }
{ $subsection uint-nth }
{ $subsection set-uint-nth }
{ $subsection long-nth }
{ $subsection set-long-nth }
{ $subsection ulong-nth }
{ $subsection set-ulong-nth }
{ $subsection longlong-nth }
{ $subsection set-longlong-nth }
{ $subsection ulonglong-nth }
{ $subsection set-ulonglong-nth }
{ $subsection float-nth }
{ $subsection set-float-nth }
{ $subsection double-nth }
{ $subsection set-double-nth }
{ $subsection void*-nth }
{ $subsection set-void*-nth }
{ $subsection char*-nth }
{ $subsection ushort*-nth } ;

ARTICLE: "c-arrays" "C arrays"
"C arrays are allocated in the same manner as other C data; see " { $link "c-byte-arrays" } " and " { $link "malloc" } "."
$nl
"C type specifiers for array types are documented in " { $link "c-types-specs" } "."
{ $subsection "c-arrays-factor" }
{ $subsection "c-arrays-get/set" } ;

ARTICLE: "c-out-params" "Output parameters in C"
"A frequently-occurring idiom in C code is the \"out parameter\". If a C function returns more than one value, the caller passes pointers of the correct type, and the C function writes its return values to those locations."
$nl
"Each numerical C type, together with " { $snippet "void*" } ", has an associated " { $emphasis "out parameter constructor" } " word which takes a Factor object as input, constructs a byte array of the correct size, and converts the Factor object to a C value stored into the byte array:"
{ $subsection <char> }
{ $subsection <uchar> }
{ $subsection <short> }
{ $subsection <ushort> }
{ $subsection <int> }
{ $subsection <uint> }
{ $subsection <long> }
{ $subsection <ulong> }
{ $subsection <longlong> }
{ $subsection <ulonglong> }
{ $subsection <float> }
{ $subsection <double> }
{ $subsection <void*> }
"You call the out parameter constructor with the required initial value, then pass the byte array to the C function, which receives a pointer to the start of the byte array's data area. The C function then returns, leaving the result in the byte array; you read it back using the next set of words:"
{ $subsection *char }
{ $subsection *uchar }
{ $subsection *short }
{ $subsection *ushort }
{ $subsection *int }
{ $subsection *uint }
{ $subsection *long }
{ $subsection *ulong }
{ $subsection *longlong }
{ $subsection *ulonglong }
{ $subsection *float }
{ $subsection *double }
{ $subsection *void* }
{ $subsection *char* }
{ $subsection *ushort* }
"Note that while structure and union types do not get these words defined for them, there is no loss of generality since " { $link <void*> } " and " { $link *void* } " may be used." ;

ARTICLE: "c-data" "Passing data between Factor and C"
"Two defining characteristics of Factor are dynamic typing and automatic memory management, which are somewhat incompatible with the machine-level data model exposed by C. Factor's C library interface defines its own set of C data types, distinct from Factor language types, together with automatic conversion between Factor values and C types. For example, C integer types must be declared and are fixed-width, whereas Factor supports arbitrary-precision integers. Also Factor's garbage collector can move objects in memory, which means that special support has to be provided for passing blocks of memory to C code."
{ $subsection "c-types-specs" }
{ $subsection "c-byte-arrays" }
{ $subsection "malloc" }
{ $subsection "c-strings" }
{ $subsection "c-arrays" }
{ $subsection "c-out-params" }
"C-style enumerated types are supported:"
{ $subsection POSTPONE: C-ENUM: }
"C types can be aliased for convenience and consitency with native library documentation:"
{ $subsection POSTPONE: TYPEDEF: }
"New C types can be defined:"
{ $subsection "c-structs" }
{ $subsection "c-unions" }
{ $subsection "reading-writing-memory" } ;

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
        { $code "void factor_sleep(long ms)" }
        "Gives all Factor threads a chance to run for " { $snippet "ms" } " milliseconds."
    } }
} ;

ARTICLE: "embedding-restrictions" "Embedding API restrictions" 
"The Factor VM is not thread safe, and does not support multiple instances. There must only be one Factor instance per process, and this instance must be consistently accessed from the same thread for its entire lifetime. Once initialized, a Factor instance cannot be destroyed other than by exiting the process." ;

ARTICLE: "embedding-factor" "What embedding looks like from Factor"
"Factor code will run inside an embedded instance in the same way it would run in a stand-alone instance."
$nl
"One exception is the global " { $link stdio } " stream, which is by default not bound to the terminal where the process is running, to avoid conflicting with any I/O the host process might perform. To initialize the terminal stream, " { $link init-stdio } " must be called explicitly."
$nl
"There is a word which can detect when Factor is embedded:"
{ $subsection embedded? }
"No special support is provided for calling out from Factor into the owner process. The C library inteface works fine for this task - see " { $link "alien" } "." ;

ARTICLE: "embedding" "Embedding Factor into C applications"
"The Factor " { $snippet "Makefile" } " builds the Factor VM both as an executable and a library. The library can be used by other applications. File names for the library on various operating systems:"
{ $table
    { "OS" "Library name" "Shared?" }
    { "Windows XP/Vista" { $snippet "factor-nt.dll" } "Yes" }
    { "Windows CE" { $snippet "factor-ce.dll" } "Yes" }
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
{ $warning "Since C does not retain runtime type information or do any kind of runtime type checking, any C library interface is not pointer safe. Improper use of C functions can crash the runtime or corrupt memory in unpredictible ways." }
{ $subsection "loading-libs" }
{ $subsection "alien-invoke" }
{ $subsection "alien-callback" }
{ $subsection "c-data" }
{ $subsection "dll.private" }
{ $subsection "embedding" } ;

ABOUT: "alien"
