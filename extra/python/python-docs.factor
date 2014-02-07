IN: python
USING: python help.markup help.syntax ;

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

ARTICLE: "python" "Python binding"
"The " { $vocab-link "python" } " vocab and its subvocabs implements a simple binding for libpython, allowing factor code to call native python."
$nl
"Initialization and finalization:"
{ $subsections py-initialize py-finalize }
"Module management:"
{ $subsections import }
"The vocab " { $vocab-link "python.syntax" } " implements a higher level factorific interface on top of the lower-level constructs in this vocab. Prefer to use that vocab most of the time."
{ $notes "Sometimes the embedded python interpreter can't find or finds the wrong load path to it's module library. To counteract that problem it is recommended that the " { $snippet "PYTHONHOME" } " environment variable is set before " { $link py-initialize } " is called. E.g:" }
{ $code "\"C:/python27-64bit/\" \"PYTHONHOME\" set-os-env" } ;
