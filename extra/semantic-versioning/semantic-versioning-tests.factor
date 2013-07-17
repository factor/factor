USING: math.order semantic-versioning tools.test ;
IN: semantic-versioning.tests

{
    {
        T{ version f 0 1 0 "" "" }
        T{ version f 0 97 0 "" "" }
        T{ version f 1 1 0 "" "" }
        T{ version f 1 2 3 "" "" }
        T{ version f 1 0 0 "dev1" "" }
        T{ version f 1 0 0 "rc1" "build" }
        T{ version f 1 0 0 "rc2" "" }
        T{ version f 1 0 0 "rc2" "123456" }
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
    } [ string>version ] map
] unit-test

{ +gt+ } [ "1.2.0dev1" "0.12.1dev2" version<=> ] unit-test
{ +lt+ } [ "1.9.0" "1.10.0" version<=> ] unit-test
{ +eq+ } [ "2.0.0rc1" "2.0.0rc1" version<=> ] unit-test
{ +lt+ } [ "1.0.0rc1" "1.0.0" version<=> ] unit-test
{ +lt+ } [ "1.0.0rc1" "1.0.0rc2" version<=> ] unit-test
{ +lt+ } [ "1.0.0-rc.1" "1.0.0-rc.11" version<=> ] unit-test
{ +lt+ } [ "1.0.0-rc.2" "1.0.0-rc.11" version<=> ] unit-test
{ +eq+ } [ "1.0.0+foo" "1.0.0+bar" version<=> ] unit-test

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
