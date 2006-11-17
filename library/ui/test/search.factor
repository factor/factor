IN: temporary
USING: gadgets-search io test namespaces gadgets 
sequences threads freetype timers kernel ;

timers get [ init-timers ] unless

[
    "set-word-prop" [ ] <word-search> "search" set
    "search" get graft
    
    1000 sleep
    do-timers
    
    [ f ]
    [ "search" get live-search-list control-value empty? ]
    unit-test
    
    "search" get ungraft
] with-freetype
