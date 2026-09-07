USING: accessors arrays kernel locals regexp regexp.captures
regexp.captures.private regexp.combinators regexp.private sequences strings tools.test ;
IN: regexp.captures.tests

: capture-strings ( match/f -- groups/f )
    [ groups>> [ [ >string ] [ f ] if* ] map ] [ f ] if* ;

{
    { "ab" "(a)(b)" { "ab" "a" "b" } }
    { "ab" "((a)(b))" { "ab" "ab" "a" "b" } }
    { "ab" "(?:a)(b)" { "ab" "b" } }
    { "ab" "(x)|(ab)" { "ab" f "ab" } }
    { "b" "(a)?(b)" { "b" f "b" } }
    { "b" "(a*)(b)" { "b" "" "b" } }
    { "" "()" { "" "" } }
    { "x" "(a)" f }
    { "ab" "abc" f }
    { "abc" "abc" { "abc" } }
    { "aa" "(a|aa)" { "aa" "aa" } }
    { "aa" "(a|aa)(a?)" { "aa" "a" "a" } }
    { "aa" "(aa|a)(a?)" { "aa" "aa" "" } }
    { "aaa" "(a*)(a*)" { "aaa" "aaa" "" } }
    { "aaa" "(a*?)(a*)" { "aaa" "aaa" "" } }
    { "aba" "(a|b)+" { "aba" "a" } }
    { "aba" "((a)|(b))+" { "aba" "a" "a" "b" } }
    { "aba" "(a(b)?)+" { "aba" "a" "b" } }
    { "a" "((a)|b)c|(a)" { "a" f f "a" } }
    { "aaa" "(a){3}" { "aaa" "a" } }
    { "aaa" "(a){2,4}" { "aaa" "a" } }
    { "aaa" "(a){2,}" { "aaa" "a" } }
    { "a" "(a){,2}" { "a" "a" } }
    { "b" "(a){0}(b)" { "b" f "b" } }
    { "b" "((a){0})(b)" { "b" "" f "b" } }
    { "" "(a?)*" { "" "" } }
    { "aa" "(a?)*" { "aa" "a" } }
    { "AB" "(?i:(a))(B)" { "AB" "A" "B" } }
    { "Ab" "(?i:(a)(?-i:(b)))" { "Ab" "A" "b" } }
    { "a\nb" "(?s:(.))(\n)(.)" { "a\nb" "a" "\n" "b" } }
    { "éλ" "(é)(λ)" { "éλ" "é" "λ" } }
    { "x foo!" "\\b(foo)\\b" { "foo" "foo" } }
    { "x\na\ny" "(?m:^(a)$)" { "a" "a" } }
    { "xab" "(?<=(x))(a)(?=(b))" { "a" "x" "a" "b" } }
    { "aa" "(?=(a+))(a)" { "a" "aa" "a" } }
    { "aaab" "(?<=(a+))(b)" { "b" "aaa" "b" } }
    { "a" "(?!(b))(a)" { "a" f "a" } }
    { "a" "(?<!(b))(a)" { "a" f "a" } }
    { "ab" "(?=(?=(a))(ab))(a)" { "a" "a" "ab" "a" } }
    { "ab" "(?=(a))x|(a)(b)" { "ab" f "a" "b" } }
    { "Ab" "(?i:(?<=(a))(b))" { "b" "A" "b" } }
    { "ab" "(?<=(^a))(b)" { "b" "a" "b" } }
    { "ab" "(a)(?=(b$))" { "a" "a" "b" } }
    { "b" "((?~(a)))" { "b" "b" f } }
    { "ab" "(?~(x))(b)" { "ab" f "b" } }
    { "ab" "(?<first>a)(?<last>b)" { "ab" "a" "b" } }
    { "b" "(?<missing>a)?(?<present>b)" { "b" f "b" } }
    { "a" "(?!(?<absent>b))(?<present>a)" { "a" f "a" } }
} [ first3 [| string pattern expected |
    expected 1array [ string pattern <regexp> first-match-with-captures capture-strings ] unit-test
] call ] each

{ "a" "b" "ab" } [
    "ab" R/ (?<first>a)(?<last>b)/ first-match-with-captures
    [ "first" swap capture >string ]
    [ "last" swap capture >string ]
    [ 0 swap capture >string ] tri
] unit-test

{ f } [ "b" R/ (?<missing>a)?b/ first-match-with-captures "missing" swap capture ] unit-test

{ 1 3 1 2 } [
    "xab!" R/ (a)b/ first-match-with-captures
    [ 0 swap capture [ from>> ] [ to>> ] bi ]
    [ 1 swap capture [ from>> ] [ to>> ] bi ] bi
] unit-test

{ { "ab" "a" "b" } } [
    "ab ab" R/ (a)(b)/r first-match-with-captures capture-strings
] unit-test

{ { "Ab" "A" "b" } } [
    "Ab" R/ (a)(b)/i first-match-with-captures capture-strings
] unit-test

{ { "a" "" "a" "" } } [
    "x\na\ny" R/ (?<=(^))(a)(?=($))/mr
    first-match-with-captures capture-strings
] unit-test

{ { "a" "x" "a" "b" } } [
    "xab" R/ (?<=(x))(a)(?=(b))/r first-match-with-captures capture-strings
] unit-test

{ { "a" "a" } } [
    R/ (a|b)/
    [ "a" swap first-match-with-captures ]
    [ "b" swap first-match-with-captures ] bi drop capture-strings
] unit-test

{ { { "a" "a" } { "b" "b" } } } [
    "a b" R/ (\w)/ all-matches-with-captures [ capture-strings ] map
] unit-test

{ { { "b" "b" } { "a" "a" } } } [
    "a b" R/ (\w)/r all-matches-with-captures [ capture-strings ] map
] unit-test

{ 3 3 } [
    "ab" R/ ()/ all-matches-with-captures length
    "ab" R/ ()/r all-matches-with-captures length
] unit-test

{ { "aa" "a" "a" } } [
    "aa" R/ (a)/ dup 2array <sequence> first-match-with-captures capture-strings
] unit-test

{ { "b" f "b" } } [
    "b" { R/ (a)/ R/ (b)/ } <or> first-match-with-captures capture-strings
] unit-test

{ { "aa" "a" } } [
    "aa" R/ (a)/ <one-or-more> first-match-with-captures capture-strings
] unit-test

{ 250 "a" } [
    250 CHAR: a <string> R/ ((a|aa)*)/ first-match-with-captures
    [ 1 swap capture length ] [ 2 swap capture >string ] bi
] unit-test

! Isolate the capture pass: the existing generated DFA exhausts the
! retain stack on sufficiently long input without the optimizer.
{ 5000 "a" } [
    0 5000 5000 CHAR: a <string>
    R/ ((a|aa)*)/ ensure-capture-code capture-result
    [ 1 swap capture length ] [ 2 swap capture >string ] bi
] unit-test

[ "a" R/ (?<x>a)(?<x>b)?/ first-match-with-captures ]
[ duplicate-capture-name? ] must-fail-with

[ "a" R/ (a)/ first-match-with-captures "missing" swap capture ]
[ unknown-capture-group? ] must-fail-with

[ "a" R/ (a)/ first-match-with-captures 2 swap capture ]
[ unknown-capture-group? ] must-fail-with

[ "a" R/ (a)/ first-match-with-captures -1 swap capture ]
[ unknown-capture-group? ] must-fail-with

! The capture pass must reproduce DFA-selected bounds across the
! extended syntax, including conditional states inside complements.
{
    R/ ((?~a+|b))/ R/ ((?~^a$))/ R/ ((?~(?=a)a))/
    R/ ((?~(?<=b)a))/ R/ ((?~[a-zA-Z]c|\p{Lower}b))/
    R/ ([a-z&&^b])/ R/ ([a-z--b])/ R/ (\p{Lower}+)/
    R/ (?<=(^))(a)/m R/ (a)(?=($))/m R/ ((?~a+|b))/r
    R/ (?<=(^))(a)/mr R/ ((?~(?=a)a))/r
    R/ (?<=(?=(ab))(a))(b)/ R/ (a)(?=(?<=a)(b))/
} [| re |
    { "" "a" "b" "aa" "ab" "ba" "a\nb" "πc" } [| string |
        { t } [
            string re first-match
            string re first-match-with-captures
            [ 0 swap capture ] [ f ] if* =
        ] unit-test
    ] each
] each
