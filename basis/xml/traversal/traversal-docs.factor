! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax xml.data sequences strings ;
IN: xml.traversal

ABOUT: "xml.traversal"

ARTICLE: "xml.traversal" "Utilities for traversing XML"
    "The " { $vocab-link "xml.traversal" } " vocabulary provides utilities for traversing an XML DOM tree and viewing the contents of a single tag. The following words are defined:"
$nl
{ $subsections
    { "xml.traversal" "intro" }
    tag-named
    tags-named
    deep-tag-named
    deep-tags-named
    get-id
}
"To get at the contents of a single tag, use"
{ $subsections
    children>string
    children-tags
    first-child-tag
    assert-tag
} ;

ARTICLE: { "xml.traversal" "intro" } "An example of XML processing"
"To illustrate how to use the XML library, we develop a simple Atom parser in Factor. Atom is an XML-based syndication format, like RSS. To see the full version of what we develop here, look at " { $snippet "basis/syndication" } " at the " { $snippet "atom1.0" } " word. First, we want to load a file and get a DOM tree for it."
{ $code "\"file.xml\" file>xml" }
"No encoding descriptor is needed, because XML files contain sufficient information to auto-detect the encoding. Next, we want to extract information from the tree. To get the title, we can use the following:"
{ $code "\"title\" tag-named children>string" }
"The " { $link tag-named } " word finds the first tag named " { $snippet "title" } " in the top level (just under the main tag). Then, with a tag on the stack, its children are asserted to be a string, and the string is returned." $nl
"For a slightly more complicated example, we can look at how entries are parsed. To get a sequence of tags with the name " { $snippet "entry" } ":"
{ $code "\"entry\" tags-named" }
"Imagine that, for each of these, we want to get the URL of the entry. In Atom, the URLs are in a " { $snippet "link" } " tag which is contained in the " { $snippet "entry" } " tag. There are multiple " { $snippet "link" } " tags, but one of them contains the attribute " { $snippet "rel=alternate" } ", and the " { $snippet "href" } " attribute has the URL. So, given an element of the sequence produced in the above quotation, we run the code:"
{ $code "\"link\" tags-named [ \"rel\" attr \"alternate\" = ] find nip " }
"to get the link tag on the stack, and"
{ $code "\"href\" attr >url " }
"to extract the URL from it." ;

HELP: deep-tag-named
{ $values { "tag" "an XML tag or document" } { "name/string" "an XML name or string representing a name" } { "matching-tag" tag } }
{ $description "Finds an XML tag with a matching name, recursively searching children and children of children." }
{ $see-also tags-named tag-named deep-tags-named } ;

HELP: deep-tags-named
{ $values { "tag" "an XML tag or document" } { "name/string" "an XML name or string representing a name" } { "tags-seq" "a sequence of tags" } }
{ $description "Returns a sequence of all tags of a matching name, recursively searching children and children of children." }
{ $see-also tag-named deep-tag-named tags-named } ;

HELP: children>string
{ $values { "tag" "an XML tag or document" } { "string" string } }
{ $description "Concatenates the children of the tag, throwing an exception when there is a non-string child." } ;

HELP: children-tags
{ $values { "tag" "an XML tag or document" } { "sequence" sequence } }
{ $description "Gets the children of the tag that are themselves tags." }
{ $see-also first-child-tag } ;

HELP: first-child-tag
{ $values { "tag" "an XML tag or document" } { "child" tag } }
{ $description "Returns the first child of the given tag that is a tag." }
{ $see-also children-tags } ;

HELP: tag-named
{ $values { "tag" "an XML tag or document" }
    { "name/string" "an XML name or string representing the name" }
    { "matching-tag" tag } }
{ $description "Finds the first tag with matching name which is the direct child of the given tag." }
{ $see-also deep-tags-named deep-tag-named tag-named-with-attr tags-named } ;

HELP: tag-named-with-attr
{ $values { "tag" "an XML tag or document" }
    { "tag-name" "an XML name or string representing the name" }
    { "attr-value" "a string representing the attribute value" }
    { "attr-name" "a string representing the attribute name" }
    { "matching-tag" tag } }
{ $description "Finds the first tag with matching name with the corresponding attribute name and value which is the direct child of the given tag." }
{ $see-also tag-named } ;

HELP: tags-named
{ $values { "tag" "an XML tag or document" }
    { "name/string" "an XML name or string representing the name" }
    { "tags-seq" "a sequence of tags" } }
{ $description "Finds all tags with matching name that are the direct children of the given tag." }
{ $see-also deep-tag-named deep-tags-named tag-named } ;

HELP: get-id
{ $values { "tag" "an XML tag or document" } { "id" string } { "elem" "an XML element or f" } }
{ $description "Finds the XML tag with the specified id, ignoring the namespace." } ;
