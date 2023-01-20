! Copyright (C) 2020 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: destructors help.markup help.syntax kernel math sodium sodium.ffi
quotations ;
IN: sodium.secure-memory

ABOUT: "sodium.secure-memory"

ARTICLE: "sodium.secure-memory" "Secure memory"
"The " { $vocab-link "sodium.secure-memory" } " vocab provides a simple wrapper around some of the libsodium's Secure memory functions, see " { $url "https://libsodium.gitbook.io/doc/memory_management" } "." $nl
"The class for securely allocated alien memory:"
{ $subsections secure-memory new-secure-memory with-new-secure-memory }
"Temporary memory access combinators:"
{ $subsections with-read-access with-write-access }
"Memory access restriction setters:"
{ $subsections allow-no-access allow-read-access allow-write-access } ;

HELP: secure-memory
{ $class-description "The " { $link disposable } " class wrapping some secure memory allocated by libsodium. This class has two slots:"
  { $list
    { { $slot "underlying" } " - pointer to memory allocated by libsodium's " { $link sodium_malloc } ";" }
    { { $slot "size" } " - memory block size in bytes." }
  }
  "New instances must be constructed with " { $link new-secure-memory } " or using " { $link clone } ". The cloned objects have an independent copy of a newly allocated secure memory block (deep copy), so read access to the source memory must be granted prior to cloning. The cloned memory doesn't inherit the current access right of the source, instead it starts with the same access rights which are normally granted by calling " { $link new-secure-memory } "." } ;

HELP: new-secure-memory
{ $values
  { "size" integer }
  { "obj" secure-memory }
}
{ $description "Allocates a new instance of " { $link secure-memory } " with " { $snippet "size" } " bytes of freshly allocated alien memory pointed by the " { $slot "underlying" } " slot. Follow the " { $link "destructors-using" } " protocol to release the memory." $nl
  "In case the memory could not be allocated, " { $link sodium-malloc-error } " is thrown." $nl
  "Initial memory contents are not zero, see documentation at " { $url "https://libsodium.gitbook.io/doc/memory_management" } ". The memory is initially in the read-write mode, but is protected against swapping out by the OS (if supported) and against out of boundary access. Call " { $link allow-no-access } " to restrict access after your own initialization." } ;

HELP: with-new-secure-memory
{ $values
  { "size" number }
  { "quot" { $quotation ( ..a secure-memory -- ..b ) } }
}
{ $description "Call " { $snippet "quot" } " with a newly allocated " { $link secure-memory } " instance of the given " { $snippet "size" } ". When the quotation is called, the memory is writable. After the call the access is restricted using " { $link allow-no-access } ". This combinator is especially useful when you need to initialize and lock a new memory region. The " { $snippet "quot" } " should save a reference to the memory for subsequent disposal." } ;

{ new-secure-memory with-new-secure-memory } related-words

HELP: allow-no-access
{ $values
    { "secure-memory" secure-memory }
}
{ $description "Disable both read and write access to the " { $snippet "secure-memory" } ". Any subsequent access to the memory will raise a memory protection exception." } ;

HELP: allow-read-access
{ $values
  { "secure-memory" secure-memory }
}
{ $description "Allow read-only access to the " { $snippet "secure-memory" } ". Any subsequent write to the memory will raise a memory protection exception." } ;

HELP: allow-write-access
{ $values
    { "secure-memory" secure-memory }
}
{ $description "Allow read and write access to the " { $snippet "secure-memory" } "." } ;

HELP: with-read-access
{ $values
  { "secure-memory" secure-memory }
  { "quot" { $quotation ( ..a secure-memory -- ..b ) } }
}
{ $description "Temporarily allow read-only access to the " { $snippet "secure-memory" } " for the duration of the " { $snippet "quot" } " call. When the quotation terminates, disable the access using " { $link allow-no-access } "." } ;

HELP: with-write-access
{ $values
  { "secure-memory" secure-memory }
  { "quot" { $quotation ( ..a secure-memory -- ..b ) } }
}
{ $description "Temporarily allow read and write access to the " { $snippet "secure-memory" } " for the duration of the " { $snippet "quot" } " call. When the quotation terminates, disable the access using " { $link allow-no-access } "." } ;

{
    allow-no-access allow-read-access allow-write-access
    with-read-access with-write-access
} related-words

HELP: secure-memory=
{ $values
  { "a" secure-memory }
  { "b" secure-memory }
  { "?" boolean }
}
{ $description "Compare the memory contents of the two memory regions and return " { $link t } " on full match. Both regions must be allocated, have equal " { $slot "size" } ", and the read access to the memory should be allowed." }
{ $notes "Comparison of secure memory blocks of equal size is performed in constant time using " { $link sodium_memcmp } "." } ;
