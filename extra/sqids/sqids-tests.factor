! Copyright (C) 2026 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays kernel locals math sequences sqids
tools.test ;
IN: sqids.tests

! Tests adapted from https://github.com/sqids/sqids-spec

! ===== encoding =====

! simple
{ "86Rf07" } [ <default-sqids> { 1 2 3 } sqids-encode ] unit-test
{ { 1 2 3 } } [ <default-sqids> "86Rf07" sqids-decode ] unit-test

! incremental numbers
{ "bM" } [ <default-sqids> { 0 } sqids-encode ] unit-test
{ "Uk" } [ <default-sqids> { 1 } sqids-encode ] unit-test
{ "gb" } [ <default-sqids> { 2 } sqids-encode ] unit-test
{ "Ef" } [ <default-sqids> { 3 } sqids-encode ] unit-test
{ "Vq" } [ <default-sqids> { 4 } sqids-encode ] unit-test
{ "uw" } [ <default-sqids> { 5 } sqids-encode ] unit-test
{ "OI" } [ <default-sqids> { 6 } sqids-encode ] unit-test
{ "AX" } [ <default-sqids> { 7 } sqids-encode ] unit-test
{ "p6" } [ <default-sqids> { 8 } sqids-encode ] unit-test
{ "nJ" } [ <default-sqids> { 9 } sqids-encode ] unit-test

! incremental numbers, same index 0
{ "SvIz" } [ <default-sqids> { 0 0 } sqids-encode ] unit-test
{ "n3qa" } [ <default-sqids> { 0 1 } sqids-encode ] unit-test
{ "tryF" } [ <default-sqids> { 0 2 } sqids-encode ] unit-test
{ "eg6q" } [ <default-sqids> { 0 3 } sqids-encode ] unit-test
{ "rSCF" } [ <default-sqids> { 0 4 } sqids-encode ] unit-test
{ "sR8x" } [ <default-sqids> { 0 5 } sqids-encode ] unit-test
{ "uY2M" } [ <default-sqids> { 0 6 } sqids-encode ] unit-test
{ "74dI" } [ <default-sqids> { 0 7 } sqids-encode ] unit-test
{ "30WX" } [ <default-sqids> { 0 8 } sqids-encode ] unit-test
{ "moxr" } [ <default-sqids> { 0 9 } sqids-encode ] unit-test

! incremental numbers, same index 1
{ "nWqP" } [ <default-sqids> { 1 0 } sqids-encode ] unit-test
{ "tSyw" } [ <default-sqids> { 2 0 } sqids-encode ] unit-test
{ "eX68" } [ <default-sqids> { 3 0 } sqids-encode ] unit-test
{ "rxCY" } [ <default-sqids> { 4 0 } sqids-encode ] unit-test
{ "sV8a" } [ <default-sqids> { 5 0 } sqids-encode ] unit-test
{ "uf2K" } [ <default-sqids> { 6 0 } sqids-encode ] unit-test
{ "7Cdk" } [ <default-sqids> { 7 0 } sqids-encode ] unit-test
{ "3aWP" } [ <default-sqids> { 8 0 } sqids-encode ] unit-test
{ "m2xn" } [ <default-sqids> { 9 0 } sqids-encode ] unit-test

! empty input
{ "" } [ <default-sqids> { } sqids-encode ] unit-test

! decoding empty / invalid
{ { } } [ <default-sqids> "" sqids-decode ] unit-test
{ { } } [ <default-sqids> "*" sqids-decode ] unit-test
{ { } } [ <default-sqids> "8" sqids-decode ] unit-test
{ { } } [ <default-sqids> "8R" sqids-decode ] unit-test
{ { 1 } } [ <default-sqids> "86R" sqids-decode ] unit-test
{ { } } [ <default-sqids> "86Rf07*" sqids-decode ] unit-test
{ { } } [ <default-sqids> "86Rf07ë" sqids-decode ] unit-test

! out-of-range numbers (no upper limit in Factor, just non-negative)
[ <default-sqids> { -1 } sqids-encode ] [ number-out-of-range? ] must-fail-with

! Reject non-integers before using them as alphabet indices.
[ <default-sqids> { 1.5 } sqids-encode ] [ number-out-of-range? ] must-fail-with
[ <default-sqids> { 1.0 } sqids-encode ] [ number-out-of-range? ] must-fail-with
[ <default-sqids> { 1/2 } sqids-encode ] [ number-out-of-range? ] must-fail-with
[ <default-sqids> { f } sqids-encode ] [ number-out-of-range? ] must-fail-with
[ <default-sqids> { 0 -1 2 } sqids-encode ] [
    dup number-out-of-range? [ n>> -1 = ] [ drop f ] if
] must-fail-with

! multi-input round-trip (large)
{ t } [
    <default-sqids>
    { 0 0 0 1 2 3 100 1000 100000 1000000 9999999999999999999 }
    [ dupd sqids-encode sqids-decode ] keep =
] unit-test

! Long inputs exercise the shuffle and decode loop repeatedly.
{ t } [
    <default-sqids> 1000 <iota>
    [ dupd sqids-encode sqids-decode ] keep sequence=
] unit-test

! ===== alphabet =====

{ "489158" } [
    "0123456789abcdef" default-min-length default-blocklist <sqids>
    { 1 2 3 } sqids-encode
] unit-test

! short alphabet round-trip
{ { 1 2 3 } } [
    "abc" default-min-length default-blocklist <sqids> dup
    { 1 2 3 } sqids-encode sqids-decode
] unit-test

! long alphabet round-trip
{ { 1 2 3 } } [
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_+|{}[];:'\"/?.>,<`~"
    default-min-length default-blocklist <sqids> dup
    { 1 2 3 } sqids-encode sqids-decode
] unit-test

! multibyte characters
[
    "ë1092" default-min-length default-blocklist <sqids>
] [ alphabet-multibyte-char? ] must-fail-with

! repeating alphabet characters
[
    "aabcdefg" default-min-length default-blocklist <sqids>
] [ alphabet-duplicate-chars? ] must-fail-with

! too short alphabet
[
    "ab" default-min-length default-blocklist <sqids>
] [ alphabet-too-short? ] must-fail-with

! ===== min length =====

! min length equal to alphabet length
{ "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTM" } [
    default-alphabet 62 default-blocklist <sqids>
    { 1 2 3 } sqids-encode
] unit-test

! incremental min-length growth
{ "86Rf07" } [
    default-alphabet 6 default-blocklist <sqids> { 1 2 3 } sqids-encode
] unit-test

{ "86Rf07x" } [
    default-alphabet 7 default-blocklist <sqids> { 1 2 3 } sqids-encode
] unit-test

{ "86Rf07xd" } [
    default-alphabet 8 default-blocklist <sqids> { 1 2 3 } sqids-encode
] unit-test

{ "86Rf07xd4" } [
    default-alphabet 9 default-blocklist <sqids> { 1 2 3 } sqids-encode
] unit-test

{ "86Rf07xd4zBmi" } [
    default-alphabet 13 default-blocklist <sqids> { 1 2 3 } sqids-encode
] unit-test

{ "86Rf07xd4zBmiJXQG6otHEbew02c3PWsUOLZxADhCpKj7aVFv9I8RquYrNlSTMy" } [
    default-alphabet 63 default-blocklist <sqids> { 1 2 3 } sqids-encode
] unit-test

! min length with multi-number input (index 0)
{ "SvIzsqYMyQwI3GWgJAe17URxX8V924Co0DaTZLtFjHriEn5bPhcSkfmvOslpBu" } [
    default-alphabet 62 default-blocklist <sqids>
    { 0 0 } sqids-encode
] unit-test

{ "n3qafPOLKdfHpuNw3M61r95svbeJGk7aAEgYn4WlSjXURmF8IDqZBy0CT2VxQc" } [
    default-alphabet 62 default-blocklist <sqids>
    { 0 1 } sqids-encode
] unit-test

! invalid min-length
[
    default-alphabet -1 default-blocklist <sqids>
] [ invalid-min-length? ] must-fail-with

[
    default-alphabet 256 default-blocklist <sqids>
] [ invalid-min-length? ] must-fail-with

! Validate types as well as bounds for the minimum length.
[
    default-alphabet 1.5 default-blocklist <sqids>
] [ invalid-min-length? ] must-fail-with

[
    default-alphabet 1.0 default-blocklist <sqids>
] [ invalid-min-length? ] must-fail-with

[
    default-alphabet 1/2 default-blocklist <sqids>
] [ invalid-min-length? ] must-fail-with

[
    default-alphabet f default-blocklist <sqids>
] [ invalid-min-length? ] must-fail-with

! Empty input stays empty even when padding is requested.
{ "" } [ default-alphabet 255 { } <sqids> { } sqids-encode ] unit-test

! Exercise every supported minimum length, including multiple padding shuffles.
{ t } [
    "abc" "0123456789abcdef" default-alphabet 3array [| alphabet |
        256 <iota> [| min-length |
            alphabet min-length { } <sqids> :> encoder
            {
                { 0 }
                { 0 0 0 0 0 }
                { 1 2 3 4 5 6 7 8 9 10 }
                { 100 200 300 }
                { 18446744073709551616 123456789012345678901234567890 }
            } [| numbers |
                encoder numbers sqids-encode :> id
                id length min-length >=
                encoder id sqids-decode numbers = and
            ] all?
        ] all?
    ] all?
] unit-test

! ===== blocklist =====

! default blocklist re-encodes aho1e
{ { 4572721 } } [ <default-sqids> "aho1e" sqids-decode ] unit-test
{ "JExTR" } [ <default-sqids> { 4572721 } sqids-encode ] unit-test

! empty blocklist allows aho1e
{ "aho1e" } [
    default-alphabet default-min-length { } <sqids>
    { 4572721 } sqids-encode
] unit-test

! custom blocklist
{ "QyG4" } [
    default-alphabet default-min-length { "ArUO" } <sqids>
    { 100000 } sqids-encode
] unit-test

! short blocklist word - shouldn't match
{ { 1000 } } [
    default-alphabet default-min-length { "pnd" } <sqids> dup
    { 1000 } sqids-encode sqids-decode
] unit-test

! lowercase blocklist with uppercase alphabet
{ "IBSHOZ" } [
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ" default-min-length { "sxnzkl" } <sqids>
    { 1 2 3 } sqids-encode
] unit-test

! id <= 3 chars: exact match
{ "86u" } [
    default-alphabet default-min-length { "hey" } <sqids>
    { 100 } sqids-encode
] unit-test

{ "sec" } [
    default-alphabet default-min-length { "86u" } <sqids>
    { 100 } sqids-encode
] unit-test

! word <=3 chars in larger id: no substring match
{ "gMvFo" } [
    default-alphabet default-min-length { "vFo" } <sqids>
    { 1000000 } sqids-encode
] unit-test

! word with digits matches at start
{ "oDqljxrokxRt" } [
    default-alphabet default-min-length { "lP3i" } <sqids>
    { 100 202 303 404 } sqids-encode
] unit-test

! word with digits matches at end
{ "oDqljxrokxRt" } [
    default-alphabet default-min-length { "1HkYs" } <sqids>
    { 100 202 303 404 } sqids-encode
] unit-test

! word with digits should NOT match in middle
{ "862REt0hfxXVdsLG8vGWD" } [
    default-alphabet default-min-length { "0hfxX" } <sqids>
    { 101 202 303 404 505 606 707 } sqids-encode
] unit-test

! word without digits matches in middle
{ "seu8n1jO9C4KQQDxdOxsK" } [
    default-alphabet default-min-length { "hfxX" } <sqids>
    { 101 202 303 404 505 606 707 } sqids-encode
] unit-test

! max encoding attempts
[
    "abc" 3 { "cab" "abc" "bca" } <sqids> { 0 } sqids-encode
] [ max-attempts-reached? ] must-fail-with

! Multiple retries must advance the offset, including substring and end matches.
{ "1aYeB7bRUt" } [
    default-alphabet 0
    { "JSwXFaosAN" "OCjV9JK64o" "rBHf" "79SM" "7tE6" } <sqids>
    { 1000000 2000000 } sqids-encode
] unit-test

! Blocked and non-canonical IDs remain decodable.
{ t } [
    { "86Rf07" "se8ojk" "ARsz1p" "Q8AI49" "5sQRZO" } dup
    default-alphabet 0 rot <sqids> [| id encoder |
        encoder id sqids-decode { 1 2 3 } =
    ] curry all?
] unit-test

! Custom blocklists replace the default; invalid words and duplicates are removed.
{ "aho1e" } [
    default-alphabet 0 { "ArUO" } <sqids> { 4572721 } sqids-encode
] unit-test

{ { "abc" } } [
    "abc" 0 { "" "ab" "ABC" "abc" "abcd" "ëbc" } <sqids> blocklist>>
] unit-test
