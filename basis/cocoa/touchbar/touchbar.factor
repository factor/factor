! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types cocoa cocoa.classes cocoa.messages
cocoa.runtime combinators compiler.units core-foundation.strings
init kernel locals namespaces sequences ;
IN: cocoa.touchbar

: make-touchbar ( seq self -- touchbar )
    [ NSTouchBar -> alloc -> init dup ] dip -> setDelegate: {
        [ swap <CFStringArray> { void { id SEL id } } ?-> setDefaultItemIdentifiers: ]
        [ swap <CFStringArray> { void { id SEL id } } ?-> setCustomizationAllowedItemIdentifiers: ]
        [ nip ]
    } 2cleave ;

:: make-NSTouchBar-button ( self identifier label-string action-string -- button )
    NSCustomTouchBarItem -> alloc
        identifier <CFString> { id { id SEL id } } ?-> initWithIdentifier: :> item
        NSButton
            label-string <CFString>
            self
            action-string lookup-selector { id { id SEL id id SEL } } ?-> buttonWithTitle:target:action: :> button
        item button -> setView:
        item ;

! Temporary hack to support new touchbar API on old macOS build
! machines by attempting to re-import the objc-class which
! causes re-registering of the objc-methods which were not
! present on the macOS 10.11 build machine.  We use a flag
! to cause this delay only the first time the image is run
! and then saved.
<PRIVATE
SYMBOL: imported?
PRIVATE>
[
    imported? get-global [
        [
            {
                "NSCustomTouchBarItem"
                "NSTouchBar"
                "NSTouchBarItem"
            } [ [ ] import-objc-class ] each
        ] with-compilation-unit
        t imported? set-global
    ] unless
] "cocoa.touchbar" add-startup-hook
