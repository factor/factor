USING: help.markup help.syntax io present ;
IN: html.elements

ARTICLE: "html.elements" "HTML elements"
"The " { $vocab-link "html.elements" } " vocabulary provides words for writing HTML tags to the " { $link output-stream } " with a familiar look and feel in the code."
$nl
"HTML tags can be used in a number of different ways. The simplest is a tag with no attributes:"
{ $code "<p> \"someoutput\" write </p>" }
"In the above, " { $link <p> } " will output the opening tag with no attributes. and " { $link </p> } " will output the closing tag."
{ $code "<p \"red\" =class p> \"someoutput\" write </p>" }
"This time the opening tag does not have the '>'. Any attribute words used between the calls to " { $link <p } " and " { $link p> } " will write an attribute whose value is the top of the stack. Attribute values can be any object supported by the " { $link present } " word."
$nl
"Values for attributes can be used directly without any stack operations. Assuming we have a string on the stack, all three of the below will output a link:"
{ $code "<a =href a> \"Click me\" write </a>" }
{ $code "<a \"http://\" prepend =href a> \"click\" write </a>" }
{ $code "<a [ \"http://\" % % ] \"\" make =href a> \"click\" write </a>" }
"Tags that have no \"closing\" equivalent have a trailing " { $snippet "tag/>" } " form:"
{ $code "<input \"text\" =type \"name\" =name 20 =size input/>" }
"For the full list of HTML tags and attributes, consult the word list for the " { $vocab-link "html.elements" } " vocabulary. In addition to HTML tag and attribute words, a few utilities are provided."
$nl
"Writing unescaped HTML to " { $vocab-link "html.streams" } ":"
{ $subsections
    write-html
    print-html
} ;

ABOUT: "html.elements"
