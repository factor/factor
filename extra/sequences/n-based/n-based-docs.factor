! (c)2008 Joe Groff, see BSD license etc.
USING: help.markup help.syntax math sequences ;
IN: sequences.n-based

HELP: <n-based-assoc>
{ $values { "seq" sequence } { "base" integer } { "n-based-assoc" n-based-assoc } }
{ $description "Wraps " { $snippet "seq" } " in an " { $link n-based-assoc } " wrapper." }
{ $examples
{ $example "
USING: assocs prettyprint kernel sequences.n-based ;
IN: scratchpad

: months ( -- assoc )
    {
        \"January\"
        \"February\"
        \"March\"
        \"April\"
        \"May\"
        \"June\"
        \"July\"
        \"August\"
        \"September\"
        \"October\"
        \"November\"
        \"December\"
    } 1 <n-based-assoc> ;

10 months at .
" "\"October\"" } } ;

HELP: n-based-assoc
{ $class-description "An adaptor class that allows a sequence to be treated as an assoc with non-zero-based keys." }
{ $examples
{ $example "
USING: assocs prettyprint kernel sequences.n-based ;
IN: scratchpad

: months ( -- assoc )
    {
        \"January\"
        \"February\"
        \"March\"
        \"April\"
        \"May\"
        \"June\"
        \"July\"
        \"August\"
        \"September\"
        \"October\"
        \"November\"
        \"December\"
    } 1 <n-based-assoc> ;

10 months at .
" "\"October\"" } } ;

{ n-based-assoc <n-based-assoc> } related-words

ARTICLE: "sequences.n-based" "N-based sequences"
"The " { $vocab-link "sequences.n-based" } " vocabulary provides a sequence adaptor that allows a sequence to be treated as an assoc with non-zero-based keys."
{ $subsections
    n-based-assoc
    <n-based-assoc>
}
;

ABOUT: "sequences.n-based"
