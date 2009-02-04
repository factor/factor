! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: xml.dispatch

ABOUT: "xml.dispatch"

ARTICLE: "xml.dispatch" "Dispatch on XML tag names"
"The " { $link "xml.dispatch" } " vocabulary defines a system, analogous to generic words, for processing XML. A word can dispatch off the name of the tag that is passed to it. To define such a word, use"
{ $subsection POSTPONE: TAGS: }
"and to define a new 'method' for this word, use"
{ $subsection POSTPONE: TAG: } ;

HELP: TAGS:
{ $syntax "TAGS: word" }
{ $values { "word" "a new word to define" } }
{ $description "Creates a new word to which dispatches on XML tag names." }
{ $see-also POSTPONE: TAG: } ;

HELP: TAG:
{ $syntax "TAG: tag word definition... ;" }
{ $values { "tag" "an XML tag name" } { "word" "an XML process" } }
{ $description "Defines a 'method' on a word created with " { $link POSTPONE: TAGS: } ". It determines what such a word should do for an argument that is has the given name." }
{ $examples { $code "TAGS: x ( tag -- )\nTAG: a x drop \"hi\" write ;" } }
{ $see-also POSTPONE: TAGS: } ;
