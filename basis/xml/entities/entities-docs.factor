! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: xml.entities

ABOUT: "xml.entities"

ARTICLE: "xml.entities" "XML entities"
    "When XML is parsed, entities like &foo; are replaced with the characters they represent. A few entities like &amp; and &lt; are defined by default, but more are available, and the set of entities can be customized. Below are some words involved in XML entities, defined in the vocabulary 'entities':"
    { $subsection entities }
    { $subsection with-entities }
"For entities used in HTML/XHTML, see " { $vocab-link "xml.entities.html" } ;

HELP: entities
{ $description "a hash table from default XML entity names (like &amp; and &lt;) to the characters they represent. This is automatically included when parsing any XML document." }
{ $see-also with-entities } ;

HELP: with-entities
{ $values { "entities" "a hash table of strings to chars" }
    { "quot" "a quotation ( -- )" } }
{ $description "calls the quotation using the given table of entity values (symbolizing, eg, that &foo; represents CHAR: a) on top of the default XML entities" } ;

