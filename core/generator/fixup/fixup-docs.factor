USING: help.syntax help.markup generator.fixup math kernel
words strings alien ;

HELP: frame-required
{ $values { "n" "a non-negative integer" } }
{ $description "Notify the code generator that the currently compiling code block needs a stack frame with room for at least " { $snippet "n" } " parameters." } ;

HELP: (rel-fixup)
{ $values { "arg" integer } { "class" "a relocation class" } { "type" "a relocation type" } { "offset" integer } { "pair" "a pair of integers" } }
{ $description "Creates a relocation instruction for the VM's runtime compiled code linker." } ;

HELP: add-literal
{ $values { "obj" object } { "n" integer } }
{ $description "Adds a literal to the " { $link literal-table } ", if it is not already there, and outputs the index of the literal in the table. This literal can then be used as an argument for a " { $link rt-literal } " relocation with " { $link rel-fixup } "." } ;

HELP: word-table
{ $var-description "Holds a vector of words called from the currently compiling word." } ;

HELP: add-word
{ $values { "word" word } { "n" integer } }
{ $description "Adds a word to the " { $link word-table } ", if it is not already there, and outputs the index of the word in the table. This literal can then be used as an argument for a " { $link rt-xt } " relocation with " { $link rel-fixup } "." } ;

HELP: string>symbol
{ $values { "str" string } { "alien" alien } }
{ $description "Converts the string to a format which is a valid symbol name for the Factor VM's compiled code linker. By performing this conversion ahead of time, the image loader can run without allocating memory."
$nl
"On Windows CE, symbols are represented as UCS2 strings, and on all other platforms they are ASCII strings." } ;

HELP: rel-dlsym
{ $values { "name" string } { "dll" "a " { $link dll } " or " { $link f } } { "class" "a relocation class" } }
{ $description "Records that the most recently assembled instruction contains a reference to the " { $snippet "name" } " symbol from " { $snippet "dll" } ". The correct " { $snippet "class" } " to use depends on instruction formats."
} ;
