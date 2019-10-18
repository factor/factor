! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: kernel cocoa cocoa.messages cocoa.classes
cocoa.application sequences splitting core-foundation
core-foundation.strings ;
IN: cocoa.dialogs

: <NSOpenPanel> ( -- panel )
    NSOpenPanel -> openPanel
    dup 1 -> setCanChooseFiles:
    dup 0 -> setCanChooseDirectories:
    dup 1 -> setResolvesAliases:
    dup 1 -> setAllowsMultipleSelection: ;

: <NSDirPanel> ( -- panel ) <NSOpenPanel>
   dup 1 -> setCanChooseDirectories: ;

: <NSSavePanel> ( -- panel )
    NSSavePanel -> savePanel
    dup 1 -> setCanChooseFiles:
    dup 0 -> setCanChooseDirectories:
    dup 0 -> setAllowsMultipleSelection: ;

CONSTANT: NSOKButton 1
CONSTANT: NSCancelButton 0

: (open-panel) ( panel -- paths )
    dup -> runModal NSOKButton =
    [ -> filenames CF>string-array ] [ drop f ] if ;
    
: open-panel ( -- paths ) <NSOpenPanel> (open-panel) ;
: open-dir-panel ( -- paths ) <NSDirPanel> (open-panel) ;

: split-path ( path -- dir file )
    "/" split1-last [ <NSString> ] bi@ ;

: save-panel ( path -- paths )
    [ <NSSavePanel> dup ] dip
    split-path -> runModalForDirectory:file: NSOKButton =
    [ -> filename CF>string ] [ drop f ] if ;
