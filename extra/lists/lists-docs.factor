! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.

IN: lists
USING: help.markup help.syntax ;

{ car cons cdr nil nil? list? uncons } related-words

HELP: cons 
{ $values { "car" "the head of the lazy list" } { "cdr" "the tail of the lazy list" } { "cons" "a cons object" } }
{ $description "Constructs a cons cell." } ;

HELP: car
{ $values { "cons" "a cons object" } { "car" "the first item in the list" } }
{ $description "Returns the first item in the list." } ;

HELP: cdr
{ $values { "cons" "a cons object" } { "cdr" "a cons object" } }
{ $description "Returns the tail of the list." } ;

HELP: nil 
{ $values { "cons" "An empty cons" } }
{ $description "Returns a representation of an empty list" } ;

HELP: nil? 
{ $values { "cons" "a cons object" } { "?" "a boolean" } }
{ $description "Return true if the cons object is the nil cons." } ;

HELP: list? ( object -- ? )
{ $values { "object" "an object" } { "?" "a boolean" } }
{ $description "Returns true if the object conforms to the list protocol." } ;

{ 1list 2list 3list } related-words

HELP: 1list
{ $values { "obj" "an object" } { "cons" "a cons object" } }
{ $description "Create a list with 1 element." } ;

HELP: 2list
{ $values { "a" "an object" } { "b" "an object" } { "cons" "a cons object" } }
{ $description "Create a list with 2 elements." } ;

HELP: 3list
{ $values { "a" "an object" } { "b" "an object" } { "c" "an object" } { "cons" "a cons object" } }
{ $description "Create a list with 3 elements." } ;