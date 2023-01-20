! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax xml.entities ;
IN: xml.entities.html

ARTICLE: "xml.entities.html" "HTML entities"
{ $vocab-link "xml.entities.html" } " defines words for using entities defined in HTML/XHTML."
{ $subsections
    html-entities
    with-html-entities
} ;

HELP: html-entities
{ $description "A hash table from HTML entity names to their character values." }
{ $see-also entities with-html-entities } ;

HELP: with-html-entities
{ $values { "quot" "a quotation ( -- )" } }
{ $description "Calls the given quotation using HTML entity values." }
{ $see-also html-entities with-entities } ;
