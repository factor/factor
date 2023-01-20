! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math sequences ;
IN: sequences.inserters

TUPLE: offset-growable { underlying read-only } { offset read-only } ;
C: <offset-growable> offset-growable
INSTANCE: offset-growable virtual-sequence
M: offset-growable length
    [ underlying>> length ] [ offset>> ] bi - ; inline
M: offset-growable virtual-exemplar
    underlying>> ; inline
M: offset-growable virtual@
    [ offset>> + ] [ underlying>> ] bi ; inline
M: offset-growable set-length
    [ offset>> + ] [ underlying>> ] bi set-length ; inline

MIXIN: inserter
M: inserter like
    nip underlying>> ; inline
M: inserter new-resizable
    [ drop 0 ] dip new-sequence ; inline
M: inserter length
    drop 0 ; inline

TUPLE: appender { underlying read-only } ;
C: <appender> appender

INSTANCE: appender inserter

M:: appender new-sequence ( len inserter -- sequence )
    inserter underlying>> :> underlying
    underlying length :> old-length
    old-length len + :> new-length
    new-length underlying set-length
    underlying old-length <offset-growable> ; inline

TUPLE: replacer { underlying read-only } ;
C: <replacer> replacer

INSTANCE: replacer inserter

M: replacer new-sequence
    underlying>> [ set-length ] keep ; inline
