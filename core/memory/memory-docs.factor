USING: help.markup help.syntax kernel ;
IN: memory

HELP: instances
{ $values { "quot" { $quotation ( obj -- ? ) } } { "seq" "a fresh sequence" } }
{ $description "Outputs a sequence of all objects in the heap which satisfy the quotation." } ;

HELP: gc
{ $description "Performs a full garbage collection." } ;

HELP: size
{ $values { "obj" object } { "n" "a size in bytes" } }
{ $description "Outputs the size of the object in memory, in bytes. Tagged immediate objects such as fixnums and " { $link f } " will yield a size of 0." } ;

HELP: save-image
{ $values { "path" "a pathname string" } }
{ $description "Saves a snapshot of the heap to the given file, overwriting the file if it already exists." } ;

HELP: save-image-and-exit
{ $values { "path" "a pathname string" } }
{ $description "Saves a snapshot of the heap to the given file, overwriting the file if it already exists. This word compacts the code heap and immediately exits Factor, since the Factor VM cannot continue executing after compiled code blocks have been moved around." } ;

{ save save-image save-image-and-exit } related-words

HELP: save
{ $description "Saves a snapshot of the heap to the current image file." } ;

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
