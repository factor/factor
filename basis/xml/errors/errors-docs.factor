! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: xml.errors

<PRIVATE

: $xml-error ( element -- )
    "Bad XML document for the error" $heading $code ;

PRIVATE>

HELP: multitags
{ $class-description "XML parsing error describing the case where there is more than one main tag in a document." }
{ $xml-error "<a/>\n<b/>" } ;

HELP: notags
{ $class-description "XML parsing error describing the case where an XML document contains no main tag, or any tags at all" }
{ $xml-error "<?xml version='1.0'?>" } ;

HELP: extra-attrs
{ $class-description "XML parsing error describing the case where the XML prolog (" { $snippet "<?xml ...?>" } ") contains attributes other than the three allowed ones, " { $snippet "standalone" } ", " { $snippet "version" } " and " { $snippet "encoding" } ". Contains one slot, " { $snippet "attrs" } ", which is a hashtable of all the extra attributes' names." }
{ $xml-error "<?xml version='1.0' reason='because I said so'?>\n<foo/>" } ;

HELP: nonexist-ns
{ $class-description "XML parsing error describing the case where a namespace doesn't exist but it is used in a tag. Contains one slot, " { $snippet "name" } ", which contains the name of the undeclared namespace." }
{ $xml-error "<a:b>c</a:b>" } ;

HELP: not-yes/no
{ $class-description "XML parsing error used to describe the case where standalone is set in the XML prolog to something other than " { $snippet "yes" } " or " { $snippet "no" } ". This contains one slot, text, which contains offending value." }
{ $xml-error "<?xml version='1.0' standalone='maybe'?>\n<x/>" } ;

HELP: unclosed
{ $class-description "XML parsing error used to describe the case where the XML document contains classes which are not closed by the end of the document. Contains one slot, " { $snippet "tags" } ", a sequence of names." }
{ $xml-error "<x>some text" } ;

HELP: mismatched
{ $class-description "XML parsing error describing mismatched tags. Contains two slots: " { $snippet "open" } " is the name of the opening tag and " { $snippet "close" } " is the name of the closing tag. This shows the location of the closing tag" }
{ $xml-error "<a></c>" } ;

HELP: expected
{ $class-description "XML parsing error describing when an expected token was not present. Contains two slots, " { $snippet "should-be" } ", which has the expected string, and " { $snippet "was" } ", which has the actual string." } ;

HELP: no-entity
{ $class-description "XML parsing error describing the use of an undefined entity. Contains one slot, " { $snippet "thing" } ", containing a string representing the entity." }
{ $xml-error "<x>&foo;</x>" } ;


HELP: pre/post-content
{ $class-description "Describes the error where a non-whitespace string is used before or after the main tag in an XML document. Contains two slots: " { $snippet "string" } " contains the offending string, and " { $snippet "pre?" } " is " { $snippet "t" } " if it occurred before the main tag and " { $snippet "f" } " if it occurred after." }
{ $xml-error "hello\n<main-tag/>" } ;

HELP: bad-name
{ $class-description "Describes the error where a name is used, for example in an XML tag or attribute key, which is invalid." }
{ $xml-error "<%>\n</%>" } ;

HELP: quoteless-attr
{ $class-description "Describes the error where an attribute of an XML tag is missing quotes around a value." }
{ $xml-error "<tag foo=bar/>" } ;

HELP: disallowed-char
{ $class-description "Describes the error where a disallowed character occurs in an XML document." } ;

HELP: missing-close
{ $class-description "Describes the error where a particular closing token is missing." } ;

HELP: unexpected-end
{ $class-description "Describes the error where a document unexpectedly ends, and the XML parser expected it to continue." } ;

HELP: duplicate-attr
{ $class-description "Describes the error where there is more than one attribute of the same key." }
{ $xml-error "<tag value='1' value='2'/>" } ;

HELP: bad-cdata
{ $class-description "Describes the error where CDATA is used outside of the main tag of an XML document." }
{ $xml-error "<x>y</x>\n<![CDATA[]]>" } ;

HELP: text-w/]]>
{ $class-description "Describes the error where a text node contains the literal string " { $snippet "]]>" } " which is disallowed." }
{ $xml-error "<x>Here's some text: ]]> there it was</x>" } ;

HELP: attr-w/<
{ $class-description "Describes the error where an attribute value contains the literal character " { $snippet "<" } " which is disallowed." }
{ $xml-error "<x value='bar<baz'/>" } ;

HELP: misplaced-directive
{ $class-description "Describes the error where an internal DTD directive is used outside of a DOCTYPE or DTD file, or where a DOCTYPE occurs somewhere other than before the main tag of an XML document." }
{ $xml-error "<x><!ENTITY foo 'bar'></x>" } ;

HELP: xml-error
{ $class-description "The exception class that all parsing errors in XML documents are in." } ;

ARTICLE: "xml.errors" "XML parsing errors"
"The " { $vocab-link "xml.errors" } " vocabulary provides a rich and highly inspectable set of parsing errors. All XML errors are described by the union class " { $link xml-error } "."
{ $subsections
    multitags
    notags
    extra-attrs
    nonexist-ns
    not-yes/no
    unclosed
    mismatched
    expected
    no-entity
    pre/post-content
    unclosed-quote
    bad-name
    quoteless-attr
    disallowed-char
    missing-close
    unexpected-end
    duplicate-attr
    bad-cdata
    text-w/]]>
    attr-w/<
    misplaced-directive
}
"Additionally, most of these errors are a kind of " { $link xml-error } " which provides more information about where the error occurred."
$nl
"Note that, in parsing an XML document, only the first error is reported." ;

ABOUT: "xml.errors"
