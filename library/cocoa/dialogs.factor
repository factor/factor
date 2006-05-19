! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: cocoa
USING: kernel objc-NSObject objc-NSOpenPanel objc-NSSavePanel
sequences ;

: <NSOpenPanel> ( -- panel )
    NSOpenPanel [openPanel]
    dup 1 [setCanChooseFiles:]
    dup 0 [setCanChooseDirectories:]
    dup 1 [setResolvesAliases:]
    dup 1 [setAllowsMultipleSelection:] ;

: NSOKButton 1 ;
: NSCancelButton 0 ;

: open-panel ( -- paths )
    <NSOpenPanel> dup f [runModalForTypes:] NSOKButton =
    [ [filenames] CF>array [ CF>string ] map ] [ drop f ] if ;
