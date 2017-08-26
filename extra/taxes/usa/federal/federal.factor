! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs kernel math math.intervals
namespaces sequences money math.order taxes.usa.fica
taxes.usa.medicare taxes.usa taxes.usa.w4 ;
IN: taxes.usa.federal

! http://www.irs.gov/pub/irs-pdf/p15.pdf
! Table 7 ANNUAL Payroll Period

: federal-single ( -- triples )
    {
        {      0   2650 decimal: 0   }
        {   2650  10300 decimal: .10 }
        {  10300  33960 decimal: .15 }
        {  33960  79725 decimal: .25 }
        {  79725 166500 decimal: .28 }
        { 166500 359650 decimal: .33 }
        { 359650   1/0. decimal: .35 }
    } ;

: federal-married ( -- triples )
    {
        {      0   8000 decimal: 0   }
        {   8000  23550 decimal: .10 }
        {  23550  72150 decimal: .15 }
        {  72150 137850 decimal: .25 }
        { 137850 207700 decimal: .28 }
        { 207700 365100 decimal: .33 }
        { 365100   1/0. decimal: .35 }
    } ;

SINGLETON: federal
: <federal> ( -- obj )
    federal federal-single federal-married <tax-table> ;

: federal-tax ( salary w4 tax-table -- n )
    [ adjust-allowances ] 2keep marriage-table tax ;

M: federal adjust-allowances* ( salary w4 collector entity -- newsalary )
    2drop calculate-w4-allowances - ;

M: federal withholding* ( salary w4 tax-table entity -- x )
    drop
    [ federal-tax ] 3keep drop
    [ fica-tax ] 2keep
    medicare-tax + + ;

: total-withholding ( salary w4 tax-table -- x )
    dup entity>> dup federal = [
        withholding*
    ] [
        drop
        [ drop <federal> federal withholding* ]
        [ dup entity>> withholding* ] 3bi +
    ] if ;

: net ( salary w4 collector -- x )
    [ dupd ] dip total-withholding - ;
