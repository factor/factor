USING: help.markup help.syntax kernel sequences ;
IN: persistent.deques

ARTICLE: "persistent.deques" "Persistent deques"
"A deque is a data structure that can be used as both a queue and a stack. That is, there are two ends, the left and the right, and values can be pushed onto and popped off of both ends. These operations take O(1) amortized time and space in a normal usage pattern."
$nl
"This vocabulary provides a deque implementation which is persistent and purely functional: old versions of deques are not modified by operations. Instead, each push and pop operation creates a new deque based off the old one."
$nl
"The class of persistent deques:"
{ $subsection deque }
"To create a deque:"
{ $subsection <deque> }
{ $subsection sequence>deque }
"To test if a deque is empty:"
{ $subsection deque-empty? }
"To manipulate deques:"
{ $subsection push-left }
{ $subsection push-right }
{ $subsection pop-left }
{ $subsection pop-right }
{ $subsection deque>sequence } ;

HELP: deque
{ $class-description "This is the class of persistent (functional) double-ended queues. All deque operations can be done in O(1) amortized time for single-threaded access while maintaining the old version. For more information, see " { $link "persistent.deques" } "." } ;

HELP: <deque>
{ $values { "deque" "an empty deque" } }
{ $description "Creates an empty deque." } ;

HELP: sequence>deque
{ $values { "sequence" sequence } { "deque" deque } }
{ $description "Given a sequence, creates a deque containing those elements in the order such that the beginning of the sequence is on the left and the end is on the right." } ;

HELP: deque>sequence
{ $values { "deque" deque } { "sequence" sequence } }
{ $description "Given a deque, creates a sequence containing those elements, such that the left side of the deque is the beginning of the sequence." } ;

HELP: deque-empty?
{ $values { "deque" deque } { "?" "t/f" } }
{ $description "Returns true if the deque is empty. This takes constant time." } ;

HELP: push-left
{ $values { "deque" deque } { "item" object } { "newdeque" deque } }
{ $description "Creates a new deque with the given object pushed onto the left side. This takes constant time." } ;

HELP: push-right
{ $values { "deque" deque } { "item" object } { "newdeque" deque } }
{ $description "Creates a new deque with the given object pushed onto the right side. This takes constant time." } ;

HELP: pop-left
{ $values { "deque" object } { "item" object } { "newdeque" deque } }
{ $description "Creates a new deque with the leftmost item removed. This takes amortized constant time with single-threaded access." } ;

HELP: pop-right
{ $values { "deque" object } { "item" object } { "newdeque" deque } }
{ $description "Creates a new deque with the rightmost item removed. This takes amortized constant time with single-threaded access." } ;
