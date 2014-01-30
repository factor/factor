IN: python.syntax
USING: python.syntax help.markup help.syntax ;

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
    "\"name-of-zip.zip\" >py \"r\" >py ZipFile namelist >factor"
  }
} ;
