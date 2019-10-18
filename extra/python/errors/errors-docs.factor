USING: math help.markup help.syntax python.ffi ;
IN: python.errors

HELP: check-zero
{ $values { "code" integer } }
{ $description
  "Verifies that the return code is 0 and throws an error otherwise."
} ;

HELP: (check-ref)
{ $values { "ref" "a python object" } }
{ $description
  "Verifies that the reference is not f and throws an error if it is."
} ;

HELP: check-new-ref
{ $values { "ref" "a python object" } }
{ $description
  "Adds reference counting to the returned python object which is assumed to be a new reference. An error is thrown if the object is f. This word is used to wrap Python functions that return new references."
} ;

HELP: check-borrowed-ref
{ $values { "ref" "a python object" } }
{ $description
  "Adds reference counting to the returned python object which is assumed to be a borrowed reference. An error is thrown if the object is f. This word is used to wrap Python functions that return borrowed references."
} ;

HELP: unsteal-ref
{ $values { "ref" "a python object" } }
{ $description
  "Unsteals a reference. Used by wrappers that call Python functions that steal references. Functions such as " { $link PyTuple_SetItem } " takes ownership of the references passed in and relieves Factor of its burden to decrement them." } ;
