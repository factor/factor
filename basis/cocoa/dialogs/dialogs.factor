! Copyright (C) 2006, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: cocoa cocoa.application cocoa.classes
core-foundation.strings kernel splitting ;
IN: cocoa.dialogs

: <NSOpenPanel> ( -- panel )
    NSOpenPanel send: openPanel
    dup 1 send: \setCanChooseFiles:
    dup 0 send: \setCanChooseDirectories:
    dup 1 send: \setResolvesAliases:
    dup 1 send: \setAllowsMultipleSelection: ;

: <NSDirPanel> ( -- panel ) <NSOpenPanel>
   dup 1 send: \setCanChooseDirectories: ;

: <NSSavePanel> ( -- panel )
    NSSavePanel send: savePanel
    dup 1 send: \setCanChooseFiles:
    dup 0 send: \setCanChooseDirectories:
    dup 0 send: \setAllowsMultipleSelection: ;

CONSTANT: NSOKButton 1
CONSTANT: NSCancelButton 0

: (open-panel) ( panel -- paths )
    dup send: runModal NSOKButton =
    [ send: filenames CFString>string-array ] [ drop f ] if ;

: open-panel ( -- paths ) <NSOpenPanel> (open-panel) ;

: open-dir-panel ( -- paths ) <NSDirPanel> (open-panel) ;

: split-path ( path -- dir file )
    "/" split1-last [ "" or <NSString> ] bi@ ;

: save-panel ( path -- path/f )
    [ <NSSavePanel> dup ] dip
    split-path send: \runModalForDirectory:file: NSOKButton =
    [ send: filename CFString>string ] [ drop f ] if ;
