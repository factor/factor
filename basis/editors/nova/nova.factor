USING: editors kernel make math.parser namespaces sequences ;
IN: editors.nova

SINGLETON: nova

: nova-path ( -- path )
    \ nova-path get [ "/usr/local/bin/nova" ] unless* ;

M: nova editor-command
    swap [
        nova-path , "open" , , "--line" , number>string ":1" append ,
    ] { } make ;
