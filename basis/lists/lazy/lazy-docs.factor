! Copyright (C) 2006 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs help.markup help.syntax lists math sequences strings ;
IN: lists.lazy

ABOUT: "lists.lazy"

ARTICLE: "lists.lazy" "Lazy lists"
"The " { $vocab-link "lists.lazy" } " vocabulary implements lazy lists and standard operations to manipulate them."
{ $subsections
    { "lists.lazy" "construction" }
    { "lists.lazy" "manipulation" }
    { "lists.lazy" "combinators" }
    { "lists.lazy" "io" }
} ;

ARTICLE: { "lists.lazy" "combinators" } "Combinators for manipulating lazy lists"
"The following combinators create lazy lists from other lazy lists:"
{ $subsections
    lmap-lazy
    lfilter
    luntil
    lwhile
    lfrom-by
    lcartesian-map
    lcartesian-map*
} ;

ARTICLE: { "lists.lazy" "io" } "Lazy list I/O"
"Input from a stream can be read through a lazy list, using the following words:"
{ $subsections
    lcontents
    llines
} ;

ARTICLE: { "lists.lazy" "construction" } "Constructing lazy lists"
"Words for constructing lazy lists:"
{ $subsections
    lazy-cons
    1lazy-list
    2lazy-list
    3lazy-list
    sequence-tail>list
    >list
    lfrom
} ;

ARTICLE: { "lists.lazy" "manipulation" } "Manipulating lazy lists"
"To make new lazy lists from old ones:"
{ $subsections
    <memoized-cons>
    lappend-lazy
    lconcat
    lcartesian-product
    lcartesian-product*
    lmerge
    ltake
    lzip
} ;

HELP: lazy-cons
{ $values { "car" { $quotation ( -- elt ) } } { "cdr" { $quotation ( -- cons ) } } { "lazy" "the resulting cons object" } }
{ $description "Constructs a cons object for a lazy list from two quotations. The " { $snippet "car" } " quotation should return the head of the list, and the " { $snippet "cons" } " quotation the tail when called. When " { $link cons } " or " { $link cdr } " are called on the lazy-cons object then the appropriate quotation is called." }
{ $see-also cons car cdr nil nil? } ;

{ 1lazy-list 2lazy-list 3lazy-list } related-words

HELP: 1lazy-list
{ $values { "a" { $quotation ( -- X ) } } { "lazy-cons" "a lazy-cons object" } }
{ $description "Create a lazy list with 1 element. The element is the result of calling the quotation. The quotation is only called when the list element is requested." } ;

HELP: 2lazy-list
{ $values { "a" { $quotation ( -- X ) } } { "b" { $quotation ( -- X ) } } { "lazy-cons" "a lazy-cons object" } }
{ $description "Create a lazy list with 2 elements. The elements are the result of calling the quotations. The quotations are only called when the list elements are requested." } ;

HELP: 3lazy-list
{ $values { "a" { $quotation ( -- X ) } } { "b" { $quotation ( -- X ) } } { "c" { $quotation ( -- X ) } } { "lazy-cons" "a lazy-cons object" } }
{ $description "Create a lazy list with 3 elements. The elements are the result of calling the quotations. The quotations are only called when the list elements are requested." } ;

HELP: <memoized-cons>
{ $values { "cons" "a cons object" } { "memoized-cons" "the resulting memoized-cons object" } }
{ $description "Constructs a cons object that wraps an existing cons object. Requests for the car, cdr and nil? will be remembered after the first call, and the previous result returned on subsequent calls." }
{ $see-also cons car cdr nil nil? } ;

{ lmap-lazy ltake lfilter lappend-lazy lfrom lfrom-by lconcat lcartesian-product lcartesian-product* lcartesian-map lcartesian-map* lmerge lwhile luntil } related-words

HELP: lmap-lazy
{ $values { "list" "a cons object" } { "quot" { $quotation ( obj -- X ) } } { "result" "resulting cons object" } }
{ $description "Perform a similar functionality to that of the " { $link map } " word, but in a lazy manner. No evaluation of the list elements occurs initially but a " { $link lazy-map } " object is returned which conforms to the list protocol. Calling " { $link car } ", " { $link cdr } " or " { $link nil? } " on this will evaluate elements as required." }
{ $examples
    { $example
        "USING: kernel lists lists.lazy math prettyprint ;"
        "1 lfrom [ 2 * ] lmap-lazy 5 ltake list>array ."
        "{ 2 4 6 8 10 }"
    }
} ;

HELP: ltake
{ $values { "list" "a cons object" } { "n" "a non negative integer" } { "result" "resulting cons object" } }
{ $description "Outputs a lazy list containing the first n items in the list. This is done a lazy manner. No evaluation of the list elements occurs initially but a " { $link lazy-take } " object is returned which conforms to the list protocol. Calling " { $link car } ", " { $link cdr } " or " { $link nil? } " on this will evaluate elements as required." }
{ $examples
    { $example
        "USING: kernel lists lists.lazy prettyprint ;"
        "1 lfrom 5 ltake list>array ."
        "{ 1 2 3 4 5 }"
    }
} ;

HELP: lfilter
{ $values { "list" "a cons object" } { "quot" { $quotation ( elt -- ? ) } } { "result" "resulting cons object" } }
{ $description "Perform a similar functionality to that of the " { $link filter } " word, but in a lazy manner. No evaluation of the list elements occurs initially but a " { $link lazy-filter } " object is returned which conforms to the list protocol. Calling " { $link car } ", " { $link cdr } " or " { $link nil? } " on this will evaluate elements as required." }
{ $examples
    { $example
        "USING: kernel lists lists.lazy math prettyprint ;"
        "1 lfrom [ even? ] lfilter 5 ltake list>array ."
        "{ 2 4 6 8 10 }"
    }
} ;

HELP: lwhile
{ $values { "list" "a cons object" } { "quot" { $quotation ( elt -- ? ) } } { "result" "resulting cons object" } }
{ $description "Outputs a lazy list containing the first items in the list as long as " { $snippet "quot" } " evaluates to t. No evaluation of the list elements occurs initially but a " { $link lazy-while } " object is returned with conforms to the list protocol. Calling " { $link car } ", " { $link cdr } " or " { $link nil? } " on this will evaluate elements as required." }
{ $examples
    { $example
        "USING: kernel lists lists.lazy math prettyprint ;"
        "1 lfrom [ 5 <= ] lwhile list>array ."
        "{ 1 2 3 4 5 }"
    }
} ;

HELP: luntil
{ $values { "list" "a cons object" } { "quot" { $quotation ( elt -- ? ) } } { "result" "resulting cons object" } }
{ $description "Outputs a lazy list containing the first items in the list until after " { $snippet "quot" } " evaluates to t. No evaluation of the list elements occurs initially but a " { $link lazy-while } " object is returned with conforms to the list protocol. Calling " { $link car } ", " { $link cdr } " or " { $link nil? } " on this will evaluate elements as required." }
{ $examples
    { $example
        "USING: kernel lists lists.lazy math prettyprint ;"
        "1 lfrom [ 5 >= ] luntil list>array ."
        "{ 1 2 3 4 5 }"
    }
} ;

HELP: lappend-lazy
{ $values { "list1" "a cons object" } { "list2" "a cons object" } { "result" "a lazy list of list2 appended to list1" } }
{ $description "Perform a similar functionality to that of the " { $link append } " word, but in a lazy manner. No evaluation of the list elements occurs initially but a " { $link lazy-append } " object is returned which conforms to the list protocol. Calling " { $link car } ", " { $link cdr } " or " { $link nil? } " on this will evaluate elements as required. Successive calls to " { $link cdr } " will iterate through list1, followed by list2." } ;

HELP: lfrom-by
{ $values { "n" integer } { "quot" { $quotation ( n -- o ) } } { "result" "a lazy list of integers" } }
{ $description "Return an infinite lazy list of values starting from n, with each successive value being the result of applying quot to the previous value." } ;

HELP: lfrom
{ $values { "n" integer } { "result" "a lazy list of integers" } }
{ $description "Return an infinite lazy list of incrementing integers starting from n." }
{ $examples
    { $example
        "USING: lists.lazy prettyprint ;"
        "10 lfrom ."
        "T{ lazy-from-by { n 10 } { quot [ 1 + ] } }"
    }
} ;

HELP: lzip
{ $values { "list1" "a cons object" } { "list2" "a cons object" } { "result" "a lazy list" } }
{ $description "Performs a similar functionality to that of the " { $link zip } " word, but in a lazy manner." }
{ $examples
    { $example
        "USING: kernel lists lists.lazy math prettyprint ;"
        "1 lfrom 10 [ 10 + ] lfrom-by lzip 5 ltake list>array ."
        "{ { 1 10 } { 2 20 } { 3 30 } { 4 40 } { 5 50 } }"
    }
} ;

HELP: sequence-tail>list
{ $values { "index" "an integer 0 or greater" } { "seq" sequence } { "list" "a list" } }
{ $description "Convert the sequence into a list, starting from " { $snippet "index" } "." }
{ $see-also >list } ;

{ leach foldl lmap-lazy ltake lfilter lappend-lazy lfrom lfrom-by lconcat lcartesian-product lcartesian-product* lcartesian-map lcartesian-map* lmerge lwhile luntil } related-words

HELP: lconcat
{ $values { "list" "a list of lists" } { "result" "a list" } }
{ $description "Concatenates a list of lists together into one list." } ;

HELP: lcartesian-product
{ $values { "list1" "a list" } { "list2" "a list" } { "result" "list of cartesian products" } }
{ $description "Given two lists, return a list containing the cartesian product of those lists." } ;

HELP: lcartesian-product*
{ $values { "lists" "a list of lists" } { "result" "list of cartesian products" } }
{ $description "Given a list of lists, return a list containing the cartesian product of those lists." } ;

HELP: lcartesian-map
{ $values { "list" "a list of lists" } { "quot" { $quotation ( elt1 elt2 -- newelt ) } } { "result" "the resulting list" } }
{ $description "Get the cartesian product of the lists in " { $snippet "list" } " and call " { $snippet "quot" } " call with each element from the cartesian product on the stack, the result of which is returned in the final " { $snippet "list" } "." } ;

HELP: lcartesian-map*
{ $values { "list" "a list of lists" } { "guards" "a sequence of quotations with stack effect ( elt1 elt2 -- ? )" } { "quot" { $quotation ( elt1 elt2 -- newelt ) } } { "result" "a list" } }
{ $description "Get the cartesian product of the lists in " { $snippet "list" } ", filter it by applying each guard quotation to it and call " { $snippet "quot" } " call with each element from the remaining cartesian product items on the stack, the result of which is returned in the final " { $snippet "list" } "." }
{ $examples
    { $example
        "USING: kernel lists lists.lazy math prettyprint ;"
        "{ 1 2 3 } >list { 4 5 6 } >list 2list"
        "{ [ drop odd? ] } [ + ] lcartesian-map* list>array ."
        "{ 5 6 7 7 8 9 }"
    }
} ;

HELP: lmerge
{ $values { "list1" "a list" } { "list2" "a list" } { "result" "lazy list merging list1 and list2" } }
{ $description "Return the result of merging the two lists in a lazy manner." }
{ $examples
    { $example
        "USING: lists lists.lazy prettyprint ;"
        "{ 1 2 3 } >list { 4 5 6 } >list lmerge list>array ."
        "{ 1 4 2 5 3 6 }"
    }
} ;

HELP: lcontents
{ $values { "stream" "a stream" } { "result" string } }
{ $description "Returns a lazy list of all characters in the file. " { $link car } " returns the next character in the file, " { $link cdr } " returns the remaining characters as a lazy list. " { $link nil? } " indicates end of file." }
{ $see-also llines } ;

HELP: llines
{ $values { "stream" "a stream" } { "result" "a list" } }
{ $description "Returns a lazy list of all lines in the file. " { $link car } " returns the next lines in the file, " { $link cdr } " returns the remaining lines as a lazy list. " { $link nil? } " indicates end of file." }
{ $see-also lcontents }
{ $examples
    { $example
        "USING: io io.encodings.utf8 io.files lists lists.lazy namespaces"
        "prettyprint ;"
        "\"resource:LICENSE.txt\" utf8 ["
        "    1 lfrom input-stream get llines lzip cdr car ."
        "] with-file-reader"
        "{ 2 \"All rights reserved.\" }"
    }
} ;
