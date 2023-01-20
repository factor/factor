! Copyright (C) 2008 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel lists lists.lazy sequences ;
IN: monads

! Functors
GENERIC#: fmap 1 ( functor quot -- functor' )
GENERIC#: <$ 1 ( functor quot -- functor' )
GENERIC#: $> 1 ( functor quot -- functor' )

! Monads

! Mixin type for monad singleton classes, used for return/fail only
MIXIN: monad

GENERIC: monad-of ( mvalue -- singleton )
GENERIC: return ( value singleton -- mvalue )
GENERIC: fail ( value singleton -- mvalue )
GENERIC: >>= ( mvalue -- quot )

M: monad return monad-of return ;
M: monad fail   monad-of fail   ;

: bind ( mvalue quot -- mvalue' ) swap >>= call( quot -- mvalue ) ;
: bind* ( mvalue quot -- mvalue' ) '[ drop @ ] bind ;
: >>   ( mvalue k -- mvalue' ) '[ drop _ ] bind ;

:: lift-m2 ( m1 m2 f monad -- m3 )
    m1 [| x1 | m2 [| x2 | x1 x2 f monad return ] bind ] bind ;

:: apply ( mvalue mquot monad -- result )
    mvalue [| value |
        mquot [| quot |
            value quot call( value -- mvalue ) monad return
        ] bind
    ] bind ;

M: monad fmap over '[ @ _ return ] bind ;

! 'do' notation
: do ( quots -- result ) unclip [ call( -- mvalue ) ] curry dip [ bind ] each ;

! Identity
SINGLETON: identity-monad
INSTANCE:  identity-monad monad

TUPLE: identity value ;
INSTANCE: identity monad

M: identity monad-of drop identity-monad ;

M: identity-monad return drop identity boa ;
M: identity-monad fail   "Fail" throw ;

M: identity >>= value>> '[ _ swap call( x -- y ) ] ;

: run-identity ( identity -- value ) value>> ;

! Maybe
SINGLETON: maybe-monad
INSTANCE:  maybe-monad monad

SINGLETON: nothing

TUPLE: just value ;
C: <just> just

UNION: maybe just nothing ;
INSTANCE: maybe monad

M: maybe monad-of drop maybe-monad ;

M: maybe-monad return drop <just> ;
M: maybe-monad fail   2drop nothing ;

M: nothing >>= '[ drop _ ] ;
M: just    >>= value>> '[ _ swap call( x -- y ) ] ;

: if-maybe ( maybe just-quot nothing-quot -- )
    pick nothing? [ 2nip call ] [ drop [ value>> ] dip call ] if ; inline

! Either
SINGLETON: either-monad
INSTANCE:  either-monad monad

TUPLE: left value ;
C: <left> left

TUPLE: right value ;
C: <right> right

UNION: either left right ;
INSTANCE: either monad

M: either monad-of drop either-monad ;

M: either-monad return  drop <right> ;
M: either-monad fail    drop <left> ;

M: left  >>= '[ drop _ ] ;
M: right >>= value>> '[ _ swap call( x -- y ) ] ;

: if-either ( value left-quot right-quot -- )
    [ [ value>> ] [ left? ] bi ] 2dip if ; inline

! Arrays
SINGLETON: array-monad
INSTANCE:  array-monad monad
INSTANCE:  array monad

M: array-monad return  drop 1array ;
M: array-monad fail   2drop { } ;

M: array monad-of drop array-monad ;

M: array >>= '[ _ swap map concat ] ;

! List
SINGLETON: list-monad
INSTANCE:  list-monad monad
INSTANCE:  list monad

M: list-monad return drop 1list ;
M: list-monad fail   2drop nil ;

M: list monad-of drop list-monad ;

M: list >>= '[ _ swap lmap-lazy lconcat ] ;

! State
SINGLETON: state-monad
INSTANCE:  state-monad monad

TUPLE: state quot ;
C: <state> state

INSTANCE: state monad

M: state monad-of drop state-monad ;

M: state-monad return drop '[ _ 2array ] <state> ;
M: state-monad fail   "Fail" throw ;

: mcall ( x state -- y ) quot>> call( x -- y ) ;

M: state >>= '[ _ swap '[ _ mcall first2 @ mcall ] <state> ] ;

: get-st ( -- state ) [ dup 2array ] <state> ;
: put-st ( value -- state ) '[ drop _ f 2array ] <state> ;

: run-st ( state initial -- value ) swap mcall second ;

: return-st ( value -- mvalue ) state-monad return ;

! Reader
SINGLETON: reader-monad
INSTANCE:  reader-monad monad

TUPLE: reader quot ;
C: <reader> reader
INSTANCE: reader monad

M: reader monad-of drop reader-monad ;

M: reader-monad return drop '[ drop _ ] <reader> ;
M: reader-monad fail   "Fail" throw ;

M: reader >>= '[ _ swap '[ dup _ mcall @ mcall ] <reader> ] ;

: run-reader ( reader env -- value ) swap quot>> call( env -- value ) ;

: ask ( -- reader ) [ ] <reader> ;
: local ( reader quot -- reader' ) swap '[ @ _ mcall ] <reader> ;

! Writer
SINGLETON: writer-monad
INSTANCE:  writer-monad monad

TUPLE: writer value log ;
C: <writer> writer

M: writer monad-of drop writer-monad ;

M: writer-monad return drop { } <writer> ;
M: writer-monad fail   "Fail" throw ;

: run-writer ( writer -- value log ) [ value>> ] [ log>> ] bi ;

M: writer >>= '[ [ _ run-writer ] dip '[ @ run-writer ] dip prepend <writer> ] ;

: pass ( writer -- writer' ) run-writer [ first2 ] dip swap call( x -- y ) <writer> ;
: listen ( writer -- writer' ) run-writer [ 2array ] keep <writer> ;
: tell ( seq -- writer ) f swap <writer> ;
