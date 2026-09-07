USING: accessors arrays kernel regexp sequences strings tools.test words ;
IN: regexp.tests.captures

! Capture operations belong alongside the existing matching operations.
{ t } [ "first-match-with-captures" "regexp" lookup-word >boolean ] unit-test
{ t } [ "all-matches-with-captures" "regexp" lookup-word >boolean ] unit-test
{ t } [ "capture" "regexp" lookup-word >boolean ] unit-test
{ t } [ "capture-bounds" "regexp" lookup-word >boolean ] unit-test

{ { { "abc" 0 3 } { "abc" 26 29 } } } [
    "abcdefghijklmnopqrstuvwxyz" dup append
    R/ (abc)/ all-matches-with-captures
    [ 1 swap capture [ >string ] [ from>> ] [ to>> ] tri 3array ] map
] unit-test

{ { { 0 3 } { 26 29 } } } [
    "abcdefghijklmnopqrstuvwxyz" dup append
    R/ (abc)/ all-matches-with-captures
    [ 1 swap capture-bounds 2array ] map
] unit-test

{ { { 26 29 } { 0 3 } } } [
    "abcdefghijklmnopqrstuvwxyz" dup append
    R/ (abc)/r all-matches-with-captures
    [ 1 swap capture-bounds 2array ] map
] unit-test

{ 0 3 2 3 } [
    "abc" R/ ab(?<last>c)/ first-match-with-captures
    [ 0 swap capture-bounds ] [ "last" swap capture-bounds ] bi
] unit-test

{ f f } [ "b" R/ (a)?b/ first-match-with-captures 1 swap capture-bounds ] unit-test
{ 0 0 } [ "b" R/ (a*)b/ first-match-with-captures 1 swap capture-bounds ] unit-test

{ { { 1 4 } { 5 8 } } } [
    "éabcλabc" R/ (abc)/ all-matches-with-captures
    [ 1 swap capture-bounds 2array ] map
] unit-test

{ 0 1 1 3 } [
    "abc" R/ a(?=(bc))/ first-match-with-captures
    [ 0 swap capture-bounds ] [ 1 swap capture-bounds ] bi
] unit-test
