! Copyright (C) 2006 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel help.markup help.syntax arrays sequences math quotations ;
IN: lists

ABOUT: "lists"

ARTICLE: "lists" "Lists"
"The " { $vocab-link "lists" } " vocabulary implements linked lists. There are simple strict linked lists, but a generic list protocol allows the implementation of lazy lists as well."
{ $subsections
    "lists-protocol"
    "lists-strict"
    "lists-manipulation"
    "lists-combinators"
}
{ $vocab-subsection "Lazy lists" "lists.lazy" } ;

ARTICLE: "lists-protocol" "The list protocol"
"Lists are instances of a mixin class:"
{ $subsections list }
"Instances of the mixin must implement the following words:"
{ $subsections
    car
    cdr
    nil?
} ;

ARTICLE: "lists-strict" "Constructing strict lists"
"Strict lists are simply cons cells where the car and cdr have already been evaluated. These are the lists of Lisp. To construct a strict list, the following words are provided:"
{ $subsections
    cons
    swons
    sequence>list
    1list
    2list
    3list
} ;

ARTICLE: "lists-combinators" "Combinators for lists"
"Several combinators exist for list traversal."
{ $subsections
    leach
    lmap
    foldl
    foldr
    lmap>array
} ;

ARTICLE: "lists-manipulation" "Manipulating lists"
"To get at the contents of a list:"
{ $subsections
    uncons
    unswons
    lnth
    cadr
    llength
}
"To get a new list from an old one:"
{ $subsections
    lreverse
    lappend
    lcut
} ;

HELP: cons
{ $values { "car" "the head of the list cell" } { "cdr" "the tail of the list cell" } { "cons-state" list } }
{ $description "Constructs a cons cell." } ;

HELP: swons
{ $values { "cdr" "the tail of the list cell" } { "car" "the head of the list cell" } { "cons" list } }
{ $description "Constructs a cons cell." } ;

{ cons swons uncons unswons } related-words

HELP: car
{ $values { "cons" list } { "car" "the first item in the list" } }
{ $description "Returns the first item in the list." } ;

HELP: cdr
{ $values { "cons" list } { "cdr" list } }
{ $description "Returns the tail of the list." } ;

{ car cdr } related-words

HELP: nil
{ $values { "symbol" "The empty cons (+nil+)" } }
{ $description "Returns a symbol representing the empty list" } ;

HELP: nil?
{ $values { "object" object } { "?" boolean } }
{ $description "Return true if the cons object is the nil cons." } ;

{ nil nil? } related-words

{ 1list 2list 3list } related-words

HELP: 1list
{ $values { "obj" object } { "cons" list } }
{ $description "Create a list with 1 element." } ;

HELP: 2list
{ $values { "a" object } { "b" object } { "cons" list } }
{ $description "Create a list with 2 elements." } ;

HELP: 3list
{ $values { "a" object } { "b" object } { "c" object } { "cons" list } }
{ $description "Create a list with 3 elements." } ;

HELP: lnth
{ $values { "n" "an integer index" } { "list" list } { "elt" "the element at the nth index" } }
{ $description "Outputs the nth element of the list." }
{ $see-also llength cons car cdr } ;

HELP: llength
{ $values { "list" list } { "n" "a non-negative integer" } }
{ $description "Outputs the length of the list. This should not be called on an infinite list." }
{ $see-also lnth cons car cdr } ;

HELP: uncons
{ $values { "cons" list } { "car" "the head of the list" } { "cdr" "the tail of the list" } }
{ $description "Put the head and tail of the list on the stack." } ;

HELP: unswons
{ $values { "cons" list } { "cdr" "the tail of the list" } { "car" "the head of the list" } }
{ $description "Put the head and tail of the list on the stack." } ;

{ leach foldl lmap>array } related-words

HELP: leach
{ $values { "list" list } { "quot" { $quotation ( ... elt -- ... ) } } }
{ $description "Call the quotation for each item in the list." } ;

HELP: foldl
{ $values { "list" list } { "identity" object } { "quot" { $quotation ( ... prev elt -- ... next ) } } { "result" "the final result" } }
{ $description "Combines successive elements of the list (in a left-associative order) using a binary operation and outputs the final result." } ;

HELP: foldr
{ $values { "list" list } { "identity" object } { "quot" { $quotation ( ... prev elt -- ... next ) } } { "result" "the final result" } }
{ $description "Combines successive elements of the list (in a right-associative order) using a binary operation, and outputs the final result." } ;

HELP: lmap
{ $values { "list" list } { "quot" { $quotation ( ... elt -- ... newelt ) } } { "result" "the final result" } }
{ $description "Applies the quotation to each element of the list in order, collecting the new elements into a new list." } ;

HELP: lreverse
{ $values { "list" list } { "newlist" list } }
{ $description "Reverses the input list, outputting a new, reversed list. The output is a strict cons list." } ;

HELP: list>array
{ $values { "list" list } { "array" array } }
{ $description "Convert a list into an array." } ;

HELP: list
{ $class-description "The class of lists. All lists are expected to conform to " { $link "lists-protocol" } "." } ;

HELP: cadr
{ $values { "list" list } { "elt" object } }
{ $description "Returns the second element of the list, ie the car of the cdr." } ;

HELP: lappend
{ $values { "list1" list } { "list2" list } { "newlist" list } }
{ $description "Appends the two lists to form a new list. The first list must be finite. The result is a strict cons cell, and the first list is exhausted." } ;

HELP: lcut
{ $values { "list" list } { "index" integer } { "before" cons } { "after" cons } }
{ $description "Analogous to " { $link cut } ", this word cuts a list into two pieces at the given index." } ;

HELP: lmap>array
{ $values { "list" list } { "quot" quotation } { "array" array } }
{ $description "Executes the quotation on each element of the list, collecting the results in an array." } ;

HELP: >list
{ $values { "object" object } { "list" "a list" } }
{ $description "Converts the object into a list." } ;
