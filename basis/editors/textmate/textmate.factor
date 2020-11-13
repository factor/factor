USING: definitions io.launcher kernel math math.parser parser
namespaces prettyprint editors make ;
IN: editors.textmate

SINGLETON: textmate
textmate editor-class set-global

M: textmate editor-command
    [ "mate" , "-a" , "-l" , number>string , , ] { } make ;
