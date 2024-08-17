USING: accessors kernel math.functions math.statistics
math.statistics.running random sequences tools.test ;

{
    { t t t t t t t t t }
    { t t t t t t t t t }
    { t t t t t t t t t }
} [| |
    100 random-units :> r1
    100 random-units :> r2
    r1 r2 append :> r3

    <running-stats> r1 push-value :> stats1

    stats1 {
        [ n>> 100 = ]
        [ min>> r1 minimum = ]
        [ max>> r1 maximum = ]
        [ sum>> r1 sum 1e-10 ~ ]
        [ math.statistics.running:mean r1 math.statistics:mean 1e-10 ~ ]
        [ variance r1 population-var 1e-10 ~ ]
        [ sample-variance r1 sample-var 1e-10 ~ ]
        [ stddev r1 population-std 1e-10 ~ ]
        [ sample-stddev r1 sample-std 1e-10 ~ ]
    } cleave>array

    <running-stats> r2 push-value :> stats2

    stats2 {
        [ n>> 100 = ]
        [ min>> r2 minimum = ]
        [ max>> r2 maximum = ]
        [ sum>> r2 sum 1e-10 ~ ]
        [ math.statistics.running:mean r2 math.statistics:mean 1e-10 ~ ]
        [ variance r2 population-var 1e-10 ~ ]
        [ sample-variance r2 sample-var 1e-10 ~ ]
        [ stddev r2 population-std 1e-10 ~ ]
        [ sample-stddev r2 sample-std 1e-10 ~ ]
    } cleave>array

    stats1 stats2 combine-stats :> stats3

    stats3 {
        [ n>> 200 = ]
        [ min>> r3 minimum = ]
        [ max>> r3 maximum = ]
        [ sum>> r3 sum 1e-10 ~ ]
        [ math.statistics.running:mean r3 math.statistics:mean 1e-10 ~ ]
        [ variance r3 population-var 1e-10 ~ ]
        [ sample-variance r3 sample-var 1e-10 ~ ]
        [ stddev r3 population-std 1e-10 ~ ]
        [ sample-stddev r3 sample-std 1e-10 ~ ]
    } cleave>array
] unit-test

{ { t t } { t t } { t t } } [| |
    100 random-units 100 random-units :> ( x1 y1 )
    100 random-units 100 random-units :> ( x2 y2 )
    x1 x2 append y1 y2 append :> ( x3 y3 )

    <running-regress> x1 y1 push-values :> regress1

    regress1 {
        [ n>> 100 = ]
        [ correlation x1 y1 population-corr 1e-10 ~ ]
    } cleave>array

    <running-regress> x2 y2 push-values :> regress2

    regress2 {
        [ n>> 100 = ]
        [ correlation x2 y2 population-corr 1e-10 ~ ]
    } cleave>array

    regress1 regress2 combine-regress :> regress3

    regress3 {
        [ n>> 200 = ]
        [ correlation x3 y3 population-corr 1e-10 ~ ]
    } cleave>array
] unit-test
