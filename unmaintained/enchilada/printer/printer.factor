! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.

IN: enchilada.printer
USING: prettyprint strings generic kernel math math.parser sequences isequences.interface isequences.base enchilada.engine ;

: s-append ( s1 s2 s3 -- s )
    swap append append ;

DEFER: e-print
DEFER: l-print

GENERIC: (e-print) ( op -- string ) 

M: .- (e-print) drop "-" ;
M: .# (e-print) drop "#" ;
M: .$ (e-print) drop "$" ;
M: .^ (e-print) drop "^" ;
M: .` (e-print) drop "`" ;
M: .~ (e-print) drop "~" ;
M: .: (e-print) drop ":" ;
M: .! (e-print) drop "!" ;
M: .\ (e-print) drop "\\" ;

M: .+ (e-print) drop "+" ;
M: .* (e-print) drop "*" ;
M: ./ (e-print) drop "/" ;
M: .< (e-print) drop "<" ;
M: .> (e-print) drop ">" ;
M: .| (e-print) drop "|" ;
M: .& (e-print) drop "&" ;
M: .@ (e-print) drop "@" ;
M: .? (e-print) drop "?" ;
M: .% (e-print) drop "%" ;

: (eprint-macro-expr) ( emacro -- string )
   dup emacro-expr dup i-length 0 =
   [ 2drop "" ]
   [ e-print swap emacro-eager? [ "==" ] [ "=" ] if swap append ] if ;

: (l-print1) ( e-list -- string )
    0 i-at dup left-side swap right-side dup 0 =
    [ drop dup i-length 0 = [ drop " " ] [ e-print ] if ] [ e-print swap e-print swap "=" s-append ] if ;
    
: (l-print0) ( e-list -- string )
    left-right [ l-print ] 2apply ";" s-append ;

: l-print ( e-list -- string )
    dup i-length dup 0 =
    [ 2drop "0" ] [ 1 = [ (l-print1) ] [ (l-print0) ] if ] if ;

: prefix-neg ( s -- s prefix )
   dup i-length 0 < [ -- "_" ] [ "" ] if ;

: (e-print3) ( symbol -- string )
    esymbol-seq to-sequence >string ;

: (e-print2) ( e-list -- string )
    dup integer? [ prefix-neg swap number>string append ] [ prefix-neg "[" append swap l-print "]" append append ] if ;
    
: (e-print1) ( e-expression -- string )
    0 i-at dup e-operator? [ (e-print) ] [ dup e-symbol? [ (e-print3) ] [ (e-print2) ] if ] if ;
        
: e-print ( e-expression -- string )
    dup i-length dup 0 =
    [ 2drop "" ]
    [ 1 = [ (e-print1) ] [ left-right [ e-print ] 2apply " " s-append ] if ] if ;

M: c-op (e-print) dup c-op-d-op swap c-op-v (e-print2) swap (e-print) " " s-append ;
M: emacro (e-print) "{" swap dup emacro-symbols e-print swap (eprint-macro-expr) "}" append append append ;

