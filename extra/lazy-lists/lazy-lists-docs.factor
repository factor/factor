! Copyright (C) 2006 Chris Double.
! See http://factorcode.org/license.txt for BSD license.

USING: help.markup help.syntax sequences strings ;
IN: lazy-lists 

HELP: cons 
{ $values { "car" "the head of the lazy list" } { "cdr" "the tail of the lazy list" } { "cons" "a cons object" } }
{ $description "Constructs a cons cell." }
{ $see-also cons car cdr nil nil? list? } ;

HELP: car
{ $values { "cons" "a cons object" } { "car" "the first item in the list" } }
{ $description "Returns the first item in the list." } 
{ $see-also cons cdr nil nil? list? } ;

HELP: cdr
{ $values { "cons" "a cons object" } { "cdr" "a cons object" } }
{ $description "Returns the tail of the list." } 
{ $see-also cons car nil nil? list? } ;

HELP: nil 
{ $values { "cons" "An empty cons" } }
{ $description "Returns a representation of an empty list" } 
{ $see-also cons car cdr nil? list? } ;

HELP: nil? 
{ $values { "cons" "a cons object" } { "?" "a boolean" } }
{ $description "Return true if the cons object is the nil cons." } 
{ $see-also cons car cdr nil list? } ;

HELP: list? 
{ $values { "object" "an object" } { "?" "a boolean" } }
{ $description "Returns true if the object conforms to the list protocol." } 
{ $see-also cons car cdr nil } ;

HELP: 1list
{ $values { "obj" "an object" } { "cons" "a cons object" } }
{ $description "Create a list with 1 element." } 
{ $see-also 2list 3list } ;

HELP: 2list
{ $values { "a" "an object" } { "b" "an object" } { "cons" "a cons object" } }
{ $description "Create a list with 2 elements." } 
{ $see-also 1list 3list } ;

HELP: 3list
{ $values { "a" "an object" } { "b" "an object" } { "c" "an object" } { "cons" "a cons object" } }
{ $description "Create a list with 3 elements." } 
{ $see-also 1list 2list } ;

HELP: lazy-cons
{ $values { "car" "a quotation with stack effect ( -- X )" } { "cdr" "a quotation with stack effect ( -- cons )" } { "promise" "the resulting cons object" } }
{ $description "Constructs a cons object for a lazy list from two quotations. The " { $snippet "car" } " quotation should return the head of the list, and the " { $snippet "cons" } " quotation the tail when called. When " { $link cons } " or " { $link cdr } " are called on the lazy-cons object then the appropriate quotation is called." } 
{ $see-also cons car cdr nil nil? } ;

HELP: 1lazy-list
{ $values { "a" "a quotation with stack effect ( -- X )" } { "lazy-cons" "a lazy-cons object" } }
{ $description "Create a lazy list with 1 element. The element is the result of calling the quotation. The quotation is only called when the list element is requested." } 
{ $see-also 2lazy-list 3lazy-list } ;

HELP: 2lazy-list
{ $values { "a" "a quotation with stack effect ( -- X )" } { "b" "a quotation with stack effect ( -- X )" } { "lazy-cons" "a lazy-cons object" } }
{ $description "Create a lazy list with 2 elements. The elements are the result of calling the quotations. The quotations are only called when the list elements are requested." } 
{ $see-also 1lazy-list 3lazy-list } ;

HELP: 3lazy-list
{ $values { "a" "a quotation with stack effect ( -- X )" } { "b" "a quotation with stack effect ( -- X )" } { "c" "a quotation with stack effect ( -- X )" } { "lazy-cons" "a lazy-cons object" } }
{ $description "Create a lazy list with 3 elements. The elements are the result of calling the quotations. The quotations are only called when the list elements are requested." } 
{ $see-also 1lazy-list 2lazy-list } ;

HELP: <memoized-cons>
{ $values { "cons" "a cons object" } { "memoized-cons" "the resulting memoized-cons object" } }
{ $description "Constructs a cons object that wraps an existing cons object. Requests for the car, cdr and nil? will be remembered after the first call, and the previous result returned on subsequent calls." } 
{ $see-also cons car cdr nil nil? } ;

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
{ $description "Put the head and tail of the list on the stack." } 
{ $see-also cons car cdr } ;

HELP: leach
{ $values { "list" "a cons object" } { "quot" "a quotation with stack effect ( obj -- )" } }
{ $description "Call the quotation for each item in the list." } 
{ $see-also lmap lmap-with ltake lsubset lappend lfrom lfrom-by lconcat lcartesian-product lcartesian-product* lcomp lcomp* lmerge } ;

HELP: lmap
{ $values { "list" "a cons object" } { "quot" "a quotation with stack effect ( obj -- X )" } { "result" "resulting cons object" } }
{ $description "Perform a similar functionality to that of the " { $link map } " word, but in a lazy manner. No evaluation of the list elements occurs initially but a " { $link <lazy-map> } " object is returned which conforms to the list protocol. Calling " { $link car } ", " { $link cdr } " or " { $link nil? } " on this will evaluate elements as required." } 
{ $see-also leach ltake lsubset lappend lmap-with  lfrom lfrom-by lconcat lcartesian-product lcartesian-product* lcomp lcomp* lmerge } ;

HELP: lmap-with
{ $values { "value" "an object" } { "list" "a cons object" } { "quot" "a quotation with stack effect ( obj elt -- X )" } { "result" "resulting cons object" } }
{ $description "Variant of " { $link lmap } " which pushes a retained object on each invocation of the quotation." } 
{ $see-also leach ltake lsubset lappend lmap lfrom lfrom-by lconcat lcartesian-product lcartesian-product* lcomp lcomp* lmerge } ;

HELP: ltake
{ $values { "n" "a non negative integer" } { "list" "a cons object" } { "result" "resulting cons object" } }
{ $description "Outputs a lazy list containing the first n items in the list. This is done a lazy manner. No evaluation of the list elements occurs initially but a " { $link <lazy-take> } " object is returned which conforms to the list protocol. Calling " { $link car } ", " { $link cdr } " or " { $link nil? } " on this will evaluate elements as required." } 
{ $see-also leach lmap lmap-with lsubset lappend lfrom lfrom-by lconcat lcartesian-product lcartesian-product* lcomp lcomp* lmerge } ;

HELP: lsubset
{ $values { "list" "a cons object" } { "quot" "a quotation with stack effect ( -- X )" } { "result" "resulting cons object" } }
{ $description "Perform a similar functionality to that of the " { $link subset } " word, but in a lazy manner. No evaluation of the list elements occurs initially but a " { $link <lazy-subset> } " object is returned which conforms to the list protocol. Calling " { $link car } ", " { $link cdr } " or " { $link nil? } " on this will evaluate elements as required." } 
{ $see-also leach lmap lmap-with ltake lappend lfrom lfrom-by lconcat lcartesian-product lcartesian-product* lcomp lcomp* lmerge } ;

HELP: list>vector
{ $values { "list" "a cons object" } { "vector" "the list converted to a vector" } }
{ $description "Convert a list to a vector. If the list is a lazy infinite list then this will enter an infinite loop." } 
{ $see-also list>array } ;

HELP: list>array
{ $values { "list" "a cons object" } { "array" "the list converted to an array" } }
{ $description "Convert a list to an array. If the list is a lazy infinite list then this will enter an infinite loop." } 
{ $see-also list>vector } ;

HELP: lappend
{ $values { "list1" "a cons object" } { "list2" "a cons object" } { "result" "a lazy list of list2 appended to list1" } }
{ $description "Perform a similar functionality to that of the " { $link append } " word, but in a lazy manner. No evaluation of the list elements occurs initially but a " { $link <lazy-append> } " object is returned which conforms to the list protocol. Calling " { $link car } ", " { $link cdr } " or " { $link nil? } " on this will evaluate elements as required. Successive calls to " { $link cdr } " will iterate through list1, followed by list2." } 
{ $see-also leach lmap lmap-with ltake lsubset lfrom lfrom-by lconcat lcartesian-product lcartesian-product* lcomp lcomp* lmerge } ;

HELP: lfrom-by
{ $values { "n" "an integer" } { "quot" "a quotation with stack effect ( -- int )" } { "list" "a lazy list of integers" } }
{ $description "Return an infinite lazy list of values starting from n, with each successive value being the result of applying quot to n." } 
{ $see-also leach lmap lmap-with ltake lsubset lfrom lconcat lcartesian-product lcartesian-product* lcomp lcomp* lmerge } ;

HELP: lfrom
{ $values { "n" "an integer" } { "list" "a lazy list of integers" } }
{ $description "Return an infinite lazy list of incrementing integers starting from n." } 
{ $see-also leach lmap lmap-with ltake lsubset lfrom-by lconcat lcartesian-product lcartesian-product* lcomp lcomp* lmerge } ;

HELP: seq>list
{ $values { "index" "an integer 0 or greater" } { "seq" "a sequence" } { "list" "a list" } }
{ $description "Convert the sequence into a list, starting from the 'index' offset into the sequence." } 
{ $see-also >list } ;

HELP: >list
{ $values { "object" "an object" } { "list" "a list" } }
{ $description "Convert the object into a list. Existing lists are passed through intact, sequences are converted using " { $link seq>list } " and other objects cause an error to be thrown." } 
{ $see-also seq>list } ;

HELP: lconcat
{ $values { "list" "a list of lists" } { "result" "a list" } }
{ $description "Concatenates a list of lists together into one list." } 
{ $see-also leach lmap lmap-with ltake lsubset lcartesian-product lcartesian-product* lfrom-by lcomp lcomp* lmerge } ;

HELP: lcartesian-product
{ $values { "list1" "a list" } { "list2" "a list" } { "result" "list of cartesian products" } }
{ $description "Given two lists, return a list containing the cartesian product of those lists." } 
{ $see-also leach lmap lmap-with lconcat ltake lsubset lfrom-by lcartesian-product* lcomp lcomp* lmerge } ;

HELP: lcartesian-product*
{ $values { "lists" "a list of lists" } { "result" "list of cartesian products" } }
{ $description "Given a list of lists, return a list containing the cartesian product of those lists." } 
{ $see-also leach lmap lmap-with lconcat ltake lsubset lfrom-by lcartesian-product lcomp lcomp* lmerge } ;

HELP: lcomp
{ $values { "list" "a list of lists" } { "quot" "a quotation with stack effect ( seq -- X )" } { "result" "the resulting list" } }
{ $description "Get the cartesian product of the lists in " { $snippet "list" } " and call " { $snippet "quot" } " call with each element from the cartesian product on the stack, the result of which is returned in the final " { $snippet "list" } "." } 
{ $see-also leach lmap lmap-with lconcat ltake lsubset lfrom-by lcartesian-product lcomp* lmerge } ;

HELP: lcomp*
{ $values { "list" "a list of lists" } { "guards" "a sequence of quotations with stack effect ( seq -- bool )" } { "quot" "a quotation with stack effect ( seq -- X )" } { "list" "the resulting list" } { "result" "a list" } }
{ $description "Get the cartesian product of the lists in " { $snippet "list" } ", filter it by applying each guard quotation to it and call " { $snippet "quot" } " call with each element from the remaining cartesian product items on the stack, the result of which is returned in the final " { $snippet "list" } "." } 
{ $examples
  { $code "{ 1 2 3 } >list { 4 5 6 } >list 2list { [ first odd? ] } [ first2 + ] lcomp*" }
}
{ $see-also leach lmap lmap-with lconcat ltake lsubset lfrom-by lcartesian-product lcomp lmerge } ;

HELP: lmerge
{ $values { "list1" "a list" } { "list2" "a list" } { "result" "lazy list merging list1 and list2" } }
{ $description "Return the result of merging the two lists in a lazy manner." } 
{ $examples
  { $example "{ 1 2 3 } >list { 4 5 6 } >list lmerge list>array ." "{ 1 4 2 5 3 6 }" }
}
{ $see-also leach lmap lmap-with lconcat ltake lsubset lfrom-by lcartesian-product lcomp } ;

HELP: lcontents
{ $values { "stream" "a stream" } { "result" string } }
{ $description "Returns a lazy list of all characters in the file. " { $link car } " returns the next character in the file, " { $link cdr } " returns the remaining characters as a lazy list. " { $link nil? } " indicates end of file." } 
{ $see-also llines } ;

HELP: llines
{ $values { "stream" "a stream" } { "result" "a list" } }
{ $description "Returns a lazy list of all lines in the file. " { $link car } " returns the next lines in the file, " { $link cdr } " returns the remaining lines as a lazy list. " { $link nil? } " indicates end of file." } 
{ $see-also lcontents } ;

