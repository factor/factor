USING: help.markup help.syntax debugger sequences kernel ;
IN: memory

ARTICLE: "memory" "Object memory"
"You can query memory status:"
{ $subsection data-room }
{ $subsection code-room }
"There are a pair of combinators, analogous to " { $link each } " and " { $link subset } ", which operate on the entire collection of objects in the object heap:"
{ $subsection each-object }
{ $subsection instances }
"You can check an object's the heap memory usage:"
{ $subsection size }
"The garbage collector can be invoked manually:"
{ $subsection data-gc }
{ $subsection code-gc }
"The current image can be saved:"
{ $subsection save }
{ $subsection save-image }
{ $subsection save-image-and-exit }
{ $see-also "tools.memory" } ;

ABOUT: "memory"

HELP: begin-scan ( -- )
{ $description "Moves all objects to tenured space, disables the garbage collector, and resets the heap scan pointer to point at the first object in the heap. The " { $link next-object } " word can then be called to advance the heap scan pointer and return successive objects."
$nl
"This word must always be paired with a call to " { $link end-scan } "." }
{ $notes "This is a low-level facility and can be dangerous. Use the " { $link each-object } " combinator instead." } ;

HELP: next-object ( -- obj )
{ $values { "obj" object } }
{ $description "Outputs the object at the heap scan pointer, and then advances the heap scan pointer. If the end of the heap has been reached, outputs " { $link f } ". This is unambiguous since the " { $link f } " object is tagged immediate and not actually stored in the heap." }
{ $errors "Throws a " { $link heap-scan-error. } " if called outside a " { $link begin-scan } "/" { $link end-scan } " pair." }
{ $notes "This is a low-level facility and can be dangerous. Use the " { $link each-object } " combinator instead." } ;

HELP: end-scan ( -- )
{ $description "Finishes a heap iteration by re-enabling the garbage collector. This word must always be paired with a call to " { $link begin-scan } "." }
{ $notes "This is a low-level facility and can be dangerous. Use the " { $link each-object } " combinator instead." } ;

HELP: each-object
{ $values { "quot" "a quotation with stack effect " { $snippet "( obj -- )" } } }
{ $description "Applies a quotation to each object in the heap. The garbage collector is switched off while this combinator runs, so the given quotation must not allocate too much memory." }
{ $notes "This word is the low-level facility used to implement the " { $link instances } " word." } ;

HELP: instances
{ $values { "quot" "a quotation with stack effect " { $snippet "( obj -- ? )" } } { "seq" "a fresh sequence" } }
{ $description "Outputs a sequence of all objects in the heap which satisfy the quotation." }
{ $notes "This word relies on " { $link each-object } ", so in particular the garbage collector is switched off while it runs and the given quotation must not allocate too much memory." } ;

HELP: data-gc ( -- )
{ $description "Performs a full garbage collection." } ;

HELP: code-gc ( -- )
{ $description "Collects all generations up to and including tenured space, and also collects the code heap." } ;

HELP: gc-time ( -- n )
{ $values { "n" "a timestamp in milliseconds" } }
{ $description "Outputs the total time spent in garbage collection during this Factor session." } ;

HELP: data-room ( -- cards semi generations )
{ $values { "cards" "number of bytes reserved for card marking" } { "semi" "number of bytes reserved for tenured semi-space" } { "generations" "array of free/total bytes pairs" } }
{ $description "Queries the runtime for memory usage information." } ;

HELP: code-room ( -- code-free code-total )
{ $values { "code-free" "bytes free in the code heap" } { "code-total" "total bytes in the code heap" } }
{ $description "Queries the runtime for memory usage information." } ;

HELP: size ( obj -- n )
{ $values { "obj" "an object" } { "n" "a size in bytes" } }
{ $description "Outputs the size of the object in memory, in bytes. Tagged immediate objects such as fixnums and " { $link f } " will yield a size of 0." } ;

HELP: save-image ( path -- )
{ $values { "path" "a pathname string" } }
{ $description "Saves a snapshot of the heap to the given file, overwriting the file if it already exists." } ;

HELP: save-image-and-exit ( path -- )
{ $values { "path" "a pathname string" } }
{ $description "Saves a snapshot of the heap to the given file, overwriting the file if it already exists. This word compacts the code heap and immediately exits Factor, since the Factor VM cannot continue executing after compiled code blocks have been moved around." } ;

{ save save-image save-image-and-exit } related-words

HELP: save
{ $description "Saves a snapshot of the heap to the current image file." } ;
