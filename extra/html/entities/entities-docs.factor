USING: help.markup help.syntax strings ;
IN: html.entities

HELP: html-escape
{ $values { "str" string } { "newstr" string } }
{ $description "Replaces special characters " { $snippet "&" } ", " { $snippet "<" } ", " { $snippet ">" } ", " { $snippet "\"" } ", and " { $snippet "'" } " to HTML-safe sequences." }
{ $examples
    { $example "USING: html.entities prettyprint ;"
               "\"<foo>\" html-escape ."
               "\"&lt;foo&gt;\"" }
} ;

HELP: html-unescape
{ $values { "str" string } { "newstr" string } }
{ $description "Convert all named and numeric character references (e.g. " { $snippet "&gt;" } ", " { $snippet "&#62;" } ", " { $snippet "&#x3e;" } ") in the string " { $snippet "str" } " to the corresponding unicode characters using the rules defined by the HTML5 standard." }
{ $examples
    { $example "USING: html.entities prettyprint ;"
               "\"x &lt; 2 &amp;&amp y &gt; 5\" html-unescape ."
               "\"x < 2 && y > 5\"" }
} ;
