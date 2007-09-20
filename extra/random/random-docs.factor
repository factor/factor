USING: help.markup help.syntax math ;
IN: random

ARTICLE: "random-numbers" "Generating random integers"
"The " { $vocab-link "random" } " vocabulary implements the ``Mersenne Twister'' pseudo-random number generator algorithm."
{ $subsection init-random }
{ $subsection (random) }
{ $subsection random } ;

ABOUT: "random-numbers"

HELP: init-random
{ $values { "seed" integer } }
{ $description "Initializes the random number generator with the given seed. This word is called on startup to initialize the random number generator with the current time." } ;

HELP: (random)
{ $values { "rand" "an integer between 0 and 2^32-1" } }
{ $description "Generates a random 32-bit unsigned integer." } ;

HELP: random
{ $values { "seq" "a sequence" } { "elt" "a random element" } }
{ $description "Outputs a random element of the sequence. If the sequence is empty, always outputs " { $link f } "." }
{ $notes "Since integers are sequences, passing an integer " { $snippet "n" } " yields a random integer in the interval " { $snippet "[0,n)" } "." } ;
