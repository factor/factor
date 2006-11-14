IN: temporary
USING: gadgets-search io test namespaces gadgets 
sequences threads ;

[ "hey man (score: 123)" ]
[
    [
        { "hey man" 123 } [ <pathname> ] string-completion.
    ] string-out
] unit-test

"set-word-prop" [ ] <word-search> "search" set
"search" get graft*

1000 sleep

[ f ]
[ "search" get live-search-list control-value empty? ]
unit-test

"search" get ungraft*

