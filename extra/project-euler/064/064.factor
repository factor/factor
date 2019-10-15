USING: accessors arrays classes.tuple io kernel locals math math.functions
    math.ranges prettyprint project-euler.common sequences ;
IN: project-euler.064

<PRIVATE

TUPLE: cont-frac
    { whole integer }
    { num-const integer }
    { denom integer } ;

C: <cont-frac> cont-frac

: deep-copy ( cont-frac -- cont-frac cont-frac )
    dup tuple>array rest cont-frac slots>tuple ;

: create-cont-frac ( n -- n cont-frac )
    dup sqrt >fixnum
    [let :> root
        root
        root
        1
    ] <cont-frac> ;

: step ( n cont-frac -- n cont-frac )
    swap dup
    ! Store n
    [let :> n
        ! Extract the constant
        swap dup num-const>>
        :> num-const

        ! Find the new denominator
        num-const 2 ^ n swap -
        :> exp-denom

        ! Find the fraction in lowest terms
        dup denom>>
        exp-denom simple-gcd
        exp-denom swap /
        :> new-denom

        ! Find the new whole number
        num-const n sqrt + new-denom / >fixnum
        :> new-whole

        ! Find the new num-const
        num-const new-denom /
        new-whole swap -
        new-denom *
        :> new-num-const

        ! Finally, update the continuing fraction
        drop new-whole new-num-const new-denom <cont-frac>
    ] ;

: loop ( c l n cont-frac -- c l n cont-frac )
    [let :> cf :> n :> l :> c
        n cf step
        :> new-cf drop
        c 1 + l n new-cf
        l new-cf = [ ] [ loop ] if
    ] ;

: find-period ( n -- period )
    0 swap
    create-cont-frac
    step
    deep-copy -rot
    loop
    drop drop drop ;

: try-all ( -- n ) 2 10000 [a,b]
    [ perfect-square? not ] filter
    [ find-period ] map
    [ odd? ] filter
    length ;

PRIVATE>

: euler064a ( -- n ) try-all ;

<PRIVATE
! (√n + a)/b
TUPLE: cfrac n a b ;

C: <cfrac> cfrac

! (√n + a) / b = 1 / (k + (√n + a') / b')
!
! b / (√n + a) = b (√n - a) / (n - a^2) = (√n - a) / ((n - a^2) / b)
:: reciprocal ( fr -- fr' )
    fr n>>
    fr a>> neg
    fr n>> fr a>> sq - fr b>> /
    <cfrac>
    ;

:: split ( fr -- k fr' )
    fr n>> sqrt fr a>> + fr b>> / >integer
    dup fr n>> swap
    fr b>> * fr a>> swap -
    fr b>>
    <cfrac>
    ;

: pure ( n -- fr )
    0 1 <cfrac>
    ;

: next ( fr -- fr' )
    reciprocal split nip
    ;

:: period ( n -- per )
    n pure split nip :> start
    n sqrt >integer sq n =
    [ 0 ]
    [ 1 start next
      [ dup start = not ]
      [ next [ 1 + ] dip ]
      while
      drop
    ] if
    ;

PRIVATE>

: euler064b ( -- ct )
    1 10000 [a,b]
    [ period odd? ] count
    ;
