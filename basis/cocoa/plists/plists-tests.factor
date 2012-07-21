USING: tools.test cocoa.plists colors kernel hashtables
core-foundation.utilities core-foundation destructors
assocs cocoa.enumeration ;
IN: cocoa.plists.tests

[
    [ V{ } ] [ H{ } >cf &CFRelease [ ] NSFastEnumeration-map ] unit-test
    [ V{ "A" } ] [ { "A" } >cf &CFRelease plist> ] unit-test
    [ H{ { "A" "B" } } ] [ "B" "A" associate >cf &CFRelease plist> ] unit-test
    [ H{ { "A" "B" } } ] [ "B" "A" associate >cf &CFRelease plist> ] unit-test

    [ t ] [
        {
            H{ { "DeviceUsagePage" 1 } { "DeviceUsage" 4 } }
            H{ { "DeviceUsagePage" 1 } { "DeviceUsage" 5 } }
            H{ { "DeviceUsagePage" 1 } { "DeviceUsage" 6 } }
        } [ >cf &CFRelease ] [ >cf &CFRelease ] bi
        [ plist> ] same?
    ] unit-test

    [ t ] [
        { "DeviceUsagePage" 1 }
        [ >cf &CFRelease ] [ >cf &CFRelease ] bi
        [ plist> ] same?
    ] unit-test

    [ V{ "DeviceUsagePage" "Yes" } ] [
        { "DeviceUsagePage" "Yes" }
        >cf &CFRelease plist>
    ] unit-test

    [ V{ 2.0 1.0 } ] [
        { 2.0 1.0 }
        >cf &CFRelease plist>
    ] unit-test

    [ 3.5 ] [
        3.5 >cf &CFRelease plist>
    ] unit-test
] with-destructors
