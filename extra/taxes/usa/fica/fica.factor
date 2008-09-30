! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors math math.order money ;
IN: taxes.usa.fica

: fica-tax-rate ( -- x ) DECIMAL: .062 ; inline

ERROR: fica-base-unknown year ;

: fica-base-rate ( year -- x )
    H{
        { 2008 102000 }
        { 2007  97500 }
    } [ fica-base-unknown ] unless-at ;

: fica-tax ( salary w4 -- x )
    year>> fica-base-rate min fica-tax-rate * ;
