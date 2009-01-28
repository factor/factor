USING: help.markup help.syntax present multiline ;
IN: xml.interpolate

ABOUT: "xml.interpolate"

ARTICLE: "xml.interpolate" "XML literal interpolation"
"The " { $vocab-link "xml.interpolate" } " vocabulary provides a convenient syntax for generating XML documents and chunks. It defines the following parsing words:"
{ $subsection POSTPONE: <XML }
{ $subsection POSTPONE: [XML }
"For a description of the common syntax of these two, see"
{ $subsection { "xml.interpolate" "in-depth" } } ;

HELP: <XML
{ $syntax "<XML <?xml version=\"1.0\"?><document>...</document> XML>" }
{ $description "This syntax allows the interpolation of XML documents. When evaluated, there is an XML document on the stack. For more information about XML interpolation, see " { $link { "xml.interpolate" "in-depth" } } "." } ;

HELP: [XML
{ $syntax "[XML foo <x>...</x> bar <y>...</y> baz XML]" }
{ $description "This syntax allows the interpolation of XML chunks. When evaluated, there is a sequence of XML elements (tags, strings, comments, etc) on the stack. For more information about XML interpolation, see " { $link { "xml.interpolate" "in-depth" } } "." } ;

ARTICLE: { "xml.interpolate" "in-depth" } "XML interpolation syntax"
"XML interpolation has two forms for each of the words " { $link POSTPONE: <XML } " and " { $link POSTPONE: [XML } ": a fry-like form and a locals form. To splice locals in, use the syntax " { $snippet "<-variable->" } ". To splice something in from the stack, in the style of " { $vocab-link "fry" } ", use the syntax " { $snippet "<->" } ". An XML interpolation form may only use one of these styles."
$nl
"These forms can be used where a tag might go, as in " { $snippet "[XML <foo><-></foo> XML]" } " or where an attribute might go, as in " { $snippet "[XML <foo bar=<->/> XML]" } ". When an attribute is spliced in, it is not included if the value is " { $snippet "f" } " and if the value is not a string, the value is put through " { $link present } ". Here is an example of the fry style of XML interpolation:"
{ $example 
{" USING: splitting sequences xml.writer xml.interpolate ;
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
{" USING: locals urls xml.interpolate xml.writer ;
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
