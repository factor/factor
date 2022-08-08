USING: editors kernel make namespaces ;
IN: editors.xcode

SINGLETON: xcode

editor-class [ xcode ] initialize

M: xcode editor-command
    drop
    [ "open" , "-a" , "XCode" , , ] { } make ;
