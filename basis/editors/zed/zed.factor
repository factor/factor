USING: editors kernel make namespaces ;
IN: editors.zed

SINGLETON: zed

M: zed editor-command
    drop
    [ "open" , "-a" , "Zed" , , ] { } make ;
