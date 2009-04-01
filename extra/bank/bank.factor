! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar kernel math math.order money sequences ;
IN: bank

TUPLE: account name interest-rate interest-payment-day opening-date transactions unpaid-interest interest-last-paid ;

: <account> ( name interest-rate interest-payment-day opening-date -- account )
    V{ } clone 0 pick account boa ;

TUPLE: transaction date amount description ;
C: <transaction> transaction

: >>transaction ( account transaction -- account )
    over transactions>> push ;

: total ( transactions -- balance )
    0 [ amount>> + ] reduce ;

: balance>> ( account -- balance ) transactions>> total ;

: open-account ( name interest-rate interest-payment-day opening-date opening-balance -- account )
    [ [ <account> ] keep ] dip "Account Opened" <transaction> >>transaction ;

: daily-rate ( yearly-rate day -- daily-rate )
    days-in-year / ;

: daily-rate>> ( account date -- rate )
    [ interest-rate>> ] dip daily-rate ;

: transactions-on-date ( account date -- transactions )
    [ before? ] curry filter ;

: balance-on-date ( account date -- balance )
    transactions-on-date total ;

: pay-interest ( account date -- )
    over unpaid-interest>> "Interest Credit" <transaction>
    >>transaction 0 >>unpaid-interest drop ;

: interest-payment-day? ( account date -- ? )
    day>> swap interest-payment-day>> = ;

: ?pay-interest ( account date -- )
    2dup interest-payment-day? [ pay-interest ] [ 2drop ] if ;

: unpaid-interest+ ( account amount -- account )
    over unpaid-interest>> + >>unpaid-interest ;

: accumulate-interest ( account date -- )
    [ dupd daily-rate>> over balance>> * unpaid-interest+ ] keep
    >>interest-last-paid drop ;

: process-day ( account date -- )
    2dup accumulate-interest ?pay-interest ;

: each-day ( quot start end -- )
    2dup before? [
        [ dup [ over [ swap call ] dip ] dip 1 days time+ ] dip each-day
    ] [
        3drop
    ] if ; inline recursive

: process-to-date ( account date -- account )
    over interest-last-paid>> 1 days time+
    [ dupd process-day ] spin each-day ; inline

: inserting-transactions ( account transactions -- account )
    [ [ date>> process-to-date ] keep >>transaction ] each ;
