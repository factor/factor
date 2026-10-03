! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io kernel locals math math.parser math.statistics memory namespaces
sequences tools.time ;
IN: benchmark.namespaces.lookup

SYMBOL: root-key
SYMBOL: outer-key
SYMBOL: current-key
SYMBOL: missing-key
SYMBOL: sink

:: nested-scopes ( depth quot: ( -- ns ) -- ns )
    depth zero? [ quot call ] [
        [ 3 current-key set depth 1 - quot nested-scopes ] with-scope
    ] if ; inline recursive

:: environment ( depth quot: ( -- ns ) -- ns )
    depth zero? [ quot call ] [
        [ 2 outer-key set 3 current-key set depth 1 - quot nested-scopes ] with-scope
    ] if ; inline

:: sample ( quot: ( -- ) -- ns )
    quot call
    5 [ gc [ quot call ] benchmark ] replicate median 200,000 /f ; inline

:: row ( depth name quot: ( -- ) -- )
    depth [ quot sample ] environment
    depth number>string write "," write name write "," write
    number>string print ; inline

:: reads ( key -- )
    0 200,000 [ key get 0 or + ] times sink set-global ; inline

: namespace-benchmark ( -- )
    1 root-key set-global 2 outer-key set-global 3 current-key set-global
    "depth,operation,ns" print
    { 0 1 4 16 64 } [| depth |
        depth "current" [ current-key reads ] row
        depth "outer" [ outer-key reads ] row
        depth "global" [ root-key reads ] row
        depth "missing" [ missing-key reads ] row
    ] each ;

MAIN: namespace-benchmark
