! Copyright (C) 2006, 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel cocoa cocoa.messages cocoa.classes
cocoa.application sequences splitting core-foundation ;
IN: cocoa.dialogs

: <NSOpenPanel> ( -- panel )
    NSOpenPanel -> openPanel
    dup 1 -> setCanChooseFiles:
    dup 0 -> setCanChooseDirectories:
    dup 1 -> setResolvesAliases:
    dup 1 -> setAllowsMultipleSelection: ;

: <NSSavePanel> ( -- panel )
    NSSavePanel -> savePanel
    dup 1 -> setCanChooseFiles:
    dup 0 -> setCanChooseDirectories:
    dup 0 -> setAllowsMultipleSelection: ;

: NSOKButton 1 ;
: NSCancelButton 0 ;

: open-panel ( -- paths )
    <NSOpenPanel>
    dup -> runModal NSOKButton =
    [ -> filenames CF>string-array ] [ drop f ] if ;

: split-path ( path -- dir file )
    "/" last-split1 [ <NSString> ] 2apply ;

: save-panel ( path -- paths )
    <NSSavePanel> dup
    rot split-path -> runModalForDirectory:file: NSOKButton =
    [ -> filename CF>string ] [ drop f ] if ;
