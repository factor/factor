! Copyright (c) 2008 Reginald Keith Ford II, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel continuations combinators sequences math math.order math.ranges
    accessors float-arrays ;
IN: math.derivatives

TUPLE: state x func h err i j errt fac hh ans a done ;

: largest-float ( -- x ) 0x7fefffffffffffff bits>double ; foldable
: ntab ( -- val ) 8 ; inline
: con ( -- val ) 1.6 ; inline
: con2 ( -- val ) con con * ; inline
: big ( -- val ) largest-float ; inline
: safe ( -- val ) 2.0 ; inline

! Yes, this was ported from C code.
: a[i][i]     ( state -- elt ) [ i>>     ] [ i>>     ] [ a>> ] tri nth nth ;
: a[j][i]     ( state -- elt ) [ i>>     ] [ j>>     ] [ a>> ] tri nth nth ;
: a[j-1][i]   ( state -- elt ) [ i>>     ] [ j>> 1 - ] [ a>> ] tri nth nth ;
: a[j-1][i-1] ( state -- elt ) [ i>> 1 - ] [ j>> 1 - ] [ a>> ] tri nth nth ;
: a[i-1][i-1] ( state -- elt ) [ i>> 1 - ] [ i>> 1 - ] [ a>> ] tri nth nth ;

: check-h ( state -- state )
    dup h>> 0 = [ "h must be nonzero in dfridr" throw ] when ;

: init-a     ( state -- state ) ntab [ ntab <float-array> ] replicate >>a ;
: init-hh    ( state -- state ) dup h>> >>hh ;
: init-err   ( state -- state ) big >>err ;
: update-hh  ( state -- state ) dup hh>> con / >>hh ;
: reset-fac  ( state -- state ) con2 >>fac ;
: update-fac ( state -- state ) dup fac>> con2 * >>fac ;

! If error is decreased, save the improved answer
: error-decreased? ( state -- state ? ) [ ] [ errt>> ] [ err>> ] tri <= ;

: save-improved-answer ( state -- state )
    dup err>>   >>errt
    dup a[j][i] >>ans ;

! If higher order is worse by a significant factor SAFE, then quit early.
: check-safe ( state -- state )
    dup [ [ a[i][i] ] [ a[i-1][i-1] ] bi - abs ]
    [ err>> safe * ] bi >= [ t >>done ] when ;

: x+hh ( state -- val ) [ x>> ] [ hh>> ] bi + ;
: x-hh ( state -- val ) [ x>> ] [ hh>> ] bi - ;

: limit-approx ( state -- val )
    [
        [ [ x+hh ] [ func>> ] bi call ]
        [ [ x-hh ] [ func>> ] bi call ] bi -
    ] [ hh>> 2.0 * ] bi / ;

: a[0][0]! ( state -- state )
    { [ ] [ limit-approx ] [ drop 0 ] [ drop 0 ] [ a>> ] } cleave nth set-nth ;

: a[0][i]! ( state -- state )
    { [ ] [ limit-approx ] [ i>> ] [ drop 0 ] [ a>> ] } cleave nth set-nth ;

: a[j-1][i]*fac ( state -- val ) [ a[j-1][i] ] [ fac>> ] bi * ;

: new-a[j][i] ( state -- val )
    [ [ a[j-1][i]*fac ] [ a[j-1][i-1] ] bi - ]
    [ fac>> 1.0 - ] bi / ;

: a[j][i]! ( state -- state )
    { [ ] [ new-a[j][i] ] [ i>> ] [ j>> ] [ a>> ] } cleave nth set-nth ;

: update-errt ( state -- state )
    dup [ [ a[j][i] ] [ a[j-1][i] ] bi - abs ]
    [ [ a[j][i] ] [ a[j-1][i-1] ] bi - abs ] bi max >>errt ;

: not-done? ( state -- state ? ) dup done>> not ;

: derive ( state -- state )
    init-a
    check-h
    init-hh
    a[0][0]!
    init-err
    1 ntab [a,b) [
        >>i not-done? [
            update-hh
            a[0][i]!
            reset-fac
            1 over i>> [a,b] [
                >>j
                a[j][i]!
                update-fac
                update-errt
                error-decreased? [ save-improved-answer ] when
            ] each check-safe
        ] when
   ] each ;

: derivative-state ( x func h err -- state )
    state new
    swap >>err
    swap >>h
    swap >>func
    swap >>x ;

! For scientists:
! h should be .001 to .5 -- too small can cause bad convergence,
! h should be small enough to give the correct sgn(f'(x))
! err is the max tolerance of gain in error for a single iteration-
: (derivative) ( x func h err -- ans error )
    derivative-state derive [ ans>> ] [ errt>> ] bi ;

: derivative ( x func -- m ) 0.01 2.0 (derivative) drop ;
: derivative-func ( func -- der ) [ derivative ] curry ;
