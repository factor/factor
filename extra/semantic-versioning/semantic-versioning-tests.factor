USING: assocs kernel math.order random semantic-versioning
sequences sequences.extras sorting tools.test ;
IN: semantic-versioning

{
    {
        { { 0 1 0 } f f }
        { { 0 97 0 } f f }
        { { 1 1 0 } f f }
        { { 1 2 3 } f f }
        { { 1 0 0 } "dev1" f }
        { { 1 0 0 } "rc1" "build" }
        { { 1 0 0 } "rc2" f }
        { { 1 0 0 } "rc2" "123456" }
    }
} [
    {
        ".1"
        "0.97"
        "1.1"
        "1.2.3"
        "1.0.0dev1"
        "1.0.0rc1+build"
        "1.0.0-rc2"
        "1.0.0-rc2+123456"
    } [ split-version ] map
] unit-test

{ +gt+ } [ "1.2.0dev1" "0.12.1dev2" version<=> ] unit-test
{ +lt+ } [ "1.9.0" "1.10.0" version<=> ] unit-test
{ +eq+ } [ "2.0.0rc1" "2.0.0rc1" version<=> ] unit-test
{ +lt+ } [ "1.0.0rc1" "1.0.0" version<=> ] unit-test
{ +lt+ } [ "1.0.0rc1" "1.0.0rc2" version<=> ] unit-test
{ +lt+ } [ "1.0.0-rc.1" "1.0.0-rc.11" version<=> ] unit-test
{ +lt+ } [ "1.0.0-rc.2" "1.0.0-rc.11" version<=> ] unit-test
{ +eq+ } [ "1.0.0+foo" "1.0.0+bar" version<=> ] unit-test
{ +eq+ } [ "1.0" "1.0.0" version<=> ] unit-test

{ t } [
    {
        "1.0.0-alpha"
        "1.0.0-alpha.1"
        "1.0.0-alpha.beta"
        "1.0.0-beta"
        "1.0.0-beta.2"
        "1.0.0-beta.11"
        "1.0.0-rc.1"
        "1.0.0"
    } dup clone randomize [ version<=> ] sort =
] unit-test

! { +gt+ } [ "1.2.3-r2" "1.2.3-r100" version<=> ] unit-test

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
    ! { "1.2.3-a.b.c.10.d.5" ".2.3-a.b.c.5.d.100" } ! bad parse
    ! { "1.2.3-r2" "1.2.3-r100" } ! fixme
    { "1.2.3-r100" "1.2.3-R2" }
}

{ t } [
    semver-gt-comparisons
    [ first2 version<=> ] zip-with
    values [ +gt+ = ] all?
] unit-test

{ t } [
    semver-gt-comparisons
    [ first2 swap version<=> ] zip-with
    values [ +lt+ = ] all?
] unit-test

