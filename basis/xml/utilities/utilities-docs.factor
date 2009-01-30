! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax xml.data sequences strings ;
IN: xml.utilities

ABOUT: "xml.utilities"

ARTICLE: "xml.utilities" "Utilities for processing XML"
    "Getting parts of an XML document or tag:"
    $nl
    "Note: the difference between deep-tag-named and tag-named is that the former searches recursively among all children and children of children of the tag, while the latter only looks at the direct children, and is therefore more efficient."
    { $subsection tag-named }
    { $subsection tags-named }
    { $subsection deep-tag-named }
    { $subsection deep-tags-named }
    { $subsection get-id }
    "To get at the contents of a single tag, use"
    { $subsection children>string }
    { $subsection children-tags }
    { $subsection first-child-tag }
    { $subsection assert-tag } ;

HELP: deep-tag-named
{ $values { "tag" "an XML tag or document" } { "name/string" "an XML name or string representing a name" } { "matching-tag" tag } }
{ $description "Finds an XML tag with a matching name, recursively searching children and children of children." }
{ $see-also tags-named tag-named deep-tags-named } ;

HELP: deep-tags-named
{ $values { "tag" "an XML tag or document" } { "name/string" "an XML name or string representing a name" } { "tags-seq" "a sequence of tags" } }
{ $description "Returns a sequence of all tags of a matching name, recursively searching children and children of children." }
{ $see-also tag-named deep-tag-named tags-named } ;

HELP: children>string
{ $values { "tag" "an XML tag or document" } { "string" "a string" } }
{ $description "Concatenates the children of the tag, throwing an exception when there is a non-string child." } ;

HELP: children-tags
{ $values { "tag" "an XML tag or document" } { "sequence" sequence } }
{ $description "Gets the children of the tag that are themselves tags." }
{ $see-also first-child-tag } ;

HELP: first-child-tag
{ $values { "tag" "an XML tag or document" } { "tag" tag } }
{ $description "Returns the first child of the given tag that is a tag." }
{ $see-also children-tags } ;

HELP: tag-named
{ $values { "tag" "an XML tag or document" }
    { "name/string" "an XML name or string representing the name" }
    { "matching-tag" tag } }
{ $description "Finds the first tag with matching name which is the direct child of the given tag." }
{ $see-also deep-tags-named deep-tag-named tags-named } ;

HELP: tags-named
{ $values { "tag" "an XML tag or document" }
    { "name/string" "an XML name or string representing the name" }
    { "tags-seq" "a sequence of tags" } }
{ $description "Finds all tags with matching name that are the direct children of the given tag." }
{ $see-also deep-tag-named deep-tags-named tag-named } ;

HELP: get-id
{ $values { "tag" "an XML tag or document" } { "id" "a string" } { "elem" "an XML element or f" } }
{ $description "Finds the XML tag with the specified id, ignoring the namespace." } ;
