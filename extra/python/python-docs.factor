USING: alien destructors help.markup help.syntax quotations ;
IN: python

HELP: py-initialize
{ $description "Initializes the python binding. This word must be called before any other words in the api can be used" } ;

HELP: py-finalize
{ $description "Finalizes the python binding. After this word is called the api must not be used anymore." } ;

HELP: >py
{ $values { "obj" "a factor object" } { "py-obj" "a python object" } }
{ $description "Converts a factor objects to its most fitting python representation." }
{ $examples
  { $unchecked-example
    "USING: arrays prettyprint python sequences ;"
    "10 <iota> >array >py py> ."
    "{ 0 1 2 3 4 5 6 7 8 9 }"
  }
}
{ $see-also py> } ;

HELP: quot>py-callback
{ $values { "quot" { $quotation ( args kw -- ret ) } } { "alien" alien } }
{ $description "Creates a python-compatible alien callback from a quotation." }
{ $examples
  "This is how you create a callback which returns the double of its first positional parameter:"
  { $unchecked-example
    "USING: python ;"
    ": double-fun ( -- alien ) [ drop first 2 * ] quot>py-callback ;"
  }
} ;

HELP: with-quot>py-cfunction
{ $values { "alien" alien } { "quot" quotation } }
{ $description "Wrapper for " { $link with-callback } " to be used when passing functions as arguments to Python functions. It should be used in conjunction with " { $link quot>py-callback } " which creates the callbacks this word consumes." } ;

HELP: python-error
{ $error-description "When Python throws an exception, it is translated to this Factor error. " { $slot "type" } " is the class name of the python exception object, " { $slot "message" } " its string and " { $slot "traceback" } " a sequence of traceback lines, if the error has one, or " { $link f } " otherwise." } ;

ARTICLE: "python" "Python binding"
"The " { $vocab-link "python" } " vocab and its subvocabs implements a simple binding for libpython, allowing factor code to call native python."
$nl
"Converting to and from Python:"
{ $subsections >py py> quot>py-callback }
"Error handling:"
{ $subsections python-error }
"Initialization and finalization:"
{ $subsections py-initialize py-finalize }
"Module management:"
{ $subsections py-import }
"The vocab " { $vocab-link "python.syntax" } " implements a higher level factorific interface on top of the lower-level constructs in this vocab. Prefer to use that vocab most of the time."
{ $notes "Sometimes the embedded python interpreter can't find or finds the wrong load path to it's module library. To counteract that problem it is recommended that the " { $snippet "PYTHONHOME" } " environment variable is set before " { $link py-initialize } " is called. E.g:" }
{ $code "\"C:/python27-64bit/\" \"PYTHONHOME\" set-os-env" }
{ $warning "All code that calls Python words should always be wrapped in a " { $link with-destructors } " context. The reason is that the words add references to Pythons internal memory heap which are removed when the destructors trigger." } ;

ABOUT: "python"
