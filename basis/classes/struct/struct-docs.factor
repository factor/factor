! Copyright (C) Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: alien classes classes.struct.private help.markup help.syntax
kernel libc math sequences ;
IN: classes.struct

HELP: <struct-boa>
{ $values
    { "class" class }
}
{ $description "This macro implements " { $link boa } " for " { $link struct } " classes. A struct of the given class is constructed, and its slots are initialized using values off the top of the datastack." } ;

HELP: (struct)
{ $values
    { "class" class }
    { "struct" struct }
}
{ $description "Allocates garbage-collected heap memory for a new " { $link struct } " of the specified " { $snippet "class" } ". The new struct's slots are left uninitialized; in most cases, the " { $link <struct> } " word, which initializes the struct's slots with their initial values, should be used instead." } ;

{ (struct) (malloc-struct) } related-words

HELP: <struct>
{ $values
    { "class" class }
    { "struct" struct }
}
{ $description "Allocates garbage-collected heap memory for a new " { $link struct } " of the specified " { $snippet "class" } ". The new struct's slots are initialized with the initial values specified in the struct definition." } ;

{ <struct> <struct-boa> malloc-struct memory>struct } related-words

HELP: STRUCT:
{ $syntax "STRUCT: class { slot type } { slot type } ... ;" }
{ $values { "class" "a new " { $link struct } " class to define" } { "slots" "a list of slot specifiers" } }
{ $description "Defines a new " { $link struct } " type. The syntax is nearly identical to " { $link POSTPONE: TUPLE: } "; however, there are some additional restrictions on struct types:"
{ $list
{ "Struct classes cannot have a superclass defined." }
{ "The slots of a struct must all have a type declared. The type must be a C type." }
{ { $link read-only } " slots on structs are not enforced, though they may be declared." }
}
"Additionally, structs may use bit fields. A slot specifier may use the syntax " { $snippet "bits: n" } " to specify that the bit width of the slot is " { $snippet "n" } ". Bit width may be specified on signed or unsigned integer slots. The layout of bit fields is not guaranteed to match that of any particular C compiler." } ;

HELP: S{
{ $syntax "S{ class slots... }" }
{ $values { "class" "a " { $link struct } " class word" } { "slots" "slot values" } }
{ $description "Marks the beginning of a literal struct. The syntax is identical to tuple literal syntax with " { $link POSTPONE: T{ } { $snippet " }" } "; either the assoc syntax (that is, " { $snippet "S{ class { slot value } { slot value } ... }" } ") or the simple syntax (" { $snippet "S{ class f value value ... }" } ") can be used." } ;

HELP: S@
{ $syntax "S@ class alien" }
{ $values { "class" "a " { $link struct } " class word" } { "alien" "a literal alien" } }
{ $description "Marks the beginning of a literal struct at a specific C address. The prettyprinter uses this syntax when the memory backing a struct object is invalid. This syntax should not generally be used in source code." } ;

{ POSTPONE: S{ POSTPONE: S@ } related-words

HELP: UNION-STRUCT:
{ $syntax "UNION-STRUCT: class { slot type } { slot type } ... ;" }
{ $values { "class" "a new " { $link struct } " class to define" } { "slots" "a list of slot specifiers" } }
{ $description "Defines a new " { $link struct } " type where all of the slots share the same storage. See " { $link POSTPONE: STRUCT: } " for details on the syntax." } ;

HELP: PACKED-STRUCT:
{ $syntax "PACKED-STRUCT: class { slot type } { slot type } ... ;" }
{ $values { "class" "a new " { $link struct } " class to define" } { "slots" "a list of slot specifiers" } }
{ $description "Defines a new " { $link struct } " type with no alignment padding between slots or at the end. In all other respects, behaves like " { $link POSTPONE: STRUCT: } "." } ;

HELP: define-struct-class
{ $values
    { "class" class } { "slots" "a sequence of " { $link struct-slot-spec } "s" }
}
{ $description "Defines a new " { $link struct } " class. This is the runtime equivalent of the " { $link POSTPONE: STRUCT: } " syntax." } ;

HELP: define-packed-struct-class
{ $values
    { "class" class } { "slots" "a sequence of " { $link struct-slot-spec } "s" }
}
{ $description "Defines a new " { $link struct } " class. This is the runtime equivalent of the " { $link POSTPONE: PACKED-STRUCT: } " syntax." } ;

HELP: define-union-struct-class
{ $values
    { "class" class } { "slots" "a sequence of " { $link struct-slot-spec } "s" }
}
{ $description "Defines a new " { $link struct } " class where all of the slots share the same storage. This is the runtime equivalent of the " { $link POSTPONE: UNION-STRUCT: } " syntax." } ;

HELP: malloc-struct
{ $values
    { "class" class }
    { "struct" struct }
}
{ $description "Allocates unmanaged C heap memory for a new " { $link struct } " of the specified " { $snippet "class" } ". The new struct's slots are initialized to their initial values. The struct should be " { $link free } "d when it is no longer needed." } ;

HELP: (malloc-struct)
{ $values
    { "class" class }
    { "struct" struct }
}
{ $description "Allocates unmanaged C heap memory for a new " { $link struct } " of the specified " { $snippet "class" } ". The new struct's slots are left uninitialized; to initialize the allocated memory with the slots' initial values, use " { $link malloc-struct } ". The struct should be " { $link free } "d when it is no longer needed." } ;

HELP: compute-struct-offsets
{ $values { "slots" sequence } { "size" integer } }
{ $description "Computes how many bytes of memory the struct takes, minus final padding." } ;

HELP: memory>struct
{ $values
    { "ptr" c-ptr } { "class" class }
    { "struct" struct }
}
{ $description "Constructs a new " { $link struct } " of the specified " { $snippet "class" } " at the memory location referenced by " { $snippet "ptr" } ". The referenced memory is unchanged." } ;

HELP: read-struct
{ $values { "class" class } { "struct" struct } }
{ $description "Reads a new " { $link struct } " of the specified " { $snippet "class" } "." } ;

HELP: struct
{ $class-description "The parent class of all struct types." } ;

{ struct POSTPONE: STRUCT: POSTPONE: UNION-STRUCT: } related-words

HELP: struct-class
{ $class-description "The metaclass of all " { $link struct } " classes." } ;

HELP: struct-slot-values
{ $values { "struct" struct } { "sequence" sequence } }
{ $description "Extracts the values of the structs slots" }
{ $errors "Throws a memory protection error if the memory the struct references is not accessible." } ;

ARTICLE: "classes.struct.examples" "Struct class examples"
"A struct with a variety of fields:"
{ $code
    "USING: alien.c-types classes.struct ;"
    ""
    "STRUCT: test-struct"
    "    { i int }"
    "    { chicken char[16] }"
    "    { data void* } ;"
}
"Creating a new instance of this struct, and printing out:"
{ $code "test-struct <struct> ." }
"Creating a new instance with slots initialized from the stack:"
{ $code
    "USING: libc specialized-arrays alien.data ;"
    "SPECIALIZED-ARRAY: char"
    ""
    "42"
    "\"Hello, chicken.\" char >c-array"
    "1024 malloc"
    "test-struct <struct-boa> ."
} ;

ARTICLE: "classes.struct.define" "Defining struct classes"
"Struct classes are defined using a syntax similar to the " { $link POSTPONE: TUPLE: } " syntax for defining tuple classes:"
{ $subsections POSTPONE: STRUCT: POSTPONE: PACKED-STRUCT: }
"Union structs are also supported, which behave like structs but share the same memory for all the slots."
{ $subsections POSTPONE: UNION-STRUCT: } ;

ARTICLE: "classes.struct.create" "Creating instances of structs"
"Structs can be allocated with " { $link new } "- and " { $link boa } "-like constructor words. Additional words are provided for building structs from C memory and from existing buffers:"
{ $subsections
    <struct>
    <struct-boa>
    malloc-struct
    memory>struct
}
"When the contents of a struct will be immediately reset, faster primitive words are available that will create a struct without initializing its contents:"
{ $subsections
    (struct)
    (malloc-struct)
}
"Structs have literal syntax, similar to " { $link POSTPONE: T{ } " for tuples:"
{ $subsections POSTPONE: S{ } ;

ARTICLE: "classes.struct.c" "Passing structs to C functions"
"Structs can be passed and returned by value, or by reference."
$nl
"If a parameter is declared with a struct type, the parameter is passed by value. To pass a struct by reference, declare a parameter with a pointer to struct type."
$nl
{ $heading "C functions returning structs" }
"If a C function is declared as returning a struct type, the struct is returned by value, and wrapped in an instance of the correct struct class automatically. If a C function is declared as returning a pointer to a struct, it will return an " { $link alien } " instance. This is because there is no way to distinguish between a pointer to a single struct and a pointer to an array of zero or more structs. It is up to the caller to wrap it in a struct using " { $link memory>struct } ", or a specialized array of structs using " { $snippet "<direct-T-array>" } ", respectively."
$nl
"An example of a struct declaration:"
{ $code
    "USING: alien.c-types classes.struct ;"
    ""
    "STRUCT: Point"
    "    { x int }"
    "    { y int }"
    "    { z int } ;"
}
"A C function which returns a struct by value:"
{ $code
    "USING: alien.syntax ;"
    "FUNCTION: Point give_me_a_point ( c-string description )"
}
"A C function which takes a struct parameter by reference:"
{ $code
    "FUNCTION: void print_point ( Point* p )"
} ;

ARTICLE: "classes.struct" "Struct classes"
"The " { $vocab-link "classes.struct" } " vocabulary implements " { $link struct } " classes. They are similar to " { $link tuple } " classes, but their slots exhibit value semantics, and they are backed by a contiguous structured block of memory. Structs can be used for space-efficient storage of data in the Factor heap, as well as for passing data to and from C libraries using the " { $link "alien" } "."
{ $subsections
    "classes.struct.examples"
    "classes.struct.define"
    "classes.struct.create"
    "classes.struct.c"
} ;

ABOUT: "classes.struct"
