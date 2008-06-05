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
{ $values { "cons" "a cons object" }  { "cdr" "the tail of the list" } { "car" "the head of the list" } }
{ $description "Put the head and tail of the list on the stack." } ;

{ leach foldl lmap>array } related-words

HELP: leach
{ $values { "list" "a cons object" } { "quot" "a quotation with stack effect ( obj -- )" } }
{ $description "Call the quotation for each item in the list." } ;

HELP: foldl
{ $values { "list" "a cons object" } { "identity" "an object" } { "quot" "a quotation with stack effect ( prev elt -- next )" } { "result" "the final result" } }
{ $description "Combines successive elements of the list (in a left-assocative order) using a binary operation and outputs the final result." } ;

HELP: foldr
{ $values { "list" "a cons object" } { "identity" "an object" } { "quot" "a quotation with stack effect ( prev elt -- next )" } { "result" "the final result" } }
{ $description "Combines successive elements of the list (in a right-assocative order) using a binary operation, and outputs the final result." } ;

HELP: lmap
{ $values { "list" "a cons object" } { "quot" "a quotation with stack effect ( old -- new )" } { "result" "the final result" } }
{ $description "Applies the quotation to each element of the list in order, collecting the new elements into a new list." } ;
    
HELP: lreverse
{ $values { "list" "a cons object" } { "newlist" "a new cons object" } }
{ $description "Reverses the input list, outputing a new, reversed list" } ;
    
HELP: list>seq    
{ $values { "list" "a cons object" } { "array" "an array object" } }
{ $description "Turns the given cons object into an array, maintaing order." } ;
    
HELP: seq>list
{ $values { "array" "an array object" } { "list" "a cons object" } }
{ $description "Turns the given array into a cons object, maintaing order." } ;
    
HELP: cons>seq
{ $values { "cons" "a cons object" } { "array" "an array object" } }
{ $description "Recursively turns the given cons object into an array, maintaing order and also converting nested lists." } ;
    
HELP: seq>cons
{ $values { "seq" "a sequence object" } { "cons" "a cons object" } }
{ $description "Recursively turns the given sequence into a cons object, maintaing order and also converting nested lists." } ;
    
HELP: traverse    
{ $values { " list"  "a cons object" } { "pred" } { "a quotation with stack effect ( list/elt -- ? )" }
          { "quot" "a quotation with stack effect ( list/elt -- result)" }  { "result" "a new cons object" } }
{ $description "Recursively traverses the list object, replacing any elements (which can themselves be sublists) that " { $snippet pred }
    " returns true for with the result of applying " { $snippet quot } " to." } ;
    
