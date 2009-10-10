! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: classes help.markup help.syntax kernel quotations words
alien.marshall.structs strings alien.structs alien.marshall ;
IN: alien.marshall.structs

HELP: define-marshalled-struct
{ $values
    { "name" string } { "vocab" "a vocabulary specifier" } { "fields" "an alist" }
}
{ $description "Calls " { $link define-struct } " and " { $link define-struct-tuple } "." } ;

HELP: define-struct-tuple
{ $values
    { "name" string }
}
{ $description "Defines a subclass of " { $link struct-wrapper } ", a constructor, "
  "and accessor words."
} ;
