USING: help help.markup help.syntax kernel math ;
IN: shuffle

M: shuffle-word word-help* drop { $shuffle } ;

HELP: nreverse
{ $values { "n" integer } }
{ $description "Reverses the order of the top " { $snippet "n" } " stack elements." }
{ $examples
  { $example
    "USING: arrays shuffle prettyprint ;"
    "10 20 30 40 4 nreverse 4array ."
    "{ 40 30 20 10 }"
  }
} ;
