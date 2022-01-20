USING: editors kernel make namespaces ;
IN: editors.xcode

SINGLETON: xcode
xcode editor-class set-global

M: xcode editor-command
    drop
    [ "open" , "-a" , "XCode" , , ] { } make ;
