USING: mongodb.persistent ;

IN: mongodb



GENERIC: store ( tuple/ht -- tuple/ht )
GENERIC: load ( example -- tuple/ht )

M: tuple store ( tuple -- tuple )
    [ check-persistent-tuple ] keep ;

M: persistent-tuple store ( ptuple -- ptuple )
    ;

