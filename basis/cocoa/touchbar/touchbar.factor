! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types cocoa cocoa.classes cocoa.messages
cocoa.runtime combinators core-foundation.strings kernel locals
;
IN: cocoa.touchbar

: make-touchbar ( seq self -- touchbar )
    [ NSTouchBar -> alloc -> init dup ] dip -> setDelegate: {
        [ swap <CFStringArray> -> setDefaultItemIdentifiers: ]
        [ swap <CFStringArray> -> setCustomizationAllowedItemIdentifiers: ]
        [ nip ]
    } 2cleave ;

:: make-NSTouchBar-button ( self identifier label-string action-string -- button )
    NSCustomTouchBarItem -> alloc
        identifier <CFString> -> initWithIdentifier: :> item
        NSButton
            label-string <CFString>
            self
            action-string lookup-selector -> buttonWithTitle:target:action: :> button
        item button -> setView:
        item ;
