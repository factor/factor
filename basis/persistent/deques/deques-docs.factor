! Copyright (C) 2008 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel sequences ;
IN: persistent.deques

ARTICLE: "persistent.deques" "Persistent deques"
"A deque is a data structure that can be used as both a queue and a stack. That is, there are two ends, the front and the back, and values can be pushed onto and popped off of both ends. These operations take O(1) amortized time and space in a normal usage pattern."
$nl
"This vocabulary provides a deque implementation which is persistent and purely functional: old versions of deques are not modified by operations. Instead, each push and pop operation creates a new deque based off the old one."
$nl
"The class of persistent deques:"
{ $subsections deque }
"To create a deque:"
{ $subsections
    <deque>
    sequence>deque
}
"To test if a deque is empty:"
{ $subsections deque-empty? }
"To manipulate deques:"
{ $subsections
    push-front
    push-back
    pop-front
    pop-back
    deque>sequence
} ;

HELP: deque
{ $class-description "This is the class of persistent (functional) double-ended queues. All deque operations can be done in O(1) amortized time for single-threaded access while maintaining the old version. For more information, see " { $link "persistent.deques" } "." } ;

HELP: <deque>
{ $values { "deque" "an empty deque" } }
{ $description "Creates an empty deque." } ;

HELP: sequence>deque
{ $values { "sequence" sequence } { "deque" deque } }
{ $description "Given a sequence, creates a deque containing those elements in the order such that the beginning of the sequence is on the front and the end is on the back." } ;

HELP: deque>sequence
{ $values { "deque" deque } { "sequence" sequence } }
{ $description "Given a deque, creates a sequence containing those elements, such that the front side of the deque is the beginning of the sequence." } ;

HELP: deque-empty?
{ $values { "deque" deque } { "?" "t/f" } }
{ $description "Returns true if the deque is empty. This takes constant time." } ;

HELP: push-front
{ $values { "deque" deque } { "item" object } { "newdeque" deque } }
{ $description "Creates a new deque with the given object pushed onto the front side. This takes constant time." } ;

HELP: push-back
{ $values { "deque" deque } { "item" object } { "newdeque" deque } }
{ $description "Creates a new deque with the given object pushed onto the back side. This takes constant time." } ;

HELP: pop-front
{ $values { "deque" object } { "item" object } { "newdeque" deque } }
{ $description "Creates a new deque with the frontmost item removed. This takes amortized constant time with single-threaded access." } ;

HELP: pop-back
{ $values { "deque" object } { "item" object } { "newdeque" deque } }
{ $description "Creates a new deque with the backmost item removed. This takes amortized constant time with single-threaded access." } ;
