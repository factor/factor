USING: asn1 asn1.ldap io io.streams.string tools.test ;

{ 6 } [
    "\u000002\u000001\u000006" [ asn-syntax read-ber ] with-string-reader
] unit-test

{ "testing" } [
    "\u000004\u000007testing" [ asn-syntax read-ber ] with-string-reader
] unit-test

{ { 1 { 3 "Administrator" "ad_is_bogus" } } } [
    "0$\u000002\u000001\u000001`\u00001f\u000002\u000001\u000003\u000004\rAdministrator\u000080\u00000bad_is_bogus"
    [ asn-syntax read-ber ] with-string-reader
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
        5 "abcdef" >ber-contextspecific-string
    ] unit-test

    ! triggers array
    [ B{ 48 4 49 50 51 52 } ] [ { 1 2 3 4 } >ber ] unit-test

    [ B{ 49 4 49 50 51 52 } ] [ { 1 2 3 4 } >ber-set ] unit-test

    [ B{ 48 4 49 50 51 52 } ] [ { 1 2 3 4 } >ber-sequence ] unit-test

    [ B{ 96 4 49 50 51 52 } ] [
        { 1 2 3 4 } >ber-appsequence
    ] unit-test

    [ B{ 160 4 49 50 51 52 } ] [
        { 1 2 3 4 } >ber-contextspecific-array
    ] unit-test

] with-ber
