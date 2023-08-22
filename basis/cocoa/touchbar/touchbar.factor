! Copyright (C) 2017 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types cocoa cocoa.classes cocoa.messages
cocoa.runtime combinators core-foundation.strings kernel ;
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
