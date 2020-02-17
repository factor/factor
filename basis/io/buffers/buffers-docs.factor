USING: alien byte-arrays destructors help.markup help.syntax
kernel math ;
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
    buffer-read-unsafe
    buffer-read-until
}
"Writing to the buffer:"
{ $subsections
    buffer-write1
    buffer-write
    buffer+
} ;

ABOUT: "buffers"

HELP: buffer
{ $class-description "The class of I/O buffers, which resemble FIFO queues, but are optimized for holding bytes, are have underlying storage allocated at a fixed address. Buffers must be de-allocated manually. It has the following slots:"
    { $slots
        { "size" "The total size, in bytes, of the buffer" }
        { "ptr" { "The " { $link c-ptr } " memory where data is stored" } }
        { "fill" "The fill pointer, a write index where new data is added" }
        { "pos" "The position, a read index where data is consumed" }
    }
} ;

HELP: <buffer>
{ $values { "n" "a non-negative integer" } { "buffer" buffer } }
{ $description "Allocates a buffer with an initial capacity of " { $snippet "n" } " bytes." } ;

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
{ $description "Collects a byte array of " { $snippet "n" } " bytes starting from the buffer's current position, and advances the position accordingly. If there are less than " { $snippet "n" } " bytes available, the output is truncated." }
{ $examples
  { $example
    "USING: alien destructors io.buffers kernel prettyprint ;"
    "5 100 <buffer> [ B{ 7 14 21 } binary-object pick buffer-write buffer-read ] with-disposal ."
    "B{ 7 14 21 }"
  }
} ;

HELP: buffer-length
{ $values { "buffer" buffer } { "n" "a non-negative integer" } }
{ $description "Outputs the number of unconsumed bytes in the buffer." }
{ $examples
  { $example
    "USING: alien destructors io.buffers kernel prettyprint ;"
    "100 <buffer> [ B{ 7 14 21 } binary-object pick buffer-write buffer-length ] with-disposal ."
    "3"
  }
} ;

HELP: buffer-capacity
{ $values { "buffer" buffer } { "n" "a non-negative integer" } }
{ $description "Outputs the buffer's maximum capacity before growing." }
{ $examples
  { $example
    "USING: destructors io.buffers prettyprint ;"
    "100 <buffer> [ buffer-capacity ] with-disposal ."
    "100"
  }
} ;

HELP: buffer-empty?
{ $values { "buffer" buffer } { "?" boolean } }
{ $description "Tests if the buffer contains no more data to be read or written." } ;

HELP: buffer-write
{ $values { "c-ptr" c-ptr } { "n" fixnum } { "buffer" buffer } }
{ $description "Copies a " { $link c-ptr } " to the buffer's fill pointer, and advances it accordingly." }
{ $warning "This word will corrupt memory if writing more than the space available in the buffer." } ;

HELP: buffer-write1
{ $values { "byte" "a byte" } { "buffer" buffer } }
{ $description "Appends a single byte to a buffer." }
{ $warning "This word will corrupt memory if the buffer is full." }
{ $examples
  { $example
    "USING: destructors io.buffers kernel prettyprint ;"
    "100 <buffer> [ 237 over buffer-write1 buffer-pop ] with-disposal ."
    "237"
  }
} ;

HELP: buffer+
{ $values { "n" "a non-negative integer" } { "buffer" buffer } }
{ $description "Advances the fill pointer by " { $snippet "n" } " bytes." }
{ $warning "This word will leave the buffer in an invalid state if it does not have " { $snippet "n" } " bytes available." } ;

HELP: buffer-peek
{ $values { "buffer" buffer } { "byte" "a byte" } }
{ $description "Outputs the byte at the buffer position." } ;

HELP: buffer-pop
{ $values { "buffer" buffer } { "byte" "a byte" } }
{ $description "Outputs the byte at the buffer position and advances the position." } ;
