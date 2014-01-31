IN: python
USING: python help.markup help.syntax ;

ARTICLE: "python" "Python binding"
"The " { $vocab-link "python" } " vocab and its subvocabs implements a simple binding for libpython, allowing factor code to call native python."
$nl
"Initialization and finalization:"
{ $subsections py-initialize py-finalize }
"Module management:"
{ $subsections import } ;

HELP: py-initialize
{ $description "Initializes the python binding. This word must be called before any other words in the api can be used" } ;

HELP: py-finalize
{ $description "Finalizes the python binding. After this word is called the api must not be used anymore." } ;

HELP: >py
{ $values { "obj" "a factor object" } { "py-obj" "a python object" } }
{ $description "Converts a factor objects to its most fitting python representation." }
{ $examples
  { $example
    "USING: python ;"
    "10 iota >array >py >factor ."
    "{ 0 1 2 3 4 5 6 7 8 9 }"
  }
}
{ $see-also >factor } ;
