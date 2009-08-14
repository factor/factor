! (c)Joe Groff bsd license
USING: alien arrays classes help.markup help.syntax kernel math
specialized-arrays.direct ;
IN: classes.c-types

HELP: c-type-class
{ $class-description "This metaclass encompasses the " { $link "classes.c-types" } "." } ;

HELP: char
{ $class-description "A signed one-byte integer quantity." } ;

HELP: direct-array-of
{ $values
    { "alien" c-ptr } { "len" integer } { "class" c-type-class }
    { "array" "a direct array" }
}
{ $description "Constructs one of the " { $link "specialized-arrays.direct" } " over " { $snippet "len" } " elements of type " { $snippet "class" } " located at the referenced location in raw memory." } ;

HELP: int
{ $class-description "A signed four-byte integer quantity." } ;

HELP: long
{ $class-description "A signed integer quantity. On 64-bit Unix platforms, this is an eight-byte type; on Windows and on 32-bit Unix platforms, it is four bytes." } ;

HELP: longlong
{ $class-description "A signed eight-byte integer quantity." } ;

HELP: short
{ $class-description "A signed two-byte integer quantity." } ;

HELP: single-complex
{ $class-description "A single-precision complex floating point quantity." } ;

HELP: single-float
{ $class-description "A single-precision floating point quantity." } ;

HELP: uchar
{ $class-description "An unsigned one-byte integer quantity." } ;

HELP: uint
{ $class-description "An unsigned four-byte integer quantity." } ;

HELP: ulong
{ $class-description "An unsigned integer quantity. On 64-bit Unix platforms, this is an eight-byte type; on Windows and on 32-bit Unix platforms, it is four bytes." } ;

HELP: ulonglong
{ $class-description "An unsigned eight-byte integer quantity." } ;

HELP: ushort
{ $class-description "An unsigned two-byte integer quantity." } ;

ARTICLE: "classes.c-types" "C type classes"
"The " { $vocab-link "classes.c-types" } " vocabulary defines Factor classes that correspond to C types in the FFI."
{ $subsection char }
{ $subsection uchar }
{ $subsection short }
{ $subsection ushort }
{ $subsection int }
{ $subsection uint }
{ $subsection long }
{ $subsection ulong }
{ $subsection longlong }
{ $subsection ulonglong }
{ $subsection single-float }
{ $subsection float }
{ $subsection single-complex }
{ $subsection complex }
{ $subsection pinned-c-ptr }
"The vocabulary also provides a word for constructing " { $link "specialized-arrays.direct" } " of C types over raw memory:"
{ $subsection direct-array-of } ;

ABOUT: "classes.c-types"
