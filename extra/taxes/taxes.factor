USING: arrays assocs kernel math math.intervals namespaces
sequences combinators.lib money ;
IN: taxes

: monthly ( x -- y ) 12 / ;
: semimonthly ( x -- y ) 24 / ;
: biweekly ( x -- y ) 26 / ;
: weekly ( x -- y ) 52 / ;
: daily ( x -- y ) 360 / ;

! Each employee fills out a w4
TUPLE: w4 year allowances married? ;
C: <w4> w4

: allowance ( -- x ) 3500 ; inline

: calculate-w4-allowances ( w4 -- x )
    w4-allowances allowance * ;

! Withhold: FICA, Medicare, Federal (FICA is social security)
: fica-tax-rate ( -- x ) DECIMAL: .062 ; inline

! Base rate -- income over this rate is not taxed
TUPLE: fica-base-unknown ;
: fica-base-rate ( year -- x )
    H{
        { 2008 102000 }
        { 2007  97500 }
    } at* [ T{ fica-base-unknown } throw ] unless ;

: fica-tax ( salary w4 -- x )
    w4-year fica-base-rate min fica-tax-rate * ;

! Employer tax only, not withheld
: futa-tax-rate ( -- x ) DECIMAL: .062 ; inline

! No base rate for medicare; all wages subject
: medicare-tax-rate ( -- x ) DECIMAL: .0145 ; inline
: medicare-tax ( salary w4 -- x ) drop medicare-tax-rate * ;

MIXIN: collector
GENERIC: adjust-allowances ( salary w4 collector -- newsalary )
GENERIC: withholding ( salary w4 collector -- x )

TUPLE: tax-table single married ;

: <tax-table> ( single married class -- obj )
    >r tax-table construct-boa r> construct-delegate ;

: tax-bracket-range dup second swap first - ;

: tax-bracket ( tax salary triples -- tax salary )
    [ [ tax-bracket-range min ] keep third * + ] 2keep
    tax-bracket-range [-] ;

: tax ( salary triples -- x )
    0 -rot [ tax-bracket ] each drop ;

: marriage-table ( w4 tax-table -- triples )
    swap w4-married?
    [ tax-table-married ] [ tax-table-single ] if ;

: federal-tax ( salary w4 tax-table -- n )
    [ adjust-allowances ] 2keep marriage-table tax ;

! http://www.irs.gov/pub/irs-pdf/p15.pdf
! Table 7 ANNUAL Payroll Period 

: federal-single ( -- triples )
    {
        {      0   2650 DECIMAL: 0   }
        {   2650  10300 DECIMAL: .10 }
        {  10300  33960 DECIMAL: .15 }
        {  33960  79725 DECIMAL: .25 }
        {  79725 166500 DECIMAL: .28 }
        { 166500 359650 DECIMAL: .33 }
        { 359650   1/0. DECIMAL: .35 }
    } ;

: federal-married ( -- triples )
    {
        {      0   8000 DECIMAL: 0   }
        {   8000  23550 DECIMAL: .10 }
        {  23550  72150 DECIMAL: .15 }
        {  72150 137850 DECIMAL: .25 }
        { 137850 207700 DECIMAL: .28 }
        { 207700 365100 DECIMAL: .33 }
        { 365100   1/0. DECIMAL: .35 }
    } ;

TUPLE: federal ;
INSTANCE: federal collector
: <federal> ( -- obj )
    federal-single federal-married federal <tax-table> ;

M: federal adjust-allowances ( salary w4 collector -- newsalary )
    drop calculate-w4-allowances - ;

M: federal withholding ( salary w4 tax-table -- x )
    [ federal-tax ] 3keep drop
    [ fica-tax ] 2keep
    medicare-tax + + ;


! Minnesota
: minnesota-single ( -- triples )
    {
        {     0  1950  DECIMAL: 0     }
        {  1950 23750  DECIMAL: .0535 }
        { 23750 73540  DECIMAL: .0705 }
        { 73540 1/0.   DECIMAL: .0785 }
    } ;

: minnesota-married ( -- triples )
    {
        {      0   7400 DECIMAL: 0     }
        {   7400  39260 DECIMAL: .0535 }
        {  39260 133980 DECIMAL: .0705 }
        { 133980   1/0. DECIMAL: .0785 }
    } ;

TUPLE: minnesota ;
INSTANCE: minnesota collector
: <minnesota> ( -- obj )
    minnesota-single minnesota-married minnesota <tax-table> ;

M: minnesota adjust-allowances ( salary w4 collector -- newsalary )
    drop calculate-w4-allowances - ;

M: minnesota withholding ( salary w4 collector -- x )
    [ adjust-allowances ] 2keep marriage-table tax ;

: employer-withhold ( salary w4 collector -- x )
    [ withholding ] 3keep
    dup federal? [ 3drop ] [ drop <federal> withholding + ] if ;

: net ( salary w4 collector -- x )
    >r dupd r> employer-withhold - ;
