USING: help.markup help.syntax debugger sequences kernel
quotations math ;
IN: memory

HELP: begin-scan ( -- )
{ $description "Disables the garbage collector and resets the heap scan pointer to point at the first object in the heap. The " { $link next-object } " word can then be called to advance the heap scan pointer and return successive objects."
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
{ $values { "quot" { $quotation "( obj -- )" } } }
{ $description "Applies a quotation to each object in the heap. The garbage collector is switched off while this combinator runs, so the given quotation must not allocate too much memory." }
{ $notes "This word is the low-level facility used to implement the " { $link instances } " word." } ;

HELP: instances
{ $values { "quot" { $quotation "( obj -- ? )" } } { "seq" "a fresh sequence" } }
{ $description "Outputs a sequence of all objects in the heap which satisfy the quotation." }
{ $notes "This word relies on " { $link each-object } ", so in particular the garbage collector is switched off while it runs and the given quotation must not allocate too much memory." } ;

HELP: gc ( -- )
{ $description "Performs a full garbage collection." } ;

HELP: data-room ( -- cards decks generations )
{ $values { "cards" "number of kilobytes reserved for card marking" } { "decks" "number of kilobytes reserved for decks of cards" } { "generations" "array of free/total kilobytes pairs" } }
{ $description "Queries the runtime for memory usage information." } ;

HELP: code-room ( -- code-total code-used code-free largest-free-block )
{ $values { "code-total" "total kilobytes in the code heap" } { "code-used" "kilobytes used in the code heap" } { "code-free" "kilobytes free in the code heap" } { "largest-free-block" "size of largest free block" } }
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

HELP: count-instances
{ $values
     { "quot" quotation }
     { "n" integer } }
{ $description "Applies the predicate quotation to each object in the heap and returns the number of objects that match. Since this word uses " { $link each-object } " with the garbage collector switched off, avoid allocating too much memory in the quotation." }
{ $examples { $unchecked-example
    "USING: memory words prettyprint ;"
    "[ word? ] count-instances ."
    "24210"
} } ;

ARTICLE: "images" "Images"
"Factor has the ability to save the entire state of the system into an " { $emphasis "image file" } ". The image contains a complete dump of all data and code in the current Factor instance."
{ $subsections
    save
    save-image
    save-image-and-exit
}
"To start Factor with a custom image, use the " { $snippet "-i=" { $emphasis "image" } } " command line switch; see " { $link "runtime-cli-args" } "."
$nl
"One reason to save a custom image is if you find yourself loading the same libraries in every Factor session; some libraries take a little while to compile, so saving an image with those libraries loaded can save you a lot of time."
$nl
"For example, to save an image with the web framework loaded,"
{ $code "USE: furnace" "save" }
"New images can be created from scratch:"
{ $subsections "bootstrap.image" }
"The " { $link "tools.deploy" } " tool creates stripped-down images containing just enough code to run a single application."
{ $see-also "tools.memory" } ;

ABOUT: "images"
