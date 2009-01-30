USING: help.markup help.syntax present multiline xml.data ;
IN: xml.literals

ABOUT: "xml.literals"

ARTICLE: "xml.literals" "XML literals"
"The " { $vocab-link "xml.literals" } " vocabulary provides a convenient syntax for generating XML documents and chunks. It defines the following parsing words:"
{ $subsection POSTPONE: <XML }
{ $subsection POSTPONE: [XML }
"These can be used for creating an XML literal, which can be used with variables or a fry-like syntax to interpolate data into XML."
{ $subsection { "xml.literals" "interpolation" } } ;

HELP: <XML
{ $syntax "<XML <?xml version=\"1.0\"?><document>...</document> XML>" }
{ $description "This gives syntax for literal XML documents. When evaluated, there is an XML document (" { $link xml } ") on the stack. It can be used for interpolation as well, if interpolation slots are used. For more information about XML interpolation, see " { $link { "xml.literals" "interpolation" } } "." } ;

HELP: [XML
{ $syntax "[XML foo <x>...</x> bar <y>...</y> baz XML]" }
{ $description "This gives syntax for literal XML documents. When evaluated, there is an XML chunk (" { $link xml-chunk } ") on the stack. For more information about XML interpolation, see " { $link { "xml.literals" "interpolation" } } "." } ;

ARTICLE: { "xml.literals" "interpolation" } "XML interpolation syntax"
"XML interpolation has two forms for each of the words " { $link POSTPONE: <XML } " and " { $link POSTPONE: [XML } ": a fry-like form and a locals form. To splice locals in, use the syntax " { $snippet "<-variable->" } ". To splice something in from the stack, in the style of " { $vocab-link "fry" } ", use the syntax " { $snippet "<->" } ". An XML interpolation form may only use one of these styles."
$nl
"These forms can be used where a tag might go, as in " { $snippet "[XML <foo><-></foo> XML]" } " or where an attribute might go, as in " { $snippet "[XML <foo bar=<->/> XML]" } ". When an attribute is spliced in, it is not included if the value is " { $snippet "f" } " and if the value is not a string, the value is put through " { $link present } ". Here is an example of the fry style of XML interpolation:"
{ $example 
{" USING: splitting sequences xml.writer xml.literals ;
"one two three" " " split
[ [XML <item><-></item> XML] ] map
<XML <doc><-></doc> XML> pprint-xml"}
{" <?xml version="1.0" encoding="UTF-8"?>
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
</doc>"} }
"Here is an example of the locals version:"
{ $example
{" USING: locals urls xml.literals xml.writer ;
[let |
    number [ 3 ]
    false [ f ]
    url [ URL" http://factorcode.org/" ]
    string [ "hello" ]
    word [ \ drop ] |
    <XML
        <x
            number=<-number->
            false=<-false->
            url=<-url->
            string=<-string->
            word=<-word-> />
    XML> pprint-xml ] "}
{" <?xml version="1.0" encoding="UTF-8"?>
<x number="3" url="http://factorcode.org/" string="hello" word="drop"/>"} } ;
