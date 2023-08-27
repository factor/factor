! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax assocs ;
IN: xml.entities

ABOUT: "xml.entities"

ARTICLE: "xml.entities" "XML entities"
    "When XML is parsed, entities like &foo; are replaced with the characters they represent. A few entities like &amp; and &lt; are defined by default, but more are available, and the set of entities can be customized. Below are some words involved in XML entities, defined in the vocabulary 'entities':"
{ $subsections
    entities
    with-entities
}
"For entities used in HTML/XHTML, see " { $vocab-link "xml.entities.html" } ;

HELP: entities
{ $values { "value" assoc } }
{ $description "A hash table from default XML entity names (like " { $snippet "&amp;" } " and " { $snippet "&lt;" } ") to the characters they represent. This is automatically included when parsing any XML document." }
{ $see-also with-entities } ;

HELP: with-entities
{ $values { "entities" "a hash table of strings to strings" } { "quot" { $quotation ( -- ) } } }
{ $description "Calls the quotation using the given table of entity values (symbolizing, eg, that " { $snippet "&foo;" } " represents " { $snippet "\"a\"" } ") on top of the default XML entities" } ;
