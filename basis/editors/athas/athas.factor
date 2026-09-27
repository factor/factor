USING: editors io.standard-paths kernel make math.order math.parser
namespaces sequences ;
IN: editors.athas

SINGLETON: athas

: athas-path ( -- path )
    \ athas-path get [ "athas" ?find-in-path ] unless* ;

M: athas editor-command
    [ athas-path , 1 max number>string ":" glue , ] { } make ;
