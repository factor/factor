! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors math math.order money kernel assocs ;
IN: taxes.usa.fica

: fica-tax-rate ( -- x ) DECIMAL: .062 ; inline

ERROR: fica-base-unknown ;

: fica-base-rate ( year -- x )
    H{
        { 2009 106800 }
        { 2008 102000 }
        { 2007  97500 }
    } at [ fica-base-unknown ] unless* ;

: fica-tax ( salary w4 -- x )
    year>> fica-base-rate min fica-tax-rate * ;
