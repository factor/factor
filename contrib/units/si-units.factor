USING: math units ;
IN: si-units

! SI Conversions
! http://physics.nist.gov/cuu/Units/

! Y Z E P T G M k h da 1 d c m mu n p f a z y
: yotta>1 1000000000000000000000000 * ;
: zetta>1 1000000000000000000000 * ;
: exa>1   1000000000000000000 * ;
: peta>1  1000000000000000 * ;
: tera>1  1000000000000 * ;
: giga>1  1000000000 * ;
: mega>1  1000000 * ;
: kilo>1  1000 * ;
: hecto>1 100 * ;
: deca>1  10 * ;
: deci>1  10 / ;
: centi>1 100 / ;
: milli>1 1000 / ;
: micro>1 1000000 / ;
: nano>1  1000000000 / ;
: pico>1  1000000000000 / ;
: femto>1 1000000000000000 / ;
: atto>1  1000000000000000000 / ;
: zepto>1 1000000000000000000000 / ;
: yocto>1 1000000000000000000000000 / ;


! Length
SYMBOL: m
: (m) { m } { } <dimensioned> ;
: m (m) ;
: km kilo>1 (m) ;
: cm centi>1 (m) ;
: mm milli>1 (m) ;
: nm nano>1 (m) ;

! Mass
SYMBOL: kg
: (kg) { kg } { } <dimensioned> ;
: kg (kg) ;
: g milli>1 (kg) ;

! Time
SYMBOL: s
: (s) { s } { } <dimensioned> ;
: s (s) ;
: ms milli>1 (s) ;

! Electric current
SYMBOL: A
: (A) { A } { } <dimensioned> ;
: A (A) ;

! Temperature
SYMBOL: K
: (K) { K } { } <dimensioned> ;
: K (K) ;

! Amount of substance
SYMBOL: mol
: (mol) { mol } { } <dimensioned> ;
: mol (mol) ;

! Luminous intensity
SYMBOL: cd
: (cd) { cd } { } <dimensioned> ;
: cd (cd) ;


! SI derived units
: m^2 { m m } { } <dimensioned> ;
: m^3 { m m m } { } <dimensioned> ;
: m/s { m } { s } <dimensioned> ;
: m/s^2 { m } { s s } <dimensioned> ;
: m^-1 { } { m } <dimensioned> ;
: kg/m^3 { kg } { m m m } <dimensioned> ;
: A/m^2 { A } { m m } <dimensioned> ;
: A/m { A } { m } <dimensioned> ;
: mol/m^3 { mol } { m m m } <dimensioned> ;
: cd/m^2 { cd } { m m } <dimensioned> ;
: kg/kg { kg } { kg } <dimensioned> ;

: radian ( n -- radian ) { m } { m } <dimensioned> ;
: sr ( n -- steradian ) { m m } { m m } <dimensioned> ;
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
: Wb ( n - weber ) { m m kg } { s s A } <dimensioned> ;
: T ( n -- tesla ) { kg } { s s A } <dimensioned> ;
: H ( n -- henry ) { m m kg } { s s A A } <dimensioned> ;
: deg-C ( n -- Celsius ) 273.15 + { K } { } <dimensioned> ;
: lm ( n -- lumen ) { m m cd } { m m } <dimensioned> ;
: lx ( n -- lux ) { m m cd } { m m m m  } <dimensioned> ;
: Bq ( n -- becquerel ) { } { s } <dimensioned> ;
: Gy ( n -- gray ) { m m } { s s } <dimensioned> ;
: Sv ( n -- sievert ) { m m } { s s } <dimensioned> ;
: kat ( n -- katal ) { mol } { s } <dimensioned> ;

! Extensions to the SI
: arc-deg pi 180 / * radian ;
: arc-min pi 10800 / * radian ;
: arc-sec pi 648000 / * radian ;
: L ( n -- liter ) 1/1000 * m^3 ;
: tons ( n -- metric-ton ) 1000 * kg ;
: Np ( n -- neper ) { } { } <dimensioned> ;
: B ( n -- bel ) 1.151292546497023 * Np ;
: eV ( n -- electronvolt ) 1.60218e-19 * J ;
: u ( n -- unified-atomic-mass-unit ) 1.66054e-27 * kg ;
: au ( n -- astronomical-unit ) 149598000000 * m ;

: nautical-miles 1852 * m ;
: knots 1852/3600 * m/s ;
: a ( n -- are ) 100 * m^2 ;
: ha ( n -- hectare ) 10000 * m^2 ;
: bar ( n -- bar ) 100000 * Pa ;
: angstrom .1 * nm ;
: b ( n -- barn ) 1/10000000000000000000000000000 * m^2 ;
: Ci ( n -- curie ) 37000000000 * Bq ;
: R 0.000258 { s A } { kg } <dimensioned> ;
: rad .01 * Gy ;
: rem .01 * Sv ;

