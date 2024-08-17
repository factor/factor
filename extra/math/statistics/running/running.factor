USING: accessors combinators kernel math math.functions
math.order sequences ;

IN: math.statistics.running

TUPLE: running-stats n min max sum mom1 mom2 mom3 mom4 ;

: <running-stats> ( -- running-stats )
    0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 running-stats boa ;

GENERIC: push-value ( stats x -- stats )

M: sequence push-value
    [ push-value ] each ;

M:: object push-value ( stats x -- stats )
    stats
    dup n>> zero? [
        x >>min
        x >>max
    ] [
        [ x min ] change-min
        [ x max ] change-max
    ] if

    [ 1 + dup ] change-n swap :> n
    ! See Knuth TAOCP vol 2, 3rd edition, page 232
    [ x + ] change-sum
    x over mom1>> - :> delta
    delta n /f :> delta_n
    delta_n sq :> delta_n2
    delta delta_n * n 1 - * :> term1
    [
        term1 delta_n2 * n sq 3 n * - 3 + *
        6 delta_n2 * stats mom2>> * +
        4 delta_n * stats mom3>> * - +
    ] change-mom4
    [
        term1 delta_n * n 2 - *
        3 delta_n * stats mom2>> * - +
    ] change-mom3
    [ term1 + ] change-mom2
    [ delta_n + ] change-mom1 ;

: mean ( stats -- n )
    mom1>> ;

: variance ( stats -- n )
    [ mom2>> ] [ n>> ] bi / ;

: sample-variance ( stats -- n )
    [ mom2>> ] [ n>> 1 - ] bi / ;

: stddev ( stats -- n )
    variance sqrt ;

: sample-stddev ( stats -- n )
    sample-variance sqrt ;

: skewness ( stats -- n )
    [ n>> sqrt ] [ mom3>> * ] [ mom2>> 1.5 ^ / ] tri ;

:: sample-skewness ( stats -- n )
    stats n>> :> n
    n dup 1 - * sqrt stats skewness * n 2 - / ;

: kurtosis ( stats -- n )
    [ n>> ] [ mom4>> * ] [ mom2>> sq / ] tri 3 - ;

:: sample-kurtosis ( stats -- n )
    stats n>> :> n
    n 1 - n 2 - n 3 - * /
    n 1 + stats kurtosis * 6 + * ;

:: combine-stats ( stats1 stats2 -- stats3 )
    stats1 n>> :> n1
    stats2 n>> :> n2

    n1 n2 + dup :> n
    stats1 stats2 [ min>> ] bi@ min
    stats1 stats2 [ max>> ] bi@ max
    stats1 stats2 [ sum>> ] bi@ +

    stats1 stats2 [ mom1>> ] bi@ - :> delta
    delta sq :> delta2
    delta delta2 * :> delta3
    delta2 delta2 * :> delta4

    n1 stats1 mom1>> * n1 stats2 mom1>> * + n /

    stats1 stats2 [ mom2>> ] bi@ + delta2 n1 * n2 * n / +

    stats1 stats2 [ mom3>> ] bi@ +
    delta3 n1 * n2 * n1 n2 - * n sq / +
    delta 3 * n1 stats2 mom2>> * n2 stats1 mom2>> * - * n / +

    stats1 stats2 [ mom4>> ] bi@ +
    delta4 n1 * n2 * n1 sq n1 n2 * - n2 sq + * n 3 ^ / +
    delta2 6 * n1 sq stats2 mom2>> * n2 sq stats1 mom2>> * + * n sq / +
    delta 4 * n1 stats2 mom3>> * n2 stats1 mom3>> * - * n / +

    running-stats boa ;

TUPLE: running-regress n x-stats y-stats xy ;

: <running-regress> ( -- regress )
    0 <running-stats> <running-stats> 0.0 running-regress boa ;

<PRIVATE

:: (push-values) ( regress x y -- regress )
    regress n>> :> n

    regress x-stats>> mean x -
    regress y-stats>> mean y - *
    n * n 1 + / regress [ + ] change-xy

    [ x-stats>> x push-value drop ]
    [ y-stats>> y push-value drop ]
    [ [ 1 + ] change-n ] tri ;

PRIVATE>

:: push-values ( regress x y -- regress )
    regress {
        { [ x y [ sequence? ] both? ] [ x y [ (push-values) ] 2each ] }
        { [ x sequence? ] [ x [ y (push-values) ] each ] }
        { [ y sequence? ] [ x y [ (push-values) ] with each ] }
        [ x y (push-values) ]
    } cond ;

: slope ( regress -- n )
    [ xy>> ] [ x-stats>> sample-variance ] [ n>> 1 - * / ] tri ;

: intercept ( regress -- n )
    [ y-stats>> mean ] [ slope ] [ x-stats>> mean * - ] tri ;

: correlation ( regress -- n )
    {
        [ xy>> ]
        [ x-stats>> stddev ]
        [ y-stats>> stddev * ]
        [ n>> * / ]
    } cleave ;

:: combine-regress ( regress1 regress2 -- regress3 )
    regress1 regress2 [ n>> ] bi@ + dup :> n
    regress1 regress2 [ x-stats>> ] bi@ combine-stats
    regress1 regress2 [ y-stats>> ] bi@ combine-stats
    regress2 regress1 [ x-stats>> mean ] bi@ - :> delta-x
    regress2 regress1 [ y-stats>> mean ] bi@ - :> delta-y
    regress1 regress2 [ xy>> ] bi@ +
    regress1 regress2 [ n>> ] bi@ * delta-x * delta-y * n / +
    running-regress boa ;
