USING: editors kernel make namespaces ;
IN: editors.xcode

EDITOR: xcode

M: xcode editor-command
    drop
    [ "open" , "-a" , "XCode" , , ] { } make ;
