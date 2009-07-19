! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces assocs kernel compiler.cfg.dcn.global ;
IN: compiler.cfg.dcn.rewrite

: inserting-peeks ( from to -- seq )
    peek-in swap [ peek-out ] [ avail-out ] bi assoc-union assoc-diff keys ;

: inserting-replaces ( from to -- seq )
    [ replace-out ] [ kill-in ] bi* assoc-diff keys ;