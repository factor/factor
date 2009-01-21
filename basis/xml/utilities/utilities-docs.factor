! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax xml.data sequences strings ;
IN: xml.utilities

ABOUT: "xml.utilities"

ARTICLE: "xml.utilities" "Utilities for processing XML"
    "Utilities for processing XML include..."
    $nl
    "System sfor creating words which dispatch on XML tags:"
    { $subsection POSTPONE: PROCESS: }
    { $subsection POSTPONE: TAG: }
    "Getting parts of an XML document or tag:"
    $nl
    "Note: the difference between deep-tag-named and tag-named is that the former searches recursively among all children and children of children of the tag, while the latter only looks at the direct children, and is therefore more efficient."
    { $subsection tag-named }
    { $subsection tags-named }
    { $subsection deep-tag-named }
    { $subsection deep-tags-named }
    { $subsection get-id }
    "Words for simplified generation of XML:"
    { $subsection build-tag* }
    { $subsection build-tag }
    { $subsection build-xml }
    "Other relevant words:"
    { $subsection children>string }
    { $subsection children-tags }
    { $subsection first-child-tag }
    { $subsection assert-tag } ;

HELP: deep-tag-named
{ $values { "tag" "an XML tag or document" } { "name/string" "an XML name or string representing a name" } { "matching-tag" tag } }
{ $description "finds an XML tag with a matching name, recursively searching children and children of children" }
{ $see-also tags-named tag-named deep-tags-named } ;

HELP: deep-tags-named
{ $values { "tag" "an XML tag or document" } { "name/string" "an XML name or string representing a name" } { "tags-seq" "a sequence of tags" } }
{ $description "returns a sequence of all tags of a matching name, recursively searching children and children of children" }
{ $see-also tag-named deep-tag-named tags-named } ;

HELP: children>string
{ $values { "tag" "an XML tag or document" } { "string" "a string" } }
{ $description "concatenates the children of the tag, ignoring everything that's not a string" } ;

HELP: children-tags
{ $values { "tag" "an XML tag or document" } { "sequence" sequence } }
{ $description "gets the children of the tag that are themselves tags" }
{ $see-also first-child-tag } ;

HELP: first-child-tag
{ $values { "tag" "an XML tag or document" } { "tag" tag } }
{ $description "returns the first child of the given tag that is a tag" }
{ $see-also children-tags } ;

HELP: tag-named
{ $values { "tag" "an XML tag or document" }
    { "name/string" "an XML name or string representing the name" }
    { "matching-tag" tag } }
{ $description "finds the first tag with matching name which is the direct child of the given tag" }
{ $see-also deep-tags-named deep-tag-named tags-named } ;

HELP: tags-named
{ $values { "tag" "an XML tag or document" }
    { "name/string" "an XML name or string representing the name" }
    { "tags-seq" "a sequence of tags" } }
{ $description "finds all tags with matching name that are the direct children of the given tag" }
{ $see-also deep-tag-named deep-tags-named tag-named } ;

HELP: get-id
{ $values { "tag" "an XML tag or document" } { "id" "a string" } { "elem" "an XML element or f" } }
{ $description "finds the XML tag with the specified id, ignoring the namespace" } ;

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

HELP: build-tag*
{ $values { "items" "sequence of elements" } { "name" "string" }
    { "tag" tag } }
{ $description "builds a " { $link tag } " with the specified name, in the namespace \"\" and URL \"\" containing the children listed in item" }
{ $see-also build-tag build-xml } ;

HELP: build-tag
{ $values { "item" "an element" } { "name" string } { "tag" tag } }
{ $description "builds a " { $link tag } " with the specified name containing the single child item" }
{ $see-also build-tag* build-xml } ;

HELP: build-xml
{ $values { "tag" tag } { "xml" "an XML document" } }
{ $description "builds an XML document out of a tag" }
{ $see-also build-tag* build-tag } ;
