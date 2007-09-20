USING: help.markup help.syntax alien ;
IN: libc

HELP: malloc
{ $values { "size" "a non-negative integer" } { "alien" c-ptr } }
{ $description "Allocates a block of " { $snippet "size" } " bytes from the operating system. The contents of the block are undefined." }
{ $errors "Throws an error if memory allocation failed." }
{ $warning "Don't forget to deallocate the memory with a call to " { $link free } "." } ;

HELP: calloc
{ $values { "count" "a non-negative integer" } { "size" "a non-negative integer" } { "alien" c-ptr } }
{ $description "Allocates a block of " { $snippet "count * size" } " bytes from the operating system. The contents of the block are initially zero." }
{ $errors "Throws an error if memory allocation failed." }
{ $warning "Don't forget to deallocate the memory with a call to " { $link free } "." } ;

HELP: realloc
{ $values { "alien" c-ptr } { "size" "a non-negative integer" } { "newalien" c-ptr } }
{ $description "Allocates a new block of " { $snippet "size" } " bytes from the operating system. The contents of " { $snippet "alien" } ", which itself must be a block previously returned by " { $link malloc } " or " { $link realloc } ", are copied into the new block, and the old block is freed." }
{ $errors "Throws an error if memory allocation failed." }
{ $warning "Don't forget to deallocate the memory with a call to " { $link free } "." } ;

HELP: memcpy
{ $values { "dst" c-ptr } { "src" c-ptr } { "size" "a non-negative integer" } }
{ $description "Copies " { $snippet "size" } " bytes from " { $snippet "src" } " to " { $snippet "dst" } "." }
{ $warning "As per the BSD C library documentation, the behavior is undefined if the source and destination overlap." } ;

HELP: check-ptr
{ $values { "c-ptr" "an alien address, byte array, or " { $link f } } { "checked" "an alien address or byte array with non-zero address" } }
{ $description "Throws an error if the input is " { $link f } ". Otherwise the object remains on the data stack. This word should be used to check the return values of " { $link malloc } " and " { $link realloc } " before use." }
{ $error-description "Callers of " { $link malloc } " and " { $link realloc } " should use " { $link check-ptr } " to throw an error in the case of a memory allocation failure." } ;

HELP: free
{ $values { "alien" c-ptr } }
{ $description "Deallocates a block of memory allocated by " { $link malloc } ", " { $link calloc } " or " { $link realloc } "." } ;

HELP: with-malloc
{ $values { "size" "a positive integer" } { "quot" "a quotation with stack effect " { $snippet "( c-ptr -- )" } } }
{ $description "Allocates a zeroed block of " { $snippet "n" } " bytes and passes it to the quotation. When the quotation returns, the block is freed." } ;

! Defined in alien-docs.factor
ABOUT: "malloc"
