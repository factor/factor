IN: python.errors
USING: python.errors help.markup help.syntax ;

HELP: check-zero
{ $description
  "Verifies that the return code is 0 and throws an error otherwise."
} ;

HELP: (check-ref)
{ $description
  "Verifies that the reference is not f and throws an error if it is."
} ;

HELP: check-new-ref
{ $description
  "Adds reference counting to the returned python object which is assumed to be a new reference. An error is thrown if the object is f. This word is used to wrap Python functions that return new references."
} ;

HELP: check-borrowed-ref
{ $description
  "Adds reference counting to the returned python object which is assumed to be a borrowed reference. An error is thrown if the object is f. This word is used to wrap Python functions that return borrowed references."
} ;

HELP: unsteal-ref
{ $description
  "Increases the objects reference count. Used by wrappers that call Python functions that steal references."
} ;
