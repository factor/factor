USING: help.markup help.syntax byte-arrays alien ;
IN: io.buffers

ARTICLE: "buffers" "Locked I/O buffers"
"I/O buffers are first-in-first-out queues of bytes. Their key feature is that they are backed by manually allocated storage that does not get moved by the garbage collector. They are used to implement native I/O backends."
$nl
"Buffer words are found in the " { $vocab-link "buffers" } " vocabulary."
{ $subsection buffer }
{ $subsection <buffer> }
"Buffers must be manually deallocated:"
{ $subsection buffer-free }
"Buffer operations:"
{ $subsection buffer-reset }
{ $subsection buffer-length }
{ $subsection buffer-empty? }
{ $subsection buffer-capacity }
{ $subsection buffer@ }
"Reading from the buffer:"
{ $subsection buffer-peek }
{ $subsection buffer-pop }
{ $subsection buffer-read }
"Writing to the buffer:"
{ $subsection extend-buffer }
{ $subsection byte>buffer }
{ $subsection >buffer }
{ $subsection n>buffer } ;

ABOUT: "buffers"

HELP: buffer
{ $class-description "The class of I/O buffers, which resemble FIFO queues, but are optimized for holding bytes, are have underlying storage allocated at a fixed address. Buffers must be de-allocated manually."
$nl
"Buffers have two internal pointers:"
{ $list
    { { $link buffer-fill } " - the fill pointer, a write index where new data is added" }
    { { $link buffer-pos } " - the position, a read index where data is consumed" }
} } ;

HELP: <buffer>
{ $values { "n" "a non-negative integer" } { "buffer" buffer } }
{ $description "Creates a buffer with an initial capacity of " { $snippet "n" } " bytes." } ;

HELP: buffer-free
{ $values { "buffer" buffer } }
{ $description "De-allocates a buffer's underlying storage. The buffer may not be used after being freed." }
{ $warning "You " { $emphasis "must" } " free a buffer using this word, before letting the GC collect the buffer tuple instance." } ;

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

HELP: (buffer-read)
{ $values { "n" "a non-negative integer" } { "buffer" buffer } { "byte-array" byte-array } }
{ $description "Outputs a byte array of the first " { $snippet "n" } " bytes at the buffer's current position. If there are less than " { $snippet "n" } " bytes available, the output is truncated." } ;

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

HELP: extend-buffer
{ $values { "n" "a non-negative integer" } { "buffer" buffer } }
{ $description "Grows a buffer to fit " { $snippet "n" } " bytes of data." } ;

HELP: check-overflow
{ $values { "n" "a non-negative integer" } { "buffer" buffer } }
{ $description "Grows the buffer, if possible, so it can accomodate " { $snippet "n" } " bytes." }
{ $warning "I/O system implementations should call this word or one of the other words that calls this word, at the beginning of an I/O transaction, when the buffer is empty. Buffers cannot be resized if they contain data; one of the requirements of a buffer is to remain fixed in memory while I/O operations are in progress." }
{ $errors "Throws an error if the buffer contains unread data, and the new data does not fit." } ;

HELP: >buffer
{ $values { "byte-array" byte-array } { "buffer" buffer } }
{ $description "Copies a byte array to the buffer's fill pointer, and advances it accordingly." } ;

HELP: byte>buffer
{ $values { "byte" "a byte" } { "buffer" buffer } }
{ $description "Appends a single byte to a buffer." } ;

HELP: n>buffer
{ $values { "n" "a non-negative integer" } { "buffer" buffer } }
{ $description "Advances the fill pointer by " { $snippet "n" } " bytes." }
{ $errors "Throws an error if the buffer does not contain " { $snippet "n" } " bytes of data." } ;

HELP: buffer-peek
{ $values { "buffer" buffer } { "byte" "a byte" } }
{ $description "Outputs the byte at the buffer position." } ;

HELP: buffer-pop
{ $values { "buffer" buffer } { "byte" "a byte" } }
{ $description "Outputs the byte at the buffer position and advances the position." } ;
