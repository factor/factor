! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;

IN: lists

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
    
HELP: lnth
{ $values { "n" "an integer index" } { "list" "a cons object" } { "elt" "the element at the nth index" } }
{ $description "Outputs the nth element of the list." } 
{ $see-also llength cons car cdr } ;

HELP: llength
{ $values { "list" "a cons object" } { "n" "a non-negative integer" } }
{ $description "Outputs the length of the list. This should not be called on an infinite list." } 
{ $see-also lnth cons car cdr } ;

HELP: uncons
{ $values { "cons" "a cons object" } { "car" "the head of the list" } { "cdr" "the tail of the list" } }
{ $description "Put the head and tail of the list on the stack." } ;

HELP: leach
{ $values { "list" "a cons object" } { "quot" "a quotation with stack effect ( obj -- )" } }
{ $description "Call the quotation for each item in the list." } ;

HELP: lreduce
{ $values { "list" "a cons object" } { "identity" "an object" } { "quot" "a quotation with stack effect ( prev elt -- next )" } { "result" "the final result" } }
{ $description "Combines successive elements of the list using a binary operation, and outputs the final result." } ;

HELP: uncons
{ $values { "cons" "a cons object" } { "car" "the head of the list" } { "cdr" "the tail of the list" } }
{ $description "Put the head and tail of the list on the stack." } ;

{ leach lreduce lmap } related-words

HELP: leach
{ $values { "list" "a cons object" } { "quot" "a quotation with stack effect ( obj -- )" } }
{ $description "Call the quotation for each item in the list." } ;

HELP: lreduce
{ $values { "list" "a cons object" } { "identity" "an object" } { "quot" "a quotation with stack effect ( prev elt -- next )" } { "result" "the final result" } }
{ $description "Combines successive elements of the list using a binary operation, and outputs the final result." } ;

