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
: m^2 ( n -- dimensioned ) { m m } { } <dimensioned> ;
: m^3 ( n -- dimensioned ) { m m m } { } <dimensioned> ;
: m/s ( n -- dimensioned ) { m } { s } <dimensioned> ;
: m/s^2 ( n -- dimensioned ) { m } { s s } <dimensioned> ;
: 1/m ( n -- dimensioned ) { } { m } <dimensioned> ;
: kg/m^3 ( n -- dimensioned ) { kg } { m m m } <dimensioned> ;
: A/m^2 ( n -- dimensioned ) { A } { m m } <dimensioned> ;
: A/m ( n -- dimensioned ) { A } { m } <dimensioned> ;
: mol/m^3 ( n -- dimensioned ) { mol } { m m m } <dimensioned> ;
: cd/m^2 ( n -- dimensioned ) { cd } { m m } <dimensioned> ;
: kg/kg ( n -- dimensioned ) { kg } { kg } <dimensioned> ;

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
ALIAS: Ω ohm
: S ( n -- siemens ) { s s s A A } { m m kg } <dimensioned> ;
: Wb ( n -- weber ) { m m kg } { s s A } <dimensioned> ;
: T ( n -- tesla ) { kg } { s s A } <dimensioned> ;
: H ( n -- henry ) { m m kg } { s s A A } <dimensioned> ;
: deg-C ( n -- Celsius ) 27315/100 + { K } { } <dimensioned> ;
ALIAS: °C deg-C
: lm ( n -- lumen ) { m m cd } { m m } <dimensioned> ;
: lx ( n -- lux ) { m m cd } { m m m m } <dimensioned> ;
: Bq ( n -- becquerel ) { } { s } <dimensioned> ;
: Gy ( n -- gray ) { m m } { s s } <dimensioned> ;
: Sv ( n -- sievert ) { m m } { s s } <dimensioned> ;
: kat ( n -- katal ) { mol } { s } <dimensioned> ;

! Extensions to the SI
: arc-deg ( n -- x ) pi 180 / * radians ;
: arc-min ( n -- x ) pi 10800 / * radians ;
: arc-sec ( n -- x ) pi 648000 / * radians ;
: L ( n -- liter ) 1/1000 * m^3 ;
ALIAS: l L
: tons ( n -- metric-ton ) 1000 * kg ;
: Np ( n -- neper ) { } { } <dimensioned> ;
: B ( n -- bel ) 1.151292546497023 * Np ;
: eV ( n -- electronvolt ) 1.60218e-19 * J ;
: u ( n -- unified-atomic-mass-unit ) 1.660539040e-27 * kg ;

! au has error of 30m, according to wikipedia
: au ( n -- astronomical-unit ) 149597870691 * m ;

: a ( n -- are ) 100 * m^2 ;
: ha ( n -- hectare ) 10000 * m^2 ;
: km^2 ( n -- dimensioned ) 1000000 * m^2 ;
: bar ( n -- bar ) 100000 * Pa ;
: b ( n -- barn ) 1/10000000000000000000000000000 * m^2 ;
: Ci ( n -- curie ) 37000000000 * Bq ;
: R ( -- dimensioned ) 258/10000 { s A } { kg } <dimensioned> ;
: rad ( n -- dimensioned ) 100 / Gy ;

! roentgen equivalent man, equal to one roentgen of X-rays
: roentgen-equivalent-man ( n -- dimensioned ) 100 / Sv ;

! inaccurate, use calendar where possible
: minutes ( n -- dimensioned ) 60 * s ;
: hours ( n -- dimensioned ) 60 * minutes ;
: days ( n -- dimensioned ) 24 * hours ;

! Q R Y Z E P T G M k h da 1 d c m mu n p f a z y r q
: quetta ( n -- x ) 1000000000000000000000000000000 * ;
: ronna  ( n -- x ) 1000000000000000000000000000 * ;
: yotta  ( n -- x ) 1000000000000000000000000 * ;
: zetta  ( n -- x ) 1000000000000000000000 * ;
: exa    ( n -- x ) 1000000000000000000 * ;
: peta   ( n -- x ) 1000000000000000 * ;
: tera   ( n -- x ) 1000000000000 * ;
: giga   ( n -- x ) 1000000000 * ;
: mega   ( n -- x ) 1000000 * ;
: kilo   ( n -- x ) 1000 * ;
: hecto  ( n -- x ) 100 * ;
: deca   ( n -- x ) 10 * ;
: deci   ( n -- x ) 10 / ;
: centi  ( n -- x ) 100 / ;
: milli  ( n -- x ) 1000 / ;
: micro  ( n -- x ) 1000000 / ;
: nano   ( n -- x ) 1000000000 / ;
: pico   ( n -- x ) 1000000000000 / ;
: femto  ( n -- x ) 1000000000000000 / ;
: atto   ( n -- x ) 1000000000000000000 / ;
: zepto  ( n -- x ) 1000000000000000000000 / ;
: yocto  ( n -- x ) 1000000000000000000000000 / ;
: ronto  ( n -- x ) 1000000000000000000000000000 / ;
: quecto ( n -- x ) 1000000000000000000000000000000 / ;

! Yi Zi Ei Pi Ti Gi Mi Ki
: yobi ( n -- x ) 1208925819614629174706176 * ;
: zebi ( n -- x ) 1180591620717411303424 * ;
: exbi ( n -- x ) 1152921504606846976 * ;
: pebi ( n -- x ) 1125899906842624 * ;
: tebi ( n -- x ) 1099511627776 * ;
: gibi ( n -- x ) 1073741824 * ;
: mebi ( n -- x ) 1048576 * ;
: kibi ( n -- x ) 1024 * ;

ALIAS: Yi yobi
ALIAS: Zi zebi
ALIAS: Ei exbi
ALIAS: Pi pebi
ALIAS: Ti tebi
ALIAS: Gi gibi
ALIAS: Mi mebi
ALIAS: Ki kibi

: km ( n -- dimensioned ) kilo m ;
: cm ( n -- dimensioned ) centi m ;
: mm ( n -- dimensioned ) milli m ;
: nm ( n -- dimensioned ) nano m ;
: g ( n -- dimensioned ) milli kg ;
: ms ( n -- dimensioned ) milli s ;
: angstrom ( n -- dimensioned ) 10 / nm ;
ALIAS: Å angstrom
