! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel help.markup help.syntax arrays sequences math quotations ;
IN: lists

ABOUT: "lists"

ARTICLE: "lists" "Lists"
"The " { $vocab-link "lists" } " vocabulary implements linked lists. There are simple strict linked lists, but a generic list protocol allows the implementation of lazy lists as well."
{ $subsection { "lists" "protocol" } }
{ $subsection { "lists" "strict" } }
{ $subsection { "lists" "manipulation" } }
{ $subsection { "lists" "combinators" } }
{ $vocab-subsection "Lazy lists" "lists.lazy" } ;

ARTICLE: { "lists" "protocol" } "The list protocol"
"Lists are instances of a mixin class"
{ $subsection list }
"Instances of the mixin must implement the following words:"
{ $subsection car }
{ $subsection cdr }
{ $subsection nil? } ;

ARTICLE: { "lists" "strict" } "Constructing strict lists"
"Strict lists are simply cons cells where the car and cdr have already been evaluated. These are the lists of Lisp. To construct a strict list, the following words are provided:"
{ $subsection cons }
{ $subsection swons }
{ $subsection sequence>cons }
{ $subsection deep-sequence>cons }
{ $subsection 1list }
{ $subsection 2list }
{ $subsection 3list } ;

ARTICLE: { "lists" "combinators" } "Combinators for lists"
"Several combinators exist for list traversal."
{ $subsection leach }
{ $subsection lmap }
{ $subsection foldl }
{ $subsection foldr }
{ $subsection lmap>array }
{ $subsection lmap-as }
{ $subsection traverse } ;

ARTICLE: { "lists" "manipulation" } "Manipulating lists"
"To get at the contents of a list:"
{ $subsection uncons }
{ $subsection unswons }
{ $subsection lnth }
{ $subsection cadr }
{ $subsection llength }
"To get a new list from an old one:"
{ $subsection lreverse }
{ $subsection lappend }
{ $subsection lcut } ;

HELP: cons 
{ $values { "car" "the head of the list cell" } { "cdr" "the tail of the list cell" } { "cons" "a cons object" } }
{ $description "Constructs a cons cell." } ;

HELP: swons 
{ $values { "cdr" "the tail of the list cell" } { "car" "the head of the list cell" } { "cons" "a cons object" } }
{ $description "Constructs a cons cell." } ;

{ cons swons uncons unswons } related-words

HELP: car
{ $values { "cons" "a cons object" } { "car" "the first item in the list" } }
{ $description "Returns the first item in the list." } ;

HELP: cdr
{ $values { "cons" "a cons object" } { "cdr" "a cons object" } }
{ $description "Returns the tail of the list." } ;

{ car cdr } related-words

HELP: nil 
{ $values { "symbol" "The empty cons (+nil+)" } }
{ $description "Returns a symbol representing the empty list" } ;

HELP: nil? 
{ $values { "object" object } { "?" "a boolean" } }
{ $description "Return true if the cons object is the nil cons." } ;

{ nil nil? } related-words

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

HELP: unswons
{ $values { "cons" "a cons object" } { "car" "the head of the list" } { "cdr" "the tail of the list" } }
{ $description "Put the head and tail of the list on the stack." } ;

{ leach foldl lmap>array } related-words

HELP: leach
{ $values { "list" "a cons object" } { "quot" { $quotation "( obj -- )" } } }
{ $description "Call the quotation for each item in the list." } ;

HELP: foldl
{ $values { "list" "a cons object" } { "identity" "an object" } { "quot" { $quotation "( prev elt -- next )" } } { "result" "the final result" } }
{ $description "Combines successive elements of the list (in a left-assocative order) using a binary operation and outputs the final result." } ;

HELP: foldr
{ $values { "list" "a cons object" } { "identity" "an object" } { "quot" { $quotation "( prev elt -- next )" } } { "result" "the final result" } }
{ $description "Combines successive elements of the list (in a right-assocative order) using a binary operation, and outputs the final result." } ;

HELP: lmap
{ $values { "list" "a cons object" } { "quot" { $quotation "( old -- new )" } } { "result" "the final result" } }
{ $description "Applies the quotation to each element of the list in order, collecting the new elements into a new list." } ;

HELP: lreverse
{ $values { "list" list } { "newlist" list } }
{ $description "Reverses the input list, outputing a new, reversed list. The output is a strict cons list." } ;

HELP: list>array    
{ $values { "list" "a cons object" } { "array" array } }
{ $description "Turns the given cons object into an array, maintaing order." } ;

HELP: sequence>cons
{ $values { "sequence" sequence } { "list" cons } }
{ $description "Turns the given array into a cons object, maintaing order." } ;

HELP: deep-list>array
{ $values { "list" list } { "array" array } }
{ $description "Recursively turns the given cons object into an array, maintaing order and also converting nested lists." } ;

HELP: deep-sequence>cons
{ $values { "sequence" sequence } { "cons" cons } }
{ $description "Recursively turns the given sequence into a cons object, maintaing order and also converting nested lists." } ;

HELP: traverse    
{ $values { "list"  "a cons object" } { "pred" { $quotation "( list/elt -- ? )" } }
          { "quot" { $quotation "( list/elt -- result)" } }  { "result" "a new cons object" } }
{ $description "Recursively traverses the list object, replacing any elements (which can themselves be sublists) that pred" 
 " returns true for with the result of applying quot to." } ;

HELP: list
{ $class-description "The class of lists. All lists are expected to conform to " { $link { "lists" "protocol" } } "." } ;

HELP: cadr
{ $values { "list" list } { "elt" object } }
{ $description "Returns the second element of the list, ie the car of the cdr." } ;

HELP: lappend
{ $values { "list1" list } { "list2" list } { "newlist" list } }
{ $description "Appends the two lists to form a new list. The first list must be finite. The result is a strict cons cell, and the first list is exausted." } ;

HELP: lcut
{ $values { "list" list } { "index" integer } { "before" cons } { "after" cons } }
{ $description "Analogous to " { $link cut } ", this word cuts a list into two pieces at the given index." } ;

HELP: lmap>array
{ $values { "list" list } { "quot" quotation } { "array" array } }
{ $description "Executes the quotation on each element of the list, collecting the results in an array." } ;

HELP: lmap-as
{ $values { "list" list } { "quot" quotation } { "exemplar" sequence } { "sequence" sequence } }
{ $description "Executes the quotation on each element of the list, collecting the results in a sequence of the type given by the exemplar." } ;
