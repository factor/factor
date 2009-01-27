! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: xml.dispatch

ABOUT: "xml.dispatch"

ARTICLE: "xml.dispatch" "Dispatch on XML tag names"
"Two parsing words define a system, analogous to generic words, for processing XML. A word can dispatch off the name of the tag that is passed to it. To define such a word, use"
{ $subsection POSTPONE: PROCESS: }
"and to define a new 'method' for this word, use"
{ $subsection POSTPONE: TAG: } ;

HELP: PROCESS:
{ $syntax "PROCESS: word" }
{ $values { "word" "a new word to define" } }
{ $description "creates a new word to process XML tags" }
{ $see-also POSTPONE: TAG: } ;

HELP: TAG:
{ $syntax "TAG: tag word definition... ;" }
{ $values { "tag" "an xml tag name" } { "word" "an XML process" } }
{ $description "defines what a process should do when it encounters a specific tag" }
{ $examples { $code "PROCESS: x ( tag -- )\nTAG: a x drop \"hi\" write ;" } }
{ $see-also POSTPONE: PROCESS: } ;
