! Copyright (C) 2005, 2006 Kevin Reid.
! See http://factorcode.org/license.txt for BSD license.
USING: cocoa compiler gadgets gadgets-browser gadgets-launchpad
gadgets-layouts gadgets-listener kernel memory objc
objc-FactorCallback objc-NSApplication objc-NSMenu
objc-NSMenuItem objc-NSObject objc-NSWindow sequences strings
words ;
IN: cocoa

! -------------------------------------------------------------------------

GENERIC: to-target-and-action ( spec -- target action )

M: f to-target-and-action f swap ;
M: string to-target-and-action sel_registerName f ;
M: word to-target-and-action unit to-target-and-action ;
M: quotation to-target-and-action
    <FactorCallback> "perform:" sel_registerName swap ;

: <NSMenu> ( title -- )
    NSMenu [alloc]
    swap <NSString> [initWithTitle:]
    [autorelease] ;

: set-main-menu ( menu -- ) NSApp swap [setMainMenu:] ;

: <NSMenuItem> ( title action equivalent -- item )
    >r >r >r
    NSMenuItem [alloc]
    r> <NSString>
    r> dup [ sel_registerName ] when
    r> <NSString>
    [initWithTitle:action:keyEquivalent:] [autorelease] ;

: make-menu-item ( title spec -- item )
    to-target-and-action >r swap <NSMenuItem> dup
    r> [setTarget:] ;

: submenu-to-item ( menu -- item )
    dup [title] CF>string f "" <NSMenuItem> dup
    rot [setSubmenu:] ;

: add-submenu ( menu submenu -- )
    submenu-to-item [addItem:] ;

: and-modifiers ( item key-equivalent-modifier-mask -- item )
    dupd [setKeyEquivalentModifierMask:] ;

: and-alternate ( item -- item )
    dup 1 [setAlternate:] ;

: and-option-equivalent-modifier 1572864 and-modifiers ;

! -------------------------------------------------------------------------

DEFER: described-menu

! { } => separator

! { { ... } } or
! { { ... } modify-quotation } => submenu as described in inner sequence

! { title action equivalent } or
! { title action equivalent modify-quotation } => item

! this is a mess
: described-item ( desc -- menu-item )
    dup length 0 = [
        drop NSMenuItem [separatorItem]
    ] [
        dup first string? [
            [ first3 swap make-menu-item ] keep
            dup length 4 = [ fourth call ] [ drop ] if
        ] [
            [ first described-menu ] keep
            dup length 2 = [ second call ] [ drop ] if
            submenu-to-item
        ] if
    ] if ;

: and-described-item ( menu desc -- same-menu )
    described-item dupd [addItem:] ;

: described-menu ( { title items* } -- menu )
    [ first <NSMenu> ] keep
    1 swap tail [ and-described-item ] each ;

: and-described-submenu ( menu { title items* } -- menu )
    described-menu dupd add-submenu ;

! -------------------------------------------------------------------------

: menu-run-file ( -- )
    open-panel [ listener-run-files ] when* ;

: default-main-menu 
    {
        "<top>"
        { {
            "Factor"
            ! About goes here
            ! Preferences goes here
            { {
                "Services"
            } [ NSApp over [setServicesMenu:] ] }
            { }
            { "Hide Factor" "hide:" "h" }
            { "Hide Others" "hideOtherApplications:" "h" [ and-option-equivalent-modifier ] }
            { "Show All" "unhideAllApplications:" "" }
            { }
            { "Quit" "terminate:" "q" }
        } [ NSApp over [setAppleMenu:] ] }
        { {
            "File"
            { "New Listener" listener-window "n" }
            { "New Browser" browser-window "b" }
            { }
            { "Run..." menu-run-file "o" }
            { }
            { "Apropos" apropos-window "r" }
            { "Globals" globals-window "" }
            { "Memory" memory-window "" }
            { }
            { "Save Image" save "s" }
        } }
        { {
            "Edit"
            { "Undo" "undo:" "z" }
            { "Redo" "redo:" "Z" }
            { }
            { "Cut" "cut:" "x" }
            { "Copy" "copy:" "c" }
            { "Paste" "paste:" "v" }
            { "Paste and Match Style" "pasteAsPlainText:" "V" [ and-option-equivalent-modifier ] }
            { "Delete" "delete:" "" }
            { "Select All" "selectAll:" "a" }
            ! Find, Spelling, and Speech submenus go here
        } }
        { {
            "Window"
            { "Close" "performClose:" "w" }
            { "Zoom" "performZoom:" "" }
            { "Minimize" "performMiniaturize:" "m" }
            { "Minimize All" "miniaturizeAll:" "m"  [ and-alternate and-option-equivalent-modifier ] }
            { }
            { "Bring All to Front" "arrangeInFront:" "" }
        } [ NSApp over [setWindowsMenu:] ] }
        { {
            "Help"
            { "Factor Documentation" handbook-window "?" }
            { "Help Index" articles-window "" }
        } }
    } described-menu set-main-menu ;
