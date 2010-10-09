USING: help.markup help.syntax byte-arrays alien destructors ;
IN: io.buffers

ARTICLE: "buffers" "Locked I/O buffers"
"I/O buffers are first-in-first-out queues of bytes."
$nl
"Buffers are backed by manually allocated storage that does not get moved by the garbage collector; they are also low-level and sacrifice error checking for efficiency."
$nl
"Buffers are used to implement native I/O backends."
$nl
"Buffer words are found in the " { $vocab-link "io.buffers" } " vocabulary."
{ $subsections
    buffer
    <buffer>
}
"Buffers must be manually deallocated by calling " { $link dispose } "."
$nl
"Buffer operations:"
{ $subsections
    buffer-reset
    buffer-length
    buffer-empty?
    buffer-capacity
    buffer@
}
"Reading from the buffer:"
{ $subsections
    buffer-peek
    buffer-pop
    buffer-read
}
"Writing to the buffer:"
{ $subsections
    byte>buffer
    >buffer
    n>buffer
} ;

ABOUT: "buffers"

HELP: buffer
{ $class-description "The class of I/O buffers, which resemble FIFO queues, but are optimized for holding bytes, are have underlying storage allocated at a fixed address. Buffers must be de-allocated manually."
$nl
"Buffers have two internal pointers:"
{ $list
    { { $snippet "fill" } " - the fill pointer, a write index where new data is added" }
    { { $snippet "pos" } " - the position, a read index where data is consumed" }
} } ;

HELP: <buffer>
{ $values { "n" "a non-negative integer" } { "buffer" buffer } }
{ $description "Creates a buffer with an initial capacity of " { $snippet "n" } " bytes." } ;

HELP: buffer-reset
{ $values { "n" "a non-negative integer" } { "buffer" buffer } }
{ $description "Resets the fill pointer to 0 and the position to " { $snippet "count" } "." } ;

HELP: buffer-consume
{ $values { "n" "a non-negative integer" } { "buffer" buffer } }
{ $description "Moves the position forward by " { $snippet "n" } " bytes. If it exceeds the fill pointer, both are reset to 0." } ;

HELP: buffer@
{ $values { "buffer" buffer } { "alien" alien } }
{ $description "Outputs the memory address of the current buffer position." } ;

HELP: buffer-end
{ $values { "buffer" buffer } { "alien" alien } }
{ $description "Outputs the memory address of the current fill-pointer." } ;

HELP: buffer-read
{ $values { "n" "a non-negative integer" } { "buffer" buffer } { "byte-array" byte-array } }
{ $description "Collects a byte array of " { $snippet "n" } " bytes starting from the buffer's current position, and advances the position accordingly. If there are less than " { $snippet "n" } " bytes available, the output is truncated." } ;

HELP: buffer-length
{ $values { "buffer" buffer } { "n" "a non-negative integer" } }
{ $description "Outputs the number of unconsumed bytes in the buffer." } ;

HELP: buffer-capacity
{ $values { "buffer" buffer } { "n" "a non-negative integer" } }
{ $description "Outputs the buffer's maximum capacity before growing." } ;

HELP: buffer-empty?
{ $values { "buffer" buffer } { "?" "a boolean" } }
{ $description "Tests if the buffer contains no more data to be read." } ;

HELP: >buffer
{ $values { "byte-array" byte-array } { "buffer" buffer } }
{ $description "Copies a byte array to the buffer's fill pointer, and advances it accordingly." }
{ $warning "This word will corrupt memory if the byte array is larger than the space available in the buffer." } ;

HELP: byte>buffer
{ $values { "byte" "a byte" } { "buffer" buffer } }
{ $description "Appends a single byte to a buffer." }
{ $warning "This word will corrupt memory if the buffer is full." } ;

HELP: n>buffer
{ $values { "n" "a non-negative integer" } { "buffer" buffer } }
{ $description "Advances the fill pointer by " { $snippet "n" } " bytes." }
{ $warning "This word will leave the buffer in an invalid state if it does not have " { $snippet "n" } " bytes available." } ;

HELP: buffer-peek
{ $values { "buffer" buffer } { "byte" "a byte" } }
{ $description "Outputs the byte at the buffer position." } ;

HELP: buffer-pop
{ $values { "buffer" buffer } { "byte" "a byte" } }
{ $description "Outputs the byte at the buffer position and advances the position." } ;
