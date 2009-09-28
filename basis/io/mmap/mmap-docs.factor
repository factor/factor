USING: help.markup help.syntax alien math continuations
destructors specialized-arrays ;
IN: io.mmap

HELP: mapped-file
{ $class-description "The class of memory-mapped files, opened by " { $link <mapped-file> } " and closed by " { $link close-mapped-file } ". The following two slots are of interest to users:"
    { $list
        { { $snippet "length" } " - the length of the mapped file area, in bytes" }
        { { $snippet "address" } " - an " { $link alien } " pointing at the file's memory area" }
    }
} ;

HELP: <mapped-file>
{ $values { "path" "a pathname string" }  { "mmap" mapped-file } }
{ $contract "Opens a file and maps its contents into memory. The length is permitted to exceed the length of the file on disk, in which case the remaining space is padded with zero bytes." }
{ $notes "You must call " { $link dispose } " when you are finished working with the returned object, to reclaim resources. The " { $link with-mapped-file } " provides an abstraction which can close the mapped file for you." }
{ $errors "Throws an error if a memory mapping could not be established." } ;

HELP: with-mapped-file
{ $values { "path" "a pathname string" } { "quot" { $quotation "( mmap -- )" } } }
{ $contract "Opens a file for read/write access and maps its contents into memory, passing the " { $link mapped-file } " instance to the quotation. The mapped file is disposed of when the quotation returns, or if an error is thrown." }
{ $notes "This is a low-level word, because " { $link mapped-file } " objects simply expose their base address and length. Most applications should use " { $link "io.mmap.arrays" } " instead." }
{ $errors "Throws an error if a memory mapping could not be established." } ;

HELP: with-mapped-file-reader
{ $values { "path" "a pathname string" } { "quot" { $quotation "( mmap -- )" } } }
{ $contract "Opens a file for read-only access and maps its contents into memory, passing the " { $link mapped-file } " instance to the quotation. The mapped file is disposed of when the quotation returns, or if an error is thrown." }
{ $notes "This is a low-level word, because " { $link mapped-file } " objects simply expose their base address and length. See " { $link "io.mmap.arrays" } " for a discussion of how to access data in a mapped file." }
{ $errors "Throws an error if a memory mapping could not be established." } ;

HELP: close-mapped-file
{ $values { "mmap" mapped-file } }
{ $contract "Releases system resources associated with the mapped file. This word should not be called by user code; use " { $link dispose } " instead." }
{ $errors "Throws an error if a memory mapping could not be established." } ;

ARTICLE: "io.mmap.arrays" "Working with memory-mapped data"
"The " { $link <mapped-file> } " word returns an instance of " { $link mapped-file } ", which doesn't directly support the sequence protocol. Instead, it needs to be wrapped in a specialized array of the appropriate C type:"
{ $subsection <mapped-array> }
"The appropriate specialized array type must first be generated with " { $link POSTPONE: SPECIALIZED-ARRAY: } "."
$nl
"Data can also be read and written from the " { $link mapped-file } " by applying low-level alien words to the " { $slot "address" } " slot. This approach is not recommended, though, since in most cases the compiler will generate efficient code for specialized array usage. See " { $link "reading-writing-memory" } " for a description of low-level memory access primitives." ;

ARTICLE: "io.mmap.examples" "Memory-mapped file examples"
"Convert a file of 4-byte cells from little to big endian or vice versa, by directly mapping it into memory and operating on it with sequence words:"
{ $code
    "USING: alien.c-types grouping io.mmap sequences" "specialized-arrays ;"
    "SPECIALIZED-ARRAY: char"
    ""
    "\"mydata.dat\" ["
    "    char <mapped-array> 4 <sliced-groups>"
    "    [ reverse-here ] change-each"
    "] with-mapped-file"
}
"Normalize a file containing packed quadrupes of floats:"
{ $code
    "USING: kernel io.mmap math.vectors math.vectors.simd" "sequences specialized-arrays ;"
    "SIMD: float"
    "SPECIALIZED-ARRAY: float-4"
    ""
    "\"mydata.dat\" ["
    "    float-4 <mapped-array>"
    "    [ normalize ] change-each"
    "] with-mapped-file"
} ;

ARTICLE: "io.mmap" "Memory-mapped files"
"The " { $vocab-link "io.mmap" } " vocabulary implements support for memory-mapped files."
{ $subsection <mapped-file> }
"Memory-mapped files are disposable and can be closed with " { $link dispose } " or " { $link with-disposal } ". A utility combinator which wraps the above:"
{ $subsection with-mapped-file }
"Instances of " { $link mapped-file } " don't support any interesting operations in themselves. There are two facilities for accessing their contents:"
{ $subsection "io.mmap.arrays" }
{ $subsection "io.mmap.examples" } ;

ABOUT: "io.mmap"
