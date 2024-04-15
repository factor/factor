! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays cocoa cocoa.application
cocoa.classes cocoa.messages cocoa.runtime cocoa.subclassing
compiler.units kernel locals.backend math.parser quotations
sequences ;
IN: cocoa.statusbar

<< {
    "NSStatusBar"
    "NSStatusItem"
} [
    [ ] import-objc-class
] each
>>

CONSTANT: NSVariableStatusItemLength -1.0
CONSTANT: NSSquareStatusItemLength -2.0

: get-system-statusbar ( -- alien )
    NSStatusBar -> systemStatusBar ;

TUPLE: platform-menu name items menu-alien statusbar-alien ;
TUPLE: platform-menu-item title { quot callable } key-equivalent selector target ;

: <platform-menu> ( name items -- platform-menu )
    platform-menu new
        swap >>items
        swap >>name ;

: <platform-menu-item> ( title quot -- platform-menu-item )
    platform-menu-item new
        swap >>quot
        swap >>title ;

: menu>dummy-class ( menu -- object )
    [ name>> "NSObject" V{ } ]
    [
        items>> [
            swap
            [
                [ number>string "dummy" prepend void { id SEL } ]
                [ quot>> [ 2 load-locals 2 drop-locals ] prepose ] bi* 4array
            ] keep over first >>selector drop
        ] map-index
        [ define-objc-class ] with-compilation-unit
    ] [
        name>> objc_getClass -> alloc -> init
    ] tri ;

: >NSMenuItem ( menu-item -- NSMenuItem )
    [ NSMenuItem -> alloc ] dip
    [ title>> <NSString> ]
    [ selector>> <selector> cocoa.messages:selector ]
    [ key-equivalent>> "" or <NSString> ] tri
    -> initWithTitle:action:keyEquivalent: ;

:: menu>alien ( menu -- menu-alien )
    NSMenu -> alloc -> init :> ns-menu
    menu menu>dummy-class :> dummy-class
    ! NSMenu objc-dummy menu
    menu items>> [
        >NSMenuItem [ dummy-class -> setTarget: ] keep
    ] map :> ns-menu-items
    ns-menu ns-menu-items [ -> addItem: ] with each
    ns-menu ;

:: show-menu* ( platform-menu -- menu-alien statusbar-alien )
    platform-menu menu>alien :> menu-alien
    get-system-statusbar :> system-alien
    system-alien
        NSVariableStatusItemLength -> statusItemWithLength: [ -> retain ] keep :> ns-status-item
    ns-status-item platform-menu name>> <NSString> -> setTitle:
    menu-alien -> setMenu:
    menu-alien ns-status-item ;

: show-statusbar ( platform-menu -- platform-menu )
    [ show-menu* ] keep
    [ statusbar-alien<< ] keep
    [ menu-alien<< ] keep ;

: enable-menu-item ( alien -- ) 1 -> setEnabled: ;
: disable-menu-item ( alien -- ) 0 -> setEnabled: ;

: hide-statusbar-item ( statusbar-item-alien -- )
    [ get-system-statusbar ] dip -> removeStatusItem: ;

: hide-statusbar* ( platform-menu -- )
    [ get-system-statusbar ] dip -> removeStatusItem: ;

: hide-statusbar ( platform-menu -- platform-menu )
    [ statusbar-alien>> hide-statusbar* ] keep ;
