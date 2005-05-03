IN: format
USING: kernel math sequences strings test ;

: decimal-split ( string -- string string )
    #! Split a string before and after the decimal point.
    dup "." index-of dup -1 = [ drop f ] [ string// ] ifte ;

: decimal-tail ( count str -- string )
    #! Given a decimal, trims all but a count of decimal places.
    [ length min ] keep string-head ;

: decimal-cat ( before after -- string )
    #! If after is of zero length, return before, otherwise
    #! return "before.after".
    dup length 0 = [
        drop
    ] [
        "." swap cat3
    ] ifte ;

: decimal-places ( num count -- string )
    #! Trims the number to a count of decimal places.
    >r decimal-split dup [
        r> swap decimal-tail decimal-cat
    ] [
        r> 2drop
    ] ifte ;

[ "123" ] [ 4 "123" decimal-tail ] unit-test
[ "12" ] [ 2 "123" decimal-tail ] unit-test
[ "123" ] [ "123" 2 decimal-places ] unit-test
[ "123.12" ] [ "123.12" 2 decimal-places ] unit-test
[ "123.123" ] [ "123.123" 5 decimal-places ] unit-test
[ "123" ] [ "123.123" 0 decimal-places ] unit-test

