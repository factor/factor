! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types cocoa cocoa.classes cocoa.messages
cocoa.runtime combinators core-foundation.strings kernel locals
;
IN: cocoa.touchbar

: make-touchbar ( seq self -- touchbar )
    [ NSTouchBar send: alloc send: init dup ] dip send: setDelegate: {
        [ swap <CFStringArray> send: \setDefaultItemIdentifiers: ]
        [ swap <CFStringArray> send: \setCustomizationAllowedItemIdentifiers: ]
        [ nip ]
    } 2cleave ;

:: make-NSTouchBar-button ( self identifier label-string action-string -- button )
    NSCustomTouchBarItem send: alloc
        identifier <CFString> send: \initWithIdentifier: :> item
        NSButton
            label-string <CFString>
            self
            action-string lookup-selector send: \buttonWithTitle:target:action: :> button
        item button send: \setView:
        item ;
