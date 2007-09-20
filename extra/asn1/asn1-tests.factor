USING: asn1 asn1.ldap io.streams.string tools.test ;

[ 6 ] [
    "\u0002\u0001\u0006" <string-reader> [ asn-syntax read-ber ] with-stream
] unit-test

[ "testing" ] [
    "\u0004\u0007testing" <string-reader> [ asn-syntax read-ber ] with-stream
] unit-test

[ { 1 { 3 "Administrator" "ad_is_bogus" } } ] [
    "0$\u0002\u0001\u0001`\u001f\u0002\u0001\u0003\u0004\rAdministrator\u0080\u000bad_is_bogus"
    <string-reader> [ asn-syntax read-ber ] with-stream
] unit-test

[
    ! triggers fixnum
    [ B{ 2 3 131 134 80 } ] [ 50000 >ber ] unit-test

    [ B{ 10 3 131 134 80 } ] [ 50000 >ber-enumerated ] unit-test

    ! triggers bignum
    [ B{ 2 5 146 208 151 228 0 } ] [ 5000000000 >ber ] unit-test

    ! triggers string
    [ B{ 4 6 97 98 99 100 101 102 } ] [ "abcdef" >ber ] unit-test

    [ B{ 69 6 97 98 99 100 101 102 } ] [ 
        5 "abcdef" >ber-application-string 
    ] unit-test

    [ B{ 133 6 97 98 99 100 101 102 } ] [ 
        5 "abcdef" >ber-contextspecific 
    ] unit-test

    ! triggers array
    [ B{ 48 4 49 50 51 52 } ] [ { 1 2 3 4 } >ber ] unit-test

    [ B{ 49 4 49 50 51 52 } ] [ { 1 2 3 4 } >ber-set ] unit-test

    [ B{ 48 4 49 50 51 52 } ] [ { 1 2 3 4 } >ber-sequence ] unit-test

    [ B{ 96 4 49 50 51 52 } ] [ 
        { 1 2 3 4 } >ber-appsequence
    ] unit-test

    [ B{ 160 4 49 50 51 52 } ] [ 
        { 1 2 3 4 } >ber-contextspecific 
    ] unit-test

] with-ber
