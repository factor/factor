! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.

IN: enchilada.engine
USING: generic kernel math sequences isequences.interface isequences.base isequences.ops ;

! Provides Enchilada's rewriting expression engine.
!

GENERIC: !! ( list -- list )
GENERIC: \\ ( list -- list )

GENERIC: e-reducible? ( e -- ? )
GENERIC: e-dyadic? ( o -- ? )
GENERIC: e-operator? ( o -- ? )
GENERIC: e-list? ( o -- ? )
GENERIC: e-symbol? ( o -- ? )

GENERIC: e-m-operate ( v op -- e )
GENERIC: e-d-operate ( v1 v2 op -- e )

GENERIC: e-reduce ( e -- e )
GENERIC: free-symbols ( s -- symbols )

TUPLE: ireplace from to seq ;

: unpack-ireplace ( ireplace -- from to seq )
    dup ireplace-from swap dup ireplace-to swap ireplace-seq ; inline

GENERIC: e-replace ( from to sequence -- s )

: (ireplace1) ( from to seq -- ireplace )
    dup is-atom?
    [ pick over i-cmp 0 = [ drop nip ] [ nip nip ] if ]
    [ <ireplace> ] if ;
    
: <i-replace> ( from to seq -- ireplace )
   dup i-length dup 0 =
   [ 3drop drop 0 ]
   [ 1 = [ (ireplace1) ] [ <ireplace> ] if ]
   if ;
       
: ireplace-i-at ( s i -- v )
   swap dup ireplace-seq rot i-at dup >r swap dup ireplace-from rot i-cmp 0 =
   [ r> drop ireplace-to ]
   [ dup ireplace-from swap ireplace-to r> e-replace ]
   if ;
    
M: object e-replace <i-replace> ;
M: integer e-replace -rot 2drop ;

M: ireplace i-length ireplace-seq i-length ;
M: ireplace i-at ireplace-i-at ;
M: ireplace ileft unpack-ireplace ileft e-replace ;
M: ireplace iright unpack-ireplace iright e-replace ;
M: ireplace ihead (ihead) ;
M: ireplace itail (itail) ;
M: ireplace $$ unpack-ireplace [ $$ ] 2apply rot $$ quick-hash quick-hash ;

TUPLE: esymbol seq ;

GENERIC: esymbol/i-cmp ( esymbol s -- i )

M: object esymbol/i-cmp 2drop -1 ;
M: esymbol esymbol/i-cmp swap [ esymbol-seq ] 2apply i-cmp ;
M: esymbol object/i-cmp 2drop 1 ;
M: esymbol i-cmp swap esymbol/i-cmp ; 

DEFER: (sunion)

: (sunion6) ( s1 s2 -- s )
    2dup [ 0 i-at ] 2apply i-cmp dup zero?
    [ 2drop ] [ 0 > [ swap ] when ++ ] if ; inline
    
: (sunion5) ( s1 s2 -- s )
    over ileft i-length pick swap i-at icut rot left-right
    swap roll (sunion) -rot swap (sunion) ++ ; inline

: (sunion4) ( s1 s2 -- s )
   2dup ifirst swap ilast i-cmp dup zero?
   [ drop 1 itail ++ ] [ 0 > [ ++ ] [ (sunion5) ] if ] if ; inline

: (sunion3) ( s1 s2 ls1 ls2 -- s )
    1 = 
    [ 1 = [ (sunion6) ] [ (sunion4) ] if ]
    [ 1 = [ swap ] when (sunion4) ] if ; inline

: (sunion2) ( s1 s2 -- s )
    2dup [ i-length ] 2apply 2dup zero?
    [ 3drop drop ] [ zero? [ 2drop nip ] [ (sunion3) ] if ] if ; inline
    
: (sunion) ( s1 s2 -- s )
    2dup eq? [ drop ] [ (sunion2) ] if ; inline

: s-union ( s1 s2 -- s )
    (sunion) ; inline

: (free-symbols) ( s -- symbols )
    dup is-atom?
    [ dup e-symbol? [ drop 0 ] unless ]
    [ 0 i-at free-symbols ] if ;

M: object free-symbols
    dup i-length dup 0 =
    [ 2drop 0 ]
    [ 1 = [ (free-symbols) ] [ left-right [ free-symbols ] 2apply s-union ] if ] if ;

M: integer free-symbols drop 0 ;

M: object !!
    dup i-length dup 0 =
    [ 2drop 0 ]
    [ 1 = [ 0 i-at dup left-side swap right-side [ e-reduce ] 2apply <i-dual-sided> <i> ] [ left-right [ !! ] 2apply ++ ] if ] if ;

M: integer !! ;


: (\\) ( expr -- list )
   dup i-length dup 0 =
   [ 2drop 0 ]
   [ 1 = [ <i> ] [ left-right [ (\\) ] 2apply ++ ] if ] if ;

M: object \\
    dup i-length dup 0 =
    [ 2drop 0 ]
    [ 1 = [ 0 i-at left-side (\\) ] [ left-right [ \\ ] 2apply ++ ] if ] if ; 
M: integer \\ ;

TUPLE: emacro symbols expr eager? ;

: symbol-list? ( symbols -- ? )
    i-sort dup free-symbols i-cmp 0 = ; inline

: full-reduce ( expr -- expr )
	dup e-reducible? [ e-reduce full-reduce ] when ;

: <e-macro> ( symbols expr eager? -- e-macro )
    dup [ swap full-reduce swap ] when
    >r swap dup symbol-list? [ swap r> <emacro> ] [ "illegal symbol list" throw ] if ;

M: emacro free-symbols dup emacro-expr free-symbols swap emacro-symbols i-diff ;

M: emacro e-replace
    pick over [ free-symbols ] 2apply i-intersect i-length 0 =
    [ -rot 2drop ]
    [ dup >r emacro-expr e-replace r> dup emacro-symbols swap emacro-eager? rot swap <e-macro> ] if ;

: eflatten ( s -- s )
    dup i-length dup zero?
    [ 2drop 0 ]
    [ 1 = [ 0 i-at left-side ] [ left-right [ eflatten ] 2apply ++ ] if ] if ; inline
    
TUPLE: c-op v d-op ;

M: object e-operator? drop f ;
M: object e-list? dup e-operator? not swap e-symbol? not and ;
M: object e-symbol? drop f ;
M: object e-dyadic? drop f ;

M: esymbol e-symbol? drop t ;

M: c-op e-m-operate
    dup c-op-v swap c-op-d-op e-d-operate ; 
    
TUPLE: .- ;
M: .- e-m-operate drop -- <i> ;
TUPLE: .` ;
M: .` e-m-operate drop `` <i> ;
TUPLE: .$ ;
M: .$ e-m-operate drop $$ <i> ;
TUPLE: .~ ;
M: .~ e-m-operate drop ~~ <i> ;
TUPLE: .: ;
M: .: e-m-operate drop :: <i> ;
TUPLE: .# ;
M: .# e-m-operate drop ## <i> ;
TUPLE: .^ ;
M: .^ e-m-operate drop eflatten ;
TUPLE: .! ;
M: .! e-m-operate drop !! <i> ;
TUPLE: .\ ;
M: .\ e-m-operate drop \\ <i> ;
    
TUPLE: .+ ;
M: .+ e-d-operate drop ++ <i> ;
TUPLE: .* ;
M: .* e-d-operate drop ** [ <i> ] 2apply ++ ;
TUPLE: ./ ;
M: ./ e-d-operate drop // [ <i> ] 2apply ++ ;
TUPLE: .& ;
M: .& e-d-operate drop && <i> ;
TUPLE: .| ;
M: .| e-d-operate drop || <i> ;
TUPLE: .< ;
M: .< e-d-operate drop << [ <i> ] 2apply ++ ;
TUPLE: .> ;
M: .> e-d-operate drop >> <i> ;
TUPLE: .@ ;
M: .@ e-d-operate >r swap 0 i-cmp 0 = [ dup eflatten swap <i> ++ r> ++ ] [ r> 2drop 0 ] if ;
TUPLE: .? ;
M: .? e-d-operate drop (i-eq?) [ 1 ] [ 0 ] if <i> ;
TUPLE: .% ;
M: .% e-d-operate drop %% [ <i> ] 2apply ++ ;

UNION: monadic-class c-op .- .` .$ .~ .: .# .^ .! .\ emacro ;
UNION: dyadic-class .+ .* ./ .& .| .< .> .@ .? .% ;
UNION: operator-class monadic-class dyadic-class ;

M: operator-class e-operator? drop t ;
M: monadic-class e-dyadic? drop f ;
M: dyadic-class e-dyadic? drop t ;

DEFER: +e+ 

: (e-reducible?) ( e -- ? )
    left-right 2dup [ e-reducible? ] either?
    [ 2drop t ] [ ifirst e-operator? swap ilast e-list? and ] if ; inline
        
M: object e-reducible?
    dup i-length 1 <= [ drop f ] [ (e-reducible?) ] if ;

: (e-reduce2) ( e1 e2 -- e )
    2dup ifirst swap ilast swap e-m-operate
    -rot 1 itail swap dup i-length 1- ihead rot ++ swap ++ ; inline
    
: (e-reduce) ( e -- e )
    left-right swap dup e-reducible? [ (e-reduce) swap ++ ]
    [ swap dup e-reducible? [ (e-reduce) ++ ] [ (e-reduce2) ] if ] if ; inline

M: object e-reduce
    dup e-reducible? [ (e-reduce) ] when ;

: (+e+2) ( e1 e2 -- e )
    2dup ifirst swap ilast swap <c-op>
    -rot 1 itail swap dup i-length 1- ihead rot ++ swap ++ ; inline

: (+e+1) ( e1 e2 -- e )
    2dup ifirst e-dyadic? swap ilast e-list? and
    [ (+e+2) ] [ ++g ] if ; inline

TUPLE: e-exp expr reducible ;

M: e-exp e-reducible? e-exp-reducible ;

: <expr> ( s -- e-exp )
    dup e-exp? [ dup e-reducible? <e-exp> ] unless ; inline

: +e+ ( e1 e2 -- e )
    2dup [ i-length 1 >= ] both?
    [ (+e+1) ] [ ++g ] if <expr> ; inline

: e-ipair ( e1 e2 -- e )
    <isequence> <expr> ; inline

M: c-op e-replace dup >r c-op-v e-replace r> c-op-d-op <c-op> ;


GENERIC: e-exp/++ ( s e -- e )
GENERIC: e-exp/ipair ( s e -- e )

M: e-exp ++ swap e-exp/++ ;
M: e-exp ipair swap e-exp/ipair ;

M: object e-exp/++ swap +e+ ;
M: object e-exp/ipair swap e-ipair ;

M: e-exp e-exp/++ swap +e+ ;
M: e-exp e-exp/ipair swap e-ipair ;
M: e-exp object/++ swap +e+ ;
M: e-exp object/ipair swap e-ipair ;

M: operator-class ++ +e+ ;
        
M: e-exp i-length e-exp-expr i-length ;
M: e-exp i-at swap e-exp-expr swap i-at ;
M: e-exp ileft e-exp-expr ileft ;
M: e-exp iright e-exp-expr iright ;
M: e-exp ihead swap e-exp-expr swap ihead ;
M: e-exp itail swap e-exp-expr swap itail ;
M: e-exp $$ e-exp-expr $$ ;

M: e-exp e-replace 
    dup i-length 1 =
    [ e-exp-expr e-replace ]
    [ 3dup iright e-replace >r ileft e-replace r> ++ ] if ;

TUPLE: ereplacement from to ;

: (ereplace) ( symbols from-symbol --  to-symbol )
   esymbol-seq dup ++ <esymbol> dup pick i-intersect i-length zero?
   [ nip ] [ (ereplace) ] if ; inline

: (replacements3) ( symbols from-symbol --  newsymbols replacement )
    2dup (ereplace) rot over i-union -rot <ereplacement> ; inline

: (replacements2) ( symbols intersect -- replacements )
   dup i-length zero?
   [ 2drop 0 ]
   [ dup >r ifirst (replacements3) swap r> 1 itail (replacements2) ++ ] if ;

: replace-s ( s replacements -- s )
    dup i-length dup zero?
    [ 2drop ]
    [ 1 = [ 0 i-at dup ereplacement-from swap ereplacement-to rot e-replace ] [ left-right >r replace-s r> replace-s ] if ] if ; 

: (replacements) ( value macro -- replacements )
    dup emacro-expr free-symbols swap emacro-symbols -1 ++
    i-intersect tuck swap free-symbols i-intersect (replacements2) ; inline 

: (replace-macro) ( replacements macro -- macro )
    2dup dup >r emacro-symbols swap replace-s swap emacro-expr rot replace-s r> emacro-eager? <e-macro> ;
    
: (eval-macro) ( value macro -- macro )
    dup >r emacro-symbols dup -1 ++ swap ilast rot <i> r> dup >r emacro-expr e-replace r> emacro-eager? <e-macro> ;

: eval-macro ( value macro -- s )
    2dup (replacements) swap (replace-macro) (eval-macro) ;

: emacro-e-m-operate ( value macro -- s )
	eval-macro dup emacro-symbols i-length zero? [ emacro-expr ] when ;

M: emacro e-m-operate emacro-e-m-operate ;
