USING: kernel math prettyprint units units.si inverse ;
IN: units.imperial

: inches ( n -- dimensioned ) 254/100 * cm ;

: feet ( n -- dimensioned ) 12 * inches ;

: yards ( n -- dimensioned ) 3 * feet ;

: miles ( n -- dimensioned ) 1760 * yards ;

: nautical-miles ( n -- dimensioned ) 1852 * m ;

: pounds ( n -- dimensioned ) 22/10 / kg ;

: ounces ( n -- dimensioned ) 1/16 * pounds ;

: gallons ( n -- dimensioned ) 379/100 * L ;

: quarts ( n -- dimensioned ) 1/4 * gallons ;

: pints ( n -- dimensioned ) 1/2 * quarts ;

: cups ( n -- dimensioned ) 1/2 * pints ;

: fluid-ounces ( n -- dimensioned ) 1/16 * pints ;

: teaspoons ( n -- dimensioned ) 1/6 * fluid-ounces ;

: tablespoons ( n -- dimensioned ) 1/2 * fluid-ounces ;

: knots ( n -- dimensioned ) 1852/3600 * m/s ;

: deg-F ( n -- dimensioned ) 32 - 5/9 * deg-C ;

: imperial-gallons ( n -- dimensioned ) 454609/100000 * L ;

: imperial-quarts ( n -- dimensioned ) 1/4 * imperial-gallons ;

: imperial-pints ( n -- dimensioned ) 1/2 * imperial-quarts ;

: imperial-fluid-ounces ( n -- dimensioned ) 1/160 * imperial-gallons ;

: imperial-gill ( n -- dimensioned ) 5 * imperial-fluid-ounces ;

: dry-gallons ( n -- dimensioned ) 440488377086/100000000000 * L ; 

: dry-quarts ( n -- dimensioned ) 1/4 * dry-gallons ;

: dry-pints ( n -- dimensioned ) 1/2 * dry-quarts ;

: pecks ( n -- dimensioned ) 8 * dry-quarts ;

: bushels ( n -- dimensioned ) 4 * pecks ;

: rods ( n -- dimensioned ) 11/2 * yards ;






! rod, hogshead, barrel, peck, metric ton, imperial ton..
