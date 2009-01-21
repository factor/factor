! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: xml.errors

HELP: multitags
{ $class-description "XML parsing error describing the case where there is more than one main tag in a document. Contains no slots" } ;

HELP: notags
{ $class-description "XML parsing error describing the case where an XML document contains no main tag, or any tags at all" } ;

HELP: extra-attrs
{ $class-description "XML parsing error describing the case where the XML prolog (<?xml ...?>) contains attributes other than the three allowed ones, standalone, version and encoding. Contains one slot, attrs, which is a hashtable of all the extra attributes' names. Delegates to " { $link parsing-error } "." } ;

HELP: nonexist-ns
{ $class-description "XML parsing error describing the case where a namespace doesn't exist but it is used in a tag. Contains one slot, name, which contains the name of the undeclared namespace, and delegates to " { $link parsing-error } "." } ;

HELP: not-yes/no
{ $class-description "XML parsing error used to describe the case where standalone is set in the XML prolog to something other than 'yes' or 'no'. Delegates to " { $link parsing-error } " and contains one slot, text, which contains offending value." } ;

HELP: unclosed
{ $class-description "XML parsing error used to describe the case where the XML document contains classes which are not closed by the end of the document. Contains one slot, tags, a sequence of names." } ;

HELP: mismatched
{ $class-description "XML parsing error describing mismatched tags, eg <a></c>. Contains two slots: open is the name of the opening tag and close is the name of the closing tag. Delegates to " { $link parsing-error } " showing the location of the closing tag" } ;

HELP: expected
{ $class-description "XML parsing error describing when an expected token was not present. Delegates to " { $link parsing-error } ". Contains two slots, should-be, which has the expected string, and was, which has the actual string." } ;

HELP: no-entity
{ $class-description "XML parsing error describing the use of an undefined entity in a case where standalone is marked yes. Delegates to " { $link parsing-error } ". Contains one slot, thing, containing a string representing the entity." } ;


HELP: pre/post-content
{ $class-description "describes the error where a non-whitespace string is used before or after the main tag in an XML document. Contains two slots: string contains the offending string, and pre? is t if it occured before the main tag and f if it occured after" } ;

HELP: unclosed-quote
{ $class-description "describes the error where a quotation for an attribute value is opened but not closed before the end of the document." } ;

HELP: bad-name
{ $class-description "describes the error where a name is used, for example in an XML tag or attribute key, which is invalid." } ;

HELP: quoteless-attr
{ $class-description "describes the error where an attribute of an XML tag is missing quotes around a value." } ;

HELP: xml-parse-error
{ $class-description "the exception class that all parsing errors in XML documents are in." } ;

ARTICLE: "xml.errors" "XML parsing errors"
    { $vocab-link "xml.errors" } " provides a rich and highly inspectable set of parsing errors. All XML errors are described by the union class " { $link xml-parse-error } " but there are many classes contained in that:"
    { $subsection multitags }
    { $subsection notags }
    { $subsection extra-attrs }
    { $subsection nonexist-ns }
    { $subsection not-yes/no }
    { $subsection unclosed }
    { $subsection mismatched }
    { $subsection expected }
    { $subsection no-entity }
    { $subsection pre/post-content }
    { $subsection unclosed-quote }
    { $subsection bad-name }
    { $subsection quoteless-attr }
    "Additionally, most of these errors are a kind of " { $link parsing-error } " which provides more information"
    $nl
    "Note that, in parsing an XML document, only the first error is reported." ;

ABOUT: "xml.errors"
