USING: editors kernel make namespaces ;
IN: editors.xcode

SINGLETON: xcode

M: xcode editor-command
    drop
    [ "open" , "-a" , "XCode" , , ] { } make ;
