USING: help.markup help.syntax strings ;
IN: html.entities

HELP: html-escape
{ $values { "str" string } { "newstr" string } }
{ $description "Replaces special characters " { $snippet "&" } ", " { $snippet "<" } ", " { $snippet ">" } ", " { $snippet "\"" } ", and " { $snippet "'" } " to HTML-safe sequences." } ;

HELP: html-unescape
{ $values { "str" string } { "newstr" string } }
{ $description "Convert all named and numeric character references (e.g. &gt;, &#62;, &x3e;) in the string " { $snippet "str" } " to the corresponding unicode characters using the rules defined by the HTML5 standard" } ;
