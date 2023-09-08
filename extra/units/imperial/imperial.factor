USING: math units units.si ;
IN: units.imperial

! TEMPERATURE

: deg-F ( n -- Fahrenheit ) 32 - 5/9 * deg-C ;
ALIAS: °F deg-F

! LENGTH

: inches ( n -- dimensioned ) 254/100 * cm ;

: thous ( n -- dimensioned ) 1/1000 * inches ;

: feet ( n -- dimensioned ) 12 * inches ;

: yards ( n -- dimensioned ) 3 * feet ;

: miles ( n -- dimensioned ) 1760 * yards ;

: furlongs ( n -- dimensioned ) 1/8 * miles ;

: chains ( n -- dimensioned ) 1/10 * furlongs ;

: leagues ( n -- dimensioned ) 3 * miles ;

: links ( n -- dimensioned ) 1/100 * chains ;

: rods ( n -- dimensioned ) 5+1/2 * yards ;
ALIAS: poles rods
ALIAS: perches rods

: barleycorns ( n -- dimensioned ) 1/3 * inches ;

: poppyseeds ( n -- dimensioned ) 1/4 * barleycorns ;

: lines ( n -- dimensioned ) 1/4 * barleycorns ;

: digits ( n -- dimensioned ) 3/4 * inches ;

: hands ( n -- dimensioned ) 4 * inches ;

: palms ( n -- dimensioned ) 3 * inches ;

: shaftments ( n -- dimensioned ) 6 * inches ;

: nails ( n -- dimensioned ) 1/16 * yards ;

: spans ( n -- dimensioned ) 3 * palms ;

: fingers ( n -- dimensioned ) 7/8 * inches ;

: cubits ( n -- dimensioned ) 18 * inches ;

: ells ( n -- dimensioned ) 1+1/4 * yards ;

: ramsdens-chains ( n -- dimensioned ) 100 * feet ;

: nautical-miles ( n -- dimensioned ) 1852 * m ;

: fathoms ( n -- dimensioned ) 6 * feet ;

: shackles ( n -- dimensioned ) 15 * fathoms ;

: cables ( n -- dimensioned ) 608 * feet ;

! AREA

: square-rods ( n -- dimensioned ) 25+1830329/6250000 * m^2 ;
ALIAS: square-poles square-rods
ALIAS: square-perches square-rods

: roods ( n -- dimensioned ) 40 * perches ;

: acres ( n -- dimensioned ) 4 * roods ;

: square-miles ( n -- dimensioned ) 640 * acres ;

! VOLUME

DEFER: imperial-fluid-ounces

: minims ( n -- dimensioned ) 1/480 * imperial-fluid-ounces ;

: apothecary-fluid-scruples ( n -- dimensioned ) 20 * minims ;

: apothecary-fluid-drachms ( n -- dimensioned ) 3 * apothecary-fluid-scruples ;

: apothecary-fluid-ounces ( n -- dimensioned ) 8 * apothecary-fluid-drachms ;

: apothecary-pints ( n -- dimensioned ) 20 * apothecary-fluid-ounces ;

: apothecary-gallons ( n -- dimensioned ) 8 * apothecary-pints ;

! MASS

: pounds ( n -- dimensioned ) 22/10 / kg ;

: drachm ( n -- dimensioned ) 1/256 * pounds ;

: grains ( n -- dimensioned ) 1/7000 * pounds ;

: ounces ( n -- dimensioned ) 1/16 * pounds ;

: nailweights ( n -- dimensioned ) 7 * pounds ;

: stones ( n -- dimensioned ) 14 * pounds ;

: tods ( n -- dimensioned ) 2 * stones ;

: hundredweights ( n -- dimensioned ) 112 * pounds ;

: quarters ( n -- dimensioned ) 1/4 * hundredweights ;

: tons ( n -- dimensioned ) 20 * hundredweights ;



: gallons ( n -- dimensioned ) 379/100 * L ;

: quarts ( n -- dimensioned ) 1/4 * gallons ;

: pints ( n -- dimensioned ) 1/2 * quarts ;

: cups ( n -- dimensioned ) 1/2 * pints ;

: us-fluid-ounces ( n -- dimensioned ) 1/16 * pints ;

: drams ( n -- dimensioned ) 1/8 * us-fluid-ounces ;

: teaspoons ( n -- dimensioned ) 1/6 * us-fluid-ounces ;

: tablespoons ( n -- dimensioned ) 1/2 * us-fluid-ounces ;

: ponies ( n -- dimensioned ) 3/4 * us-fluid-ounces ;

: jiggers ( n -- dimensioned ) 1+1/2 * us-fluid-ounces ;

: us-gill ( n -- dimensioned ) 4 * us-fluid-ounces ;

: knots ( n -- dimensioned ) 1852/3600 * m/s ;

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

: pins ( n -- dimensioned ) 4+1/2 * imperial-gallons ;

: firkins ( n -- dimensioned ) 2 * pins ;

: kilderkins ( n -- dimensioned ) 2 * firkins ;

: beer-barrels ( n -- dimensioned ) 2 * kilderkins ;

: beer-hogsheads ( n -- dimensioned ) 1+1/2 * beer-barrels ;

: beer-butts ( n -- dimensioned ) 2 * beer-hogsheads ;
ALIAS: beer-pipes beer-butts

: beer-tuns ( n -- dimensioned ) 2 * beer-pipes ;

: wine-gallons ( n -- dimensioned ) 18/15 * imperial-gallons ;

: rundlets ( n -- dimensioned ) 18 * wine-gallons ;

: wine-barrels ( n -- dimensioned ) 1+3/4 * rundlets ;

: tierces ( n -- dimensioned ) 1+1/3 * wine-barrels ;

: wine-hogsheads ( n -- dimensioned ) 2 * wine-barrels ;

: wine-punchians ( n -- dimensioned ) 2 * tierces ;
ALIAS: wine-tertians wine-punchians

: wine-butts ( n -- dimensioned ) 2 * wine-hogsheads ;
ALIAS: wine-pipes wine-butts

: wine-tun ( n -- dimensioned ) 2 * wine-butts ;
