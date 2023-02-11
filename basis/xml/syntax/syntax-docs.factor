! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax xml.data present ;
IN: xml.syntax

ABOUT: "xml.syntax"

ARTICLE: "xml.syntax" "Syntax extensions for XML"
"The " { $link "xml.syntax" } " vocabulary defines a number of new parsing words for XML processing."
{ $subsections
    { "xml.syntax" "tags" }
    { "xml.syntax" "literals" }
    POSTPONE: XML-NS:
} ;

ARTICLE: { "xml.syntax" "tags" } "Dispatch on XML tag names"
"There is a system, analogous to generic words, for processing XML. A word can dispatch off the name of the tag that is passed to it. To define such a word, use"
{ $subsections POSTPONE: TAGS: }
"and to define a new 'method' for this word, use"
{ $subsections POSTPONE: TAG: } ;

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

ARTICLE: { "xml.syntax" "literals" } "XML literals"
"The following words provide syntax for XML literals:"
{ $subsections
    POSTPONE: <XML
    POSTPONE: [XML
}
"These can be used for creating an XML literal, which can be used with variables or a fry-like syntax to interpolate data into XML."
{ $subsections { "xml.syntax" "interpolation" } } ;

HELP: <XML
{ $syntax "<XML <?xml version=\"1.0\"?><document>...</document> XML>" }
{ $description "This gives syntax for literal XML documents. When evaluated, there is an XML document (" { $link xml } ") on the stack. It can be used for interpolation as well, if interpolation slots are used. For more information about XML interpolation, see " { $link { "xml.syntax" "interpolation" } } "." } ;

HELP: [XML
{ $syntax "[XML foo <x>...</x> bar <y>...</y> baz XML]" }
{ $description "This gives syntax for literal XML documents. When evaluated, there is an XML chunk (" { $link xml-chunk } ") on the stack. For more information about XML interpolation, see " { $link { "xml.syntax" "interpolation" } } "." } ;

ARTICLE: { "xml.syntax" "interpolation" } "XML interpolation syntax"
"XML interpolation has two forms for each of the words " { $link POSTPONE: <XML } " and " { $link POSTPONE: [XML } ": a fry-like form and a locals form. To splice locals in, use the syntax " { $snippet "<-variable->" } ". To splice something in from the stack, in the style of " { $vocab-link "fry" } ", use the syntax " { $snippet "<->" } ". An XML interpolation form may only use one of these styles."
$nl
"These forms can be used where a tag might go, as in " { $snippet "[XML <foo><-></foo> XML]" } " or where an attribute might go, as in " { $snippet "[XML <foo bar=<->/> XML]" } ". When an attribute is spliced in, it is not included if the value is " { $snippet "f" } " and if the value is not a string, the value is put through " { $link present } ". Here is an example of the fry style of XML interpolation:"
{ $example
"USING: splitting xml.writer xml.syntax ;
\"one two three\" \" \" split
[ [XML <item><-></item> XML] ] map
<XML <doc><-></doc> XML> pprint-xml"

"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<doc>
  <item>
    one
  </item>
  <item>
    two
  </item>
  <item>
    three
  </item>
</doc>" }
"Here is an example of the locals version:"
{ $example
"USING: locals urls xml.syntax xml.writer ;
[let
    3 :> number
    f :> false
    URL\" https://factorcode.org/\" :> url
    \"hello\" :> string
    \\ drop :> word
    <XML
        <x
            number=<-number->
            false=<-false->
            url=<-url->
            string=<-string->
            word=<-word-> />
    XML> pprint-xml
]"

"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<x number=\"3\" url=\"https://factorcode.org/\" string=\"hello\" word=\"drop\"/>" }
"XML interpolation can also be used, in conjunction with " { $vocab-link "inverse" } " in pattern matching. For example:"
{ $example "USING: xml.syntax inverse ;
: dispatch ( xml -- string )
    {
        { [ [XML <a><-></a> XML] ] [ \"a\" prepend ] }
        { [ [XML <b><-></b> XML] ] [ \"b\" prepend ] }
        { [ [XML <b val='yes'/> XML] ] [ \"yes\" ] }
        { [ [XML <b val=<->/> XML] ] [ \"no\" prepend ] }
    } switch ;
[XML <a>pple</a> XML] dispatch write"
"apple" } ;

HELP: XML-NS:
{ $syntax "XML-NS: name https://url" }
{ $description "Defines a new word of the given name which constructs XML names in the namespace of the given URL. The names constructed are memoized." } ;
