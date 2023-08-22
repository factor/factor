! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs kernel math math.order random semver sequences
sequences.extras sorting tools.test ;
IN: semver.tests

CONSTANT: semver-ranges {
    { "1.0.0 - 2.0.0" ">=1.0.0 <=2.0.0" }
    { "1.0.0 - 2.0.0" ">=1.0.0-0 <2.0.1-0" }
    { "1 - 2" ">=1.0.0 <3.0.0-0" }
    { "1 - 2" ">=1.0.0-0 <3.0.0-0" }
    { "1.0 - 2.0" ">=1.0.0 <2.1.0-0" }
    { "1.0 - 2.0" ">=1.0.0-0 <2.1.0-0" }
    { "1.0.0" "1.0.0" }
    { ">=*" "*" }
    ! { "" "*" }
    { "*" "*" }
    { "*" "*" }
    { ">=1.0.0" ">=1.0.0" }
    { ">1.0.0" ">1.0.0" }
    { "<=2.0.0" "<=2.0.0" }
    { "1" ">=1.0.0 <2.0.0-0" }
    { "<=2.0.0" "<=2.0.0" }
    { "<=2.0.0" "<=2.0.0" }
    { "<2.0.0" "<2.0.0" }
    { "<2.0.0" "<2.0.0" }
    { ">= 1.0.0" ">=1.0.0" }
    { ">=  1.0.0" ">=1.0.0" }
    { ">=   1.0.0" ">=1.0.0" }
    { "> 1.0.0" ">1.0.0" }
    { ">  1.0.0" ">1.0.0" }
    { "<=   2.0.0" "<=2.0.0" }
    { "<= 2.0.0" "<=2.0.0" }
    { "<=  2.0.0" "<=2.0.0" }
    { "<    2.0.0" "<2.0.0" }
    { "<\t2.0.0" "<2.0.0" }
    { ">=0.1.97" ">=0.1.97" }
    { ">=0.1.97" ">=0.1.97" }
    { "0.1.20 || 1.2.4" "0.1.20||1.2.4" }
    { ">=0.2.3 || <0.0.1" ">=0.2.3||<0.0.1" }
    { ">=0.2.3 || <0.0.1" ">=0.2.3||<0.0.1" }
    { ">=0.2.3 || <0.0.1" ">=0.2.3||<0.0.1" }
    { "||" "*" }
    { "2.x.x" ">=2.0.0 <3.0.0-0" }
    { "1.2.x" ">=1.2.0 <1.3.0-0" }
    { "1.2.x || 2.x" ">=1.2.0 <1.3.0-0||>=2.0.0 <3.0.0-0" }
    { "1.2.x || 2.x" ">=1.2.0 <1.3.0-0||>=2.0.0 <3.0.0-0" }
    { "x" "*" }
    { "2.*.*" ">=2.0.0 <3.0.0-0" }
    { "1.2.*" ">=1.2.0 <1.3.0-0" }
    { "1.2.* || 2.*" ">=1.2.0 <1.3.0-0||>=2.0.0 <3.0.0-0" }
    { "*" "*" }
    { "2" ">=2.0.0 <3.0.0-0" }
    { "2.3" ">=2.3.0 <2.4.0-0" }
    { "~2.4" ">=2.4.0 <2.5.0-0" }
    { "~2.4" ">=2.4.0 <2.5.0-0" }
    { "~>3.2.1" ">=3.2.1 <3.3.0-0" }
    { "~1" ">=1.0.0 <2.0.0-0" }
    { "~>1" ">=1.0.0 <2.0.0-0" }
    { "~> 1" ">=1.0.0 <2.0.0-0" }
    { "~1.0" ">=1.0.0 <1.1.0-0" }
    { "~ 1.0" ">=1.0.0 <1.1.0-0" }
    { "^0" "<1.0.0-0" }
    { "^ 1" ">=1.0.0 <2.0.0-0" }
    { "^0.1" ">=0.1.0 <0.2.0-0" }
    { "^1.0" ">=1.0.0 <2.0.0-0" }
    { "^1.2" ">=1.2.0 <2.0.0-0" }
    { "^0.0.1" ">=0.0.1 <0.0.2-0" }
    { "^0.0.1-beta" ">=0.0.1-beta <0.0.2-0" }
    { "^0.1.2" ">=0.1.2 <0.2.0-0" }
    { "^1.2.3" ">=1.2.3 <2.0.0-0" }
    { "^1.2.3-beta.4" ">=1.2.3-beta.4 <2.0.0-0" }
    { "<1" "<1.0.0-0" }
    { "< 1" "<1.0.0-0" }
    { ">=1" ">=1.0.0" }
    { ">= 1" ">=1.0.0" }
    { "<1.2" "<1.2.0-0" }
    { "< 1.2" "<1.2.0-0" }
    { "1" ">=1.0.0 <2.0.0-0" }
    { ">01.02.03" ">1.2.3" }
    ! { ">01.02.03" null" }
    ! { "~1.2.3beta" ">=1.2.3-beta <1.3.0-0" }
    ! { "~1.2.3beta" null" }
    { "^ 1.2 ^ 1" ">=1.2.0 <2.0.0-0 >=1.0.0" }
    { "1.2 - 3.4.5" ">=1.2.0 <=3.4.5" }
    { "1.2.3 - 3.4" ">=1.2.3 <3.5.0-0" }
    { "1.2 - 3.4" ">=1.2.0 <3.5.0-0" }
    { ">1" ">=2.0.0" }
    { ">1.2" ">=1.3.0" }
    { ">X" "<0.0.0-0" }
    { "<X" "<0.0.0-0" }
    { "<x <* || >* 2.x" "<0.0.0-0" }
    { ">x 2.x || * || <x" "*" }
}


! first > second
CONSTANT: semver-gt-comparisons {
    { "0.0.0" "0.0.0-foo" }
    { "0.0.1" "0.0.0" }
    { "1.0.0" "0.9.9" }
    { "0.10.0" "0.9.0" }
    { "0.99.0" "0.10.0" }
    { "2.0.0" "1.2.3" }
    ! { "v0.0.0" "0.0.0-oo" }
    ! { "v0.0.1" "0.0.0" }
    ! { "v1.0.0" "0.9.9" }
    ! { "v0.10.0" "0.9.0" }
    ! { "v0.99.0" "0.10.0" }
    ! { "v2.0.0" "1.2.3" }
    ! { "0.0.0" "v0.0.0-fo" }
    ! { "0.0.1" "v0.0.0" }
    ! { "1.0.0" "v0.9.9" }
    ! { "0.10.0" "v0.9.0" }
    ! { "0.99.0" "v0.10.0" }
    ! { "2.0.0" "v1.2.3" }
    { "1.2.3" "1.2.3-asf" }
    { "1.2.3" "1.2.3-4" }
    { "1.2.3" "1.2.3-4-fo" }
    { "1.2.3-5-foo" "1.2.3-5" }
    { "1.2.3-5" "1.2.3-4" }
    { "1.2.3-5-foo" "1.2.3-5-Foo" }
    { "3.0.0" "2.7.2+asdf" }
    { "1.2.3-a.10" "1.2.3-a.5" }
    { "1.2.3-a.b" "1.2.3-a.5" }
    { "1.2.3-a.b" "1.2.3-a" }
    ! { "1.2.3-a.b.c.10.d.5" ".2.3-a.b.c.5.d.100" }
    { "1.2.3-r2" "1.2.3-r100" }
    { "1.2.3-r100" "1.2.3-R2" }
}

{ t } [
    semver-gt-comparisons [ first2 semver<=> +gt+ eq? ] all?
] unit-test

{ t } [
    semver-gt-comparisons [ first2 swap semver<=> +lt+ eq? ] all?
] unit-test

{ "2.0.0" } [ "1.0.4-rc.1" >semver bump-major semver>string ] unit-test
{ "2.0.0" } [ "1.1.0-rc.1" >semver bump-major semver>string ] unit-test
{ "2.0.0" } [ "1.1.4-rc.1" >semver bump-major semver>string ] unit-test
{ "2.0.0" } [ "1.2.3" >semver bump-major semver>string ] unit-test
{ "1.0.0" } [ "1.0.0-rc.1" >semver bump-major semver>string ] unit-test

{ "0.2.0" } [ "0.2.0-rc.1" >semver bump-minor semver>string ] unit-test
{ "0.3.0" } [ "0.2.5-rc.1" >semver bump-minor semver>string ] unit-test
{ "1.4.0" } [ "1.3.1" >semver bump-minor semver>string ] unit-test

{ "1.3.3" } [ "1.3.2" >semver bump-patch semver>string ] unit-test
{ "0.1.5" } [ "0.1.5-rc.2" >semver bump-patch semver>string ] unit-test

{
    "0.1.4"
    "0.1.5-0"
    "0.1.5-1"
    "0.1.5-alpha.0"
    "0.1.5-alpha.1"
    "0.1.5-beta.0"
    "0.1.5-beta.1"
    "0.1.5-rc.0"
    "0.1.5-rc.1"
    "0.1.5"
} [
    "0.1.4" >semver [ semver>string ] keep
    2 [ bump-dev [ semver>string ] keep ] times
    2 [ bump-alpha [ semver>string ] keep ] times
    2 [ bump-beta [ semver>string ] keep ] times
    2 [ bump-rc [ semver>string ] keep ] times
    bump-patch semver>string
] unit-test

{ "1.2.4-0" } [ "1.2.3" >semver bump-prepatch semver>string ] unit-test
{ "1.3.0-0" } [ "1.2.3" >semver bump-preminor semver>string ] unit-test
{ "2.0.0-0" } [ "1.2.3" >semver bump-premajor semver>string ] unit-test
{ "2.0.0-1" } [ "1.2.3" >semver bump-premajor bump-dev semver>string ] unit-test

{ "1.2.3-erg.0" } [ "1.2.3-0" >semver "erg" bump-prerelease semver>string ] unit-test
{ "1.2.3-erg.1" } [ "1.2.3-erg.0" >semver "erg" bump-prerelease semver>string ] unit-test
{ "1.2.4-erg.0" } [ "1.2.3" >semver "erg" bump-prerelease semver>string ] unit-test

{ T{ semver f 2 7 2 "pre" "build" } } [ "2.7.2-pre+build" >semver ] unit-test
{ T{ semver f 2 7 2 "pre" f } } [ "2.7.2-pre" >semver ] unit-test
{ T{ semver f 2 7 2 f "build" } } [ "2.7.2+build" >semver ] unit-test

[ "2.7.2.1+build" >semver ] [ malformed-semver? ] must-fail-with
[ "2.7.2.+build" >semver ] [ malformed-semver? ] must-fail-with
[ "2.7.2." >semver ] [ malformed-semver? ] must-fail-with
[ "2.7." >semver ] [ malformed-semver? ] must-fail-with
[ "2.7" >semver ] [ malformed-semver? ] must-fail-with
[ "2." >semver ] [ malformed-semver? ] must-fail-with
[ "2" >semver ] [ malformed-semver? ] must-fail-with

{ +gt+ } [ "1.2.0-dev1" "0.12.1-dev2" semver<=> ] unit-test
{ +lt+ } [ "1.2.0-dev12" "1.2.0-dev2" semver<=> ] unit-test
{ +gt+ } [ "1.2.0-dev3" "1.2.0-dev21" semver<=> ] unit-test
{ +lt+ } [ "1.9.0" "1.10.0" semver<=> ] unit-test
{ +eq+ } [ "2.0.0-rc1" "2.0.0-rc1" semver<=> ] unit-test
{ +lt+ } [ "1.0.0-rc1" "1.0.0" semver<=> ] unit-test
{ +lt+ } [ "1.0.0-rc1" "1.0.0-rc2" semver<=> ] unit-test
{ +lt+ } [ "1.0.0-rc.1" "1.0.0-rc.11" semver<=> ] unit-test
{ +lt+ } [ "1.0.0-rc.2" "1.0.0-rc.11" semver<=> ] unit-test
{ +eq+ } [ "1.0.0+foo" "1.0.0+bar" semver<=> ] unit-test
{ +eq+ } [ "1.0.0" "1.0.0" semver<=> ] unit-test

{ t } [
    {
        "1.0.0-0"
        "1.0.0-12"
        "1.0.0-alpha"
        "1.0.0-alpha.1"
        "1.0.0-alpha.beta"
        "1.0.0-beta"
        "1.0.0-beta.2"
        "1.0.0-beta.11"
        "1.0.0-rc.1"
        "1.0.0"
        "2.0.0"
        "2.1.0"
        "2.1.1"
    } dup clone randomize [ semver<=> ] sort-with =
] unit-test
