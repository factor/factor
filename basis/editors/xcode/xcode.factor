USING: definitions io.launcher kernel math math.parser parser
namespaces prettyprint editors make ;
IN: editors.xcode

SINGLETON: xcode
xcode editor-class set-global

M: xcode editor-command ( file line -- command )
    drop
    [ "open" , "-a" , "XCode" , , ] { } make ;
