IN: cocoa.plists.tests
USING: tools.test cocoa.plists colors kernel hashtables
core-foundation.utilities core-foundation destructors
assocs cocoa.enumeration ;

[
    [ V{ } ] [ H{ } >cf &CFRelease [ ] NSFastEnumeration-map ] unit-test
    [ V{ "A" } ] [ { "A" } >cf &CFRelease plist> ] unit-test
    [ H{ { "A" "B" } } ] [ "B" "A" associate >cf &CFRelease plist> ] unit-test
] with-destructors