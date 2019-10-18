USING: kernel math math.constants sequences units ;
IN: units.si

! SI Conversions
! http://physics.nist.gov/cuu/Units/

! Length
: m ( n -- dimensioned ) { m } { } <dimensioned> ;

! Mass
: kg ( n -- dimensioned ) { kg } { } <dimensioned> ;

! Time
: s ( n -- dimensioned ) { s } { } <dimensioned> ;

! Electric current
: A ( n -- dimensioned ) { A } { } <dimensioned> ;

! Temperature
: K ( n -- dimensioned ) { K } { } <dimensioned> ;

! Amount of substance
: mol ( n -- dimensioned ) { mol } { } <dimensioned> ;

! Luminous intensity
: cd ( n -- dimensioned ) { cd } { } <dimensioned> ;

! SI derived units
: m^2 { m m } { } <dimensioned> ;
: m^3 { m m m } { } <dimensioned> ;
: m/s { m } { s } <dimensioned> ;
: m/s^2 { m } { s s } <dimensioned> ;
: 1/m { } { m } <dimensioned> ;
: kg/m^3 { kg } { m m m } <dimensioned> ;
: A/m^2 { A } { m m } <dimensioned> ;
: A/m { A } { m } <dimensioned> ;
: mol/m^3 { mol } { m m m } <dimensioned> ;
: cd/m^2 { cd } { m m } <dimensioned> ;
: kg/kg { kg } { kg } <dimensioned> ;

! Radians are really m/m, and steradians are m^2/m^2
! but they need to be in reduced form here.
: radians ( n -- radian ) scalar ;
: sr ( n -- steradian ) scalar ;

: Hz ( n -- hertz ) { } { s } <dimensioned> ;
: N ( n -- newton ) { kg m } { s s } <dimensioned> ;
: Pa ( n -- pascal ) { kg } { m s s } <dimensioned> ;
: J ( n -- joule ) { m m kg } { s s } <dimensioned> ;
: W ( n -- watt ) { m m kg } { s s s } <dimensioned> ;
: C ( n -- coulomb ) { s A } { } <dimensioned> ;
: V ( n -- volt ) { m m kg } { s s s A } <dimensioned> ;
: F ( n -- farad ) { s s s s A A } { m m kg } <dimensioned> ;
: ohm ( n -- ohm ) { m m kg } { s s s A A } <dimensioned> ;
: S ( n -- siemens ) { s s s A A } { m m kg } <dimensioned> ;
: Wb ( n -- weber ) { m m kg } { s s A } <dimensioned> ;
: T ( n -- tesla ) { kg } { s s A } <dimensioned> ;
: H ( n -- henry ) { m m kg } { s s A A } <dimensioned> ;
: deg-C ( n -- Celsius ) 27315/100 + { K } { } <dimensioned> ;
: lm ( n -- lumen ) { m m cd } { m m } <dimensioned> ;
: lx ( n -- lux ) { m m cd } { m m m m  } <dimensioned> ;
: Bq ( n -- becquerel ) { } { s } <dimensioned> ;
: Gy ( n -- gray ) { m m } { s s } <dimensioned> ;
: Sv ( n -- sievert ) { m m } { s s } <dimensioned> ;
: kat ( n -- katal ) { mol } { s } <dimensioned> ;

! Extensions to the SI
: arc-deg pi 180 / * radians ;
: arc-min pi 10800 / * radians ;
: arc-sec pi 648000 / * radians ;
: L ( n -- liter ) 1/1000 * m^3 ;
: tons ( n -- metric-ton ) 1000 * kg ;
: Np ( n -- neper ) { } { } <dimensioned> ;
: B ( n -- bel ) 1.151292546497023 * Np ;
: eV ( n -- electronvolt ) 1.60218e-19 * J ;
: u ( n -- unified-atomic-mass-unit ) 1.66054e-27 * kg ;

! au has error of 30m, according to wikipedia
: au ( n -- astronomical-unit ) 149597870691 * m ;

: a ( n -- are ) 100 * m^2 ;
: ha ( n -- hectare ) 10000 * m^2 ;
: bar ( n -- bar ) 100000 * Pa ;
: b ( n -- barn ) 1/10000000000000000000000000000 * m^2 ;
: Ci ( n -- curie ) 37000000000 * Bq ;
: R 258/10000 { s A } { kg } <dimensioned> ;
: rad 100 / Gy ;

! roentgen equivalent man, equal to one roentgen of X-rays
: roentgen-equivalent-man 100 / Sv ;

! inaccurate, use calendar where possible
: minutes 60 * s ;
: hours 60 * minutes ;
: days 24 * hours ;

! Y Z E P T G M k h da 1 d c m mu n p f a z y
: yotta 1000000000000000000000000 * ;
: zetta 1000000000000000000000 * ;
: exa   1000000000000000000 * ;
: peta  1000000000000000 * ;
: tera  1000000000000 * ;
: giga  1000000000 * ;
: mega  1000000 * ;
: kilo  1000 * ;
: hecto 100 * ;
: deca  10 * ;
: deci  10 / ;
: centi 100 / ;
: milli 1000 / ;
: micro 1000000 / ;
: nano  1000000000 / ;
: pico  1000000000000 / ;
: femto 1000000000000000 / ;
: atto  1000000000000000000 / ;
: zepto 1000000000000000000000 / ;
: yocto 1000000000000000000000000 / ;

: km kilo m ;
: cm centi m ;
: mm milli m ;
: nm nano m ;
: g milli kg ;
: ms milli s ;
: angstrom 10 / nm ;
