USING: help.markup help.syntax alien math ;
IN: io.mmap

HELP: mapped-file
{ $class-description "The class of memory-mapped files, opened by " { $link <mapped-file> } " and closed by " { $link close-mapped-file } ". The following two slots are of interest to users:"
    { $list
        { { $link mapped-file-length } " - the length of the mapped file area, in bytes" }
        { { $link mapped-file-address } " - an " { $link alien } " pointing at the file's memory area" }
    }
} ;

HELP: <mapped-file>
{ $values { "path" "a pathname string" } { "length" integer } { "mmap" mapped-file } }
{ $contract "Opens a file and maps the first " { $snippet "length" } " bytes into memory. The length is permitted to exceed the length of the file on disk, in which case the remaining space is padded with zero bytes." }
{ $notes "You must call " { $link close-mapped-file } " when you are finished working with the returned object, to reclaim resources. The " { $link with-mapped-file } " provides an abstraction which can close the mapped file for you." }
{ $errors "Throws an error if a memory mapping could not be established." } ;

HELP: (close-mapped-file)
{ $values { "mmap" mapped-file } }
{ $contract "Releases system resources associated with the mapped file. This word should not be called by user code; use " { $link close-mapped-file } " instead." }
{ $errors "Throws an error if a memory mapping could not be established." } ;

HELP: close-mapped-file
{ $values { "mmap" mapped-file } }
{ $description "Releases system resources associated with the mapped file." }
{ $errors "Throws an error if a memory mapping could not be established." } ;

ARTICLE: "io.mmap" "Memory-mapped files"
"The " { $vocab-link "io.mmap" } " vocabulary implements support for memory-mapped files."
{ $subsection <mapped-file> }
{ $subsection close-mapped-file }
"A combinator which wraps the above two words:"
{ $subsection with-mapped-file }
"Memory mapped files implement the " { $link "sequence-protocol" } " and present themselves as a sequence of bytes. The underlying memory area can also be accessed directly:"
{ $subsection mapped-file-address }
"Data can be read and written from the memory area using alien words. See " { $link "reading-writing-memory" } "." ;

ABOUT: "io.mmap"
