! Copyright (C) 2011 rien
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays classes.singleton combinators
combinators.smart continuations effects io io.streams.string
kernel locals make math math.order multiline parser prettyprint
quotations sequences sequences.generalizations stack-checker
unicode.case ;

IN: explain


: ins ( word -- seq ) stack-effect in>> ;
: outs ( word -- seq ) stack-effect out>> ;
: n-in ( word -- n ) ins length ;
: n-out ( word -- n ) outs length ;
: is-literal? ( word -- ? ) dup literalize eq? ; ! thanks to qx
: isuffix! ( seq1 seq2 -- seq ) 1array append ; ! \ suffix! for immutable sequences

! color effect with labels, e.g.
! { "A" "B" "C" } [ + + ] infer label-effect ! => ( A B C -- x )
! [ + + ] infer ! would otherwise return ( x x x -- x )
! if labels length > effect n-in then ignore leftmost labels; if < then error
: label-effect ( labels effect -- effect ) [ in>> length ] [ out>> ] bi [ tail* ] dip <effect> ;
: label-effect' ( labels effect -- spill effect ) [ in>> length ] [ out>> ] bi [ cut* ] dip <effect> ;

! this is shorthand - nothing meaningful is done here
: end-shuffle ( string -- string ) "back from " prepend ;

DEFER: gen-steps

:: (do-the-keep) ( stack -- final-stack steps )
    stack unclip-last :> quot
    unclip-last dup 1array :> retained-top
    isuffix!
    quot inputs :> nobjs4quot ! qty of objects from stack that the quotation will use
    nobjs4quot cut* :> objs4quot :> new-stack
    objs4quot quot infer label-effect :> new-quot-effect
    quot new-quot-effect gen-steps :> dip-steps
    dip-steps last :> last-step
    new-stack last-step retained-top append append :> resulting-stack
    dip-steps resulting-stack
    swap ;

: do-the-keep ( stack -- stack )
    (do-the-keep) , "keep" end-shuffle , ; inline

:: (do-the-dip) ( stack -- final-stack steps )
    stack unclip-last :> quot
    unclip-last 1array :> retained-top
    quot inputs :> nobjs4quot ! qty of objects from stack that the quotation will use
    nobjs4quot cut* :> objs4quot :> new-stack
    objs4quot quot infer label-effect :> new-quot-effect
    quot new-quot-effect gen-steps :> dip-steps
    dip-steps last :> last-step
    new-stack last-step retained-top append append :> resulting-stack
    dip-steps resulting-stack
    swap ;

: do-the-dip ( stack -- stack )
    (do-the-dip) , "dip" end-shuffle , ; inline

: 2array-spill ( seq -- x y ) [ 0 swap nth ] [ 1 swap nth ] bi ;

! this was hard and I bet it's still wrong
:: (do-the-bi) ( stack -- final-stack steps )
    stack 2 cut* 2array-spill     :> ( stack-elts quot1 quot2 )
    stack-elts last               :> x-to-keep
    quot1 inputs quot2 inputs max :> n-elts-used
    stack-elts n-elts-used cut*   :> ( stack-unused! quot1-input )
    quot1 quot1-input quot1 infer label-effect' swapd gen-steps :> ( quot1-unused bi-steps1 )
    stack-unused quot1-unused append stack-unused!              ! update unused stack
    stack-unused bi-steps1 last append x-to-keep isuffix!       :> quot2-input
    quot2 quot2-input quot2 infer label-effect' swapd gen-steps :> ( quot2-unused bi-steps2 )
    quot2-unused stack-unused!                                  ! update here is != from above
    stack-unused bi-steps2 last append   ! calculate final stack
    bi-steps1 bi-steps2 2array ;         ! package both steps

: do-the-bi ( stack -- stack )
    (do-the-bi) , "bi" end-shuffle , ; inline

#! Checks if the quotation's effect is equivalent to the given effect
#! (in arity, disregarding names).
: is-this-your-effect? ( quot effect -- ? ) [ infer ] dip effect= ;

: wrong-effect ( quot effect -- string )
    [ "The quotation:\n" print over . "   " write
      "\nwhose effect is:\n" print swap infer .
      "\ndoes not match the given effect:\n" print . ] with-string-writer ;

: exec-word ( stack word -- stack )
    {
        { [ dup is-literal? ] [ isuffix! ] }
        { [ dup singleton-class? ] [ isuffix! ] }
        ! first, words that are too simple to have gen-steps show its steps
        { [ dup
            ! these are *really* exec'ed
            { -rot 2drop 2dup 2nip 3drop 3dup drop dup dupd nip over pick rot swap swapd }
              member? ] [ 1quotation with-datastack ] }
        [
            dup { ! -- stack word (\ case eats the \ dup)
                  ! now, all the words that gen-steps gens, in case showing steps is turned off (TODO)
                  { \ bi   [ drop (do-the-bi)   drop ] }
                  { \ dip  [ drop (do-the-dip)  drop ] }
                  { \ keep [ drop (do-the-keep) drop ] }
                  ! { \ + [ drop 2 cut* sum isuffix! ] }                  
                  ! -- stack word word
                  [ -rot n-in head* swap outs append ]
            } case
        ]
    } cond ; inline


: gen-steps ( quot effect -- seq )
    [let dup in>> :> stack! ! stack starts with effect's in-labels
        2dup is-this-your-effect? [ drop ] [ wrong-effect throw ] if ! -- quot
        [
            stack , ! push current stack as the first step
            [
                ! -- quot-elt : for each elt:
                ! 1. push it as a step
                dup ,
                ! 2. push its resulting stack as a step
                stack swap {
                    ! these are words that need to be treated specially
                    ! each case has this effect: ( quot-elt -- final-stack )
                    { \ bi   [ do-the-bi   ] }
                    { \ dip  [ do-the-dip  ] }
                    { \ keep [ do-the-keep ] }
                    [ exec-word ] ! stack quot-elt -- final-stack
                } case
                dup stack! , ! push final-stack, stack = final-stack
            ] each
        ] { } make
    ] ;


: quick-gen-steps ( quot -- seq ) dup infer gen-steps ;

: print-examples ( -- )
    "\n[ 4 5 10 [ 2 / ] [ 2 * ] bi * ] steps:" print
    [ 4 5 10 [ 2 / ] [ 2 * ] bi * ] ( -- x x x ) gen-steps .
    "\n[ 8 3 2 [ dup 19 + ] dip + + ] steps:" print
    [ 8 3 2 [ dup 19 + ] dip + + ] ( -- x x ) gen-steps .
    "\n[ 1 2 3 [ + ] keep 3array sum ] steps:" print
    [ 1 2 3 [ + ] keep 3array sum ] ( -- x ) gen-steps . ;

MAIN: print-examples
