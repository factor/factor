USING: alien.c-types alien.data strings help.markup help.syntax alien.syntax
sequences io arrays kernel words assocs namespaces ;
IN: alien.structs

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
"Arrays of C structures can be created with the " { $vocab-link "specialized-arrays" } " vocabulary." ;

ARTICLE: "c-unions" "C unions"
"A " { $snippet "union" } " in C defines a type large enough to hold its largest member. This is usually used to allocate a block of memory which can hold one of several types of values."
{ $subsection POSTPONE: C-UNION: }
"C union objects can be allocated by calling " { $link <c-object> } " or " { $link malloc-object } "."
$nl
"Arrays of C unions can be created with the " { $vocab-link "specialized-arrays" } " vocabulary." ;
