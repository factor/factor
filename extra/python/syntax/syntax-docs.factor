IN: python.syntax
USING: hashtables python.syntax help.markup help.syntax ;

HELP: PY-FROM:
{ $syntax "PY-FROM: module => name-effects ;" }
{ $values
  { "module" "fully qualified name of a python module" }
  { "name-effects" "pairs of names and effect declarations of bindings to import" }
}
{ $description
  "Creates factor words that maps to the given python objects."
}
{ $examples
  { $code
    "PY-FROM: os.path => isfile ( path -- ? ) splitext ( path -- root ext ) ;"
  }
} ;

HELP: PY-QUALIFIED-FROM:
{ $syntax "PY-QUALIFIED-FROM: module => name-effects ;" }
{ $values
  { "module" "fully qualified name of a python module" }
  { "name-effects" "pairs of names and effect declarations of bindings to import" }
}
{ $description
  "Like " { $link \ PY-FROM: } " except all words are created with module as the given prefix."
} ;

HELP: PY-METHODS:
{ $syntax "PY-METHODS: class => name-effects ;" }
{ $values
  { "class" "name of a class to associate the bindings with" }
  { "name-effects" "pairs of names and effect declarations of methods to create" }
}
{ $description
  "Creates factor words that acts as properties and getters and can work on any python object."
}
{ $examples
  { $code
    "PY-FROM: zipfile => ZipFile ( name mode -- file ) ;"
    "PY-METHODS: ZipFile => namelist ( self -- names ) ;"
    "! Then use the declarations like this"
    "\"name-of-zip.zip\" >py \"r\" >py ZipFile namelist py>"
  }
} ;

ARTICLE: "python.syntax" "Syntax for python calls from factor"
"The " { $vocab-link "python.syntax" } " vocab adds syntax to factor to make calls from factor to python natural and intuitive."
{ $subsections \ PY-FROM: \ PY-QUALIFIED-FROM: \ PY-METHODS: }
$nl
{ $examples "Here is how you bind and call a method namelist on a ZipFile instance created by importing the zipfile module:"
  { $code
    "PY-FROM: zipfile => ZipFile ( name mode -- file ) ;"
    "PY-METHODS: ZipFile => namelist ( self -- names ) ;"
    "! Then use the declarations like this"
    "\"name-of-zip.zip\" >py \"r\" >py ZipFile namelist py>"
  }
  "In python, a method or function takes keyword arguments if its last parameter starts with \"**\". If the name of the last argument to a declared function is \"**\" then a " { $link hashtable } " can be sent to the function:"
  { $code
    "PY-FROM: datetime => timedelta ( ** -- timedelta ) ;"
    "PY-METHODS: timedelta => seconds ( self -- n ) ;"
    "H{ { \"hours\" 99 } { \"minutes\" 33 } } >py timedelta $seconds py> ."
    "12780"
    }
} ;

ABOUT: "python.syntax"
