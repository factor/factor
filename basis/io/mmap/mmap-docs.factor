USING: help.markup help.syntax alien math continuations
destructors ;
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
{ $contract "Opens a file and maps its contents into memory, passing the " { $link mapped-file } " instance to the quotation. The mapped file is disposed of when the quotation returns, or if an error is thrown." }
{ $notes "This is a low-level word, because " { $link mapped-file } " objects simply expose their base address and length. Most applications should use " { $link "io.mmap.arrays" } " instead." }
{ $errors "Throws an error if a memory mapping could not be established." } ;

HELP: close-mapped-file
{ $values { "mmap" mapped-file } }
{ $contract "Releases system resources associated with the mapped file. This word should not be called by user code; use " { $link dispose } " instead." }
{ $errors "Throws an error if a memory mapping could not be established." } ;

ARTICLE: "io.mmap.arrays" "Memory-mapped arrays"
"Mapped file can be viewed as a sequence using the words in sub-vocabularies of " { $vocab-link "io.mmap" } ". For each primitive C type " { $snippet "T" } ", a set of words are defined in the vocabulary named " { $snippet "io.mmap.T" } ":"
{ $table
    { { $snippet "<mapped-T-array>" } { "Wraps a " { $link mapped-file } " in a sequence; stack effect " { $snippet "( mapped-file -- direct-array )" } } }
    { { $snippet "with-mapped-T-file" } { "Maps a file into memory and wraps it in a sequence by combining " { $link with-mapped-file } " and " { $snippet "<mapped-T-array>" } "; stack effect " { $snippet "( path quot -- )" } } }
}
"The primitive C types for which mapped arrays exist:"
{ $list
    { $snippet "char" }
    { $snippet "uchar" }
    { $snippet "short" }
    { $snippet "ushort" }
    { $snippet "int" }
    { $snippet "uint" }
    { $snippet "long" }
    { $snippet "ulong" }
    { $snippet "longlong" }
    { $snippet "ulonglong" }
    { $snippet "float" }
    { $snippet "double" }
    { $snippet "void*" }
    { $snippet "bool" }
} ;

ARTICLE: "io.mmap.low-level" "Reading and writing mapped files directly"
"Data can be read and written from the " { $link mapped-file } " by applying low-level alien words to the " { $slot "address" } " slot. See " { $link "reading-writing-memory" } "." ;

ARTICLE: "io.mmap.examples" "Memory-mapped file example"
"Convert a file of 4-byte cells from little to big endian or vice versa, by directly mapping it into memory and operating on it with sequence words:"
{ $code
    "USING: accessors grouping io.files io.mmap.char kernel sequences ;"
    "\"mydata.dat\" ["
    "    4 <sliced-groups> [ reverse-here ] change-each"
    "] with-mapped-char-file"
} ;

ARTICLE: "io.mmap" "Memory-mapped files"
"The " { $vocab-link "io.mmap" } " vocabulary implements support for memory-mapped files."
{ $subsection <mapped-file> }
"Memory-mapped files are disposable and can be closed with " { $link dispose } " or " { $link with-disposal } "."
{ $subsection "io.mmap.examples" }
"A utility combinator which wraps the above:"
{ $subsection with-mapped-file }
"Instances of " { $link mapped-file } " don't support any interesting operations in themselves. There are two facilities for accessing their contents:"
{ $subsection "io.mmap.arrays" }
{ $subsection "io.mmap.low-level" } ;

ABOUT: "io.mmap"
