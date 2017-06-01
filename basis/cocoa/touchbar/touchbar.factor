! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.enums alien.syntax cocoa
cocoa.classes cocoa.messages cocoa.runtime combinators
core-foundation.strings kernel locals namespaces sequences words ;
IN: cocoa.touchbar

! ui.backend.cocoa.views creates buttons for each of these actions
ENUM: default-touchbar refresh-all-action auto-use-action ;

: enum>CFStringArray ( seq -- alien )
    enum>keys
    NSArray -> alloc
        swap <CFStringArray> -> initWithArray: ;

: make-touchbar ( enum self -- touchbar )
    [ NSTouchBar -> alloc -> init dup ] dip -> setDelegate: {
        [ swap enum>CFStringArray { void { id SEL id } } ?-> setDefaultItemIdentifiers: ]
        [ swap enum>CFStringArray { void { id SEL id } } ?-> setCustomizationAllowedItemIdentifiers: ]
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
