! Copyright (C) 2006 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
IN: cocoa
USING: kernel objc objc-classes sequences ;

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

: run-panel ( panel -- paths ) ;

: open-panel ( -- paths )
    <NSOpenPanel>
    dup -> runModal NSOKButton =
    [ -> filenames CF>string-array ] [ drop f ] if ;

: split-path ( path -- dir file )
    <reversed> "/" split1 [ reverse <NSString> ] 2apply swap ;

: save-panel ( path -- paths )
    <NSSavePanel> dup
    rot split-path -> runModalForDirectory:file: NSOKButton =
    [ -> filename CF>string ] [ drop f ] if ;
