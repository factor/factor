USING: kernel math prettyprint units units.si inverse ;
IN: units.imperial

: inches ( n -- dimensioned ) 254/100 * cm ;

: feet ( n -- dimensioned ) 12 * inches ;

: yards ( n -- dimensioned ) 3 * feet ;

: miles ( n -- dimensioned ) 1760 * yards ;

: pounds ( n -- dimensioned ) 22/10 / kg ;

: ounces ( n -- dimensioned ) 1/16 * pounds ;

: gallons ( n -- dimensioned ) 379/100 * L ;

: quarts ( n -- dimensioned ) 1/4 * gallons ;

: pints ( n -- dimensioned ) 1/2 * quarts ;

: cups ( n -- dimensioned ) 1/2 * pints ;

: fluid-ounces ( n -- dimensioned ) 1/16 * pints ;

: teaspoons ( n -- dimensioned ) 1/6 * fluid-ounces ;

: tablespoons ( n -- dimensioned ) 1/2 * fluid-ounces ;

: nautical-miles ( n -- dimensioned ) 1852 * m ;

: knots ( n -- dimensioned ) 1852/3600 * m/s ;

: deg-F ( n -- dimensioned ) 32 - 5/9 * deg-C ;

! rod, hogshead, barrel, peck, metric ton, imperial ton..
