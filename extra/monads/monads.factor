! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel sequences sequences.deep splitting
accessors fry locals combinators namespaces lists lists.lazy
shuffle ;
IN: monads

! Functors
GENERIC# fmap 1 ( functor quot -- functor' ) inline

! Monads

! Mixin type for monad singleton classes, used for return/fail only
MIXIN: monad

GENERIC: monad-of ( mvalue -- singleton )
GENERIC: return ( string singleton -- mvalue )
GENERIC: fail ( value singleton -- mvalue )
GENERIC: >>= ( mvalue -- quot )

M: monad return monad-of return ;
M: monad fail   monad-of fail   ;

: bind ( mvalue quot -- mvalue' ) swap >>= call ;
: >>   ( mvalue k -- mvalue' ) '[ drop , ] bind ;

:: lift-m2 ( m1 m2 f monad -- m3 )
    m1 [| x1 | m2 [| x2 | x1 x2 f monad return ] bind ] bind ;

:: apply ( mvalue mquot monad -- result )
    mvalue [| value |
        mquot [| quot |
            value quot call monad return
        ] bind
    ] bind ;

M: monad fmap over '[ @ , return ] bind ;

! 'do' notation
: do ( quots -- result ) unclip dip [ bind ] each ;

! Identity
SINGLETON: identity-monad
INSTANCE:  identity-monad monad

TUPLE: identity value ;
INSTANCE: identity monad

M: identity monad-of drop identity-monad ;

M: identity-monad return drop identity boa ;
M: identity-monad fail   "Fail" throw ;

M: identity >>= value>> '[ , _ call ] ;

: run-identity ( identity -- value ) value>> ;

! Maybe
SINGLETON: maybe-monad
INSTANCE:  maybe-monad monad

SINGLETON: nothing

TUPLE: just value ;
: just \ just boa ;

UNION: maybe just nothing ;
INSTANCE: maybe monad

M: maybe monad-of drop maybe-monad ;

M: maybe-monad return drop just ;
M: maybe-monad fail   2drop nothing ;

M: nothing >>= '[ drop , ] ;
M: just    >>= value>> '[ , _ call ] ;

: if-maybe ( maybe just-quot nothing-quot -- )
    pick nothing? [ 2nip call ] [ drop [ value>> ] dip call ] if ; inline

! Either
SINGLETON: either-monad
INSTANCE:  either-monad monad

TUPLE: left value ;
: left \ left boa ;

TUPLE: right value ;
: right \ right boa ;

UNION: either left right ;
INSTANCE: either monad

M: either monad-of drop either-monad ;

M: either-monad return  drop right ;
M: either-monad fail    drop left ;

M: left  >>= '[ drop , ] ;
M: right >>= value>> '[ , _ call ] ;

: if-either ( value left-quot right-quot -- )
    [ [ value>> ] [ left? ] bi ] 2dip if ; inline

! Arrays
SINGLETON: array-monad
INSTANCE:  array-monad monad
INSTANCE:  array monad

M: array-monad return  drop 1array ;
M: array-monad fail   2drop { } ;

M: array monad-of drop array-monad ;

M: array >>= '[ , _ map concat ] ;

! List
SINGLETON: list-monad
INSTANCE:  list-monad monad
INSTANCE:  list monad

M: list-monad return drop 1list ;
M: list-monad fail   2drop nil ;

M: list monad-of drop list-monad ;

M: list >>= '[ , _ lmap lconcat ] ;

! State
SINGLETON: state-monad
INSTANCE:  state-monad monad

TUPLE: state quot ;
: state \ state boa ;

INSTANCE: state monad

M: state monad-of drop state-monad ;

M: state-monad return drop '[ , 2array ] state ;
M: state-monad fail   "Fail" throw ;

: mcall quot>> call ;

M: state >>= '[ , _ '[ , mcall first2 @ mcall ] state ] ;

: get-st ( -- state ) [ dup 2array ] state ;
: put-st ( value -- state ) '[ drop , f 2array ] state ;

: run-st ( state initial -- ) swap mcall second ;

: return-st state-monad return ;

! Reader
SINGLETON: reader-monad
INSTANCE:  reader-monad monad

TUPLE: reader quot ;
: reader \ reader boa ;
INSTANCE: reader monad

M: reader monad-of drop reader-monad ;

M: reader-monad return drop '[ drop , ] reader ;
M: reader-monad fail   "Fail" throw ;

M: reader >>= '[ , _ '[ dup , mcall @ mcall ] reader ] ;

: run-reader ( reader env -- ) swap mcall ;

: ask ( -- reader ) [ ] reader ;
: local ( reader quot -- reader' ) swap '[ @ , mcall ] reader ;

! Writer
SINGLETON: writer-monad
INSTANCE:  writer-monad monad

TUPLE: writer value log ;
: writer \ writer boa ;

M: writer monad-of drop writer-monad ;

M: writer-monad return drop { } writer ;
M: writer-monad fail   "Fail" throw ;

: run-writer ( writer -- value log ) [ value>> ] [ log>> ] bi ;

M: writer >>= '[ , run-writer _ '[ @ run-writer ] dip append writer ] ;

: pass ( writer -- writer' ) run-writer [ first2 ] dip swap call writer ;
: listen ( writer -- writer' ) run-writer [ 2array ] keep writer ;
: tell ( seq -- writer ) f swap writer ;
