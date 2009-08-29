! (c)Joe Groff bsd license
USING: alien classes help.markup help.syntax kernel libc
quotations slots ;
IN: classes.struct

HELP: <struct-boa>
{ $values
    { "class" class }
}
{ $description "This macro implements " { $link boa } " for " { $link struct } " classes. A struct of the given class is constructed, and its slots are initialized using values off the top of the datastack." } ;

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
} } ;

HELP: S{
{ $syntax "S{ class slots... }" }
{ $values { "class" "a " { $link struct } " class word" } { "slots" "slot values" } }
{ $description "Marks the beginning of a literal struct. The syntax is identical to tuple literal syntax with " { $link POSTPONE: T{ } { $snippet " }" } "; either the assoc syntax (that is, " { $snippet "S{ class { slot value } { slot value } ... }" } ") or the simple syntax (" { $snippet "S{ class f value value ... }" } ") can be used." } ;

HELP: UNION-STRUCT:
{ $syntax "UNION-STRUCT: class { slot type } { slot type } ... ;" }
{ $values { "class" "a new " { $link struct } " class to define" } { "slots" "a list of slot specifiers" } }
{ $description "Defines a new " { $link struct } " type where all of the slots share the same storage. See " { $link POSTPONE: STRUCT: } " for details on the syntax." } ;

HELP: define-struct-class
{ $values
    { "class" class } { "slots" "a sequence of " { $link slot-spec } "s" }
}
{ $description "Defines a new " { $link struct } " class. This is the runtime equivalent of the " { $link POSTPONE: STRUCT: } " syntax." } ;

HELP: define-union-struct-class
{ $values
    { "class" class } { "slots" "a sequence of " { $link slot-spec } "s" }
}
{ $description "Defines a new " { $link struct } " class where all of the slots share the same storage. This is the runtime equivalent of the " { $link POSTPONE: UNION-STRUCT: } " syntax." } ;

HELP: malloc-struct
{ $values
    { "class" class }
    { "struct" struct }
}
{ $description "Allocates unmanaged C heap memory for a new " { $link struct } " of the specified " { $snippet "class" } ". The new struct's slots are left uninitialized. The struct should be " { $link free } "d when it is no longer needed." } ;

HELP: memory>struct
{ $values
    { "ptr" c-ptr } { "class" class }
    { "struct" struct }
}
{ $description "Constructs a new " { $link struct } " of the specified " { $snippet "class" } " at the memory location referenced by " { $snippet "ptr" } ". The referenced memory is unchanged." } ;

HELP: struct
{ $class-description "The parent class of all struct types." } ;

{ struct POSTPONE: STRUCT: POSTPONE: UNION-STRUCT: } related-words

HELP: struct-class
{ $class-description "The metaclass of all " { $link struct } " classes." } ;

ARTICLE: "classes.struct" "Struct classes"
{ $link struct } " classes are similar to " { $link tuple } "s, but their slots exhibit value semantics, and they are backed by a contiguous structured block of memory. Structs can be used for structured access to C memory or Factor byte arrays and for passing struct values in and out of the FFI. Struct types are defined using a syntax similar to tuple syntax:"
{ $subsection POSTPONE: STRUCT: }
"Structs can be allocated with " { $link new } "- and " { $link boa } "-like constructor words. Additional words are provided for building structs from C memory and from existing buffers:"
{ $subsection <struct> }
{ $subsection <struct-boa> }
{ $subsection malloc-struct }
{ $subsection memory>struct }
"Structs have literal syntax like tuples:"
{ $subsection POSTPONE: S{ }
"Union structs are also supported, which behave like structs but share the same memory for all the type's slots."
{ $subsection POSTPONE: UNION-STRUCT: }
;

ABOUT: "classes.struct"
