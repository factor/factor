USING: accessors classes classes.mixin classes.tuple compiler.units
fry kernel words locals mirrors formatting assocs hashtables ;

IN: mongodb.persistent

MIXIN: persistent-tuple

SLOT: _p_oid
SLOT: _p_info

TUPLE: oid { a initial: 0 } { b initial: 0 } ;

: MDB_CLASS ( -- string ) "p_class" ; inline
: MDB_VOCAB ( -- string ) "p_vocab" ; inline
: MDB_MT ( -- string ) "p_mt" ; inline
: MDB_CT ( -- string ) "p_ct" ; inline
: MDB_COL ( -- string ) "p_col" ; inline 

PREDICATE: pinfo-hashtable < hashtable  [ MDB_CLASS swap key? ] [ MDB_VOCAB swap key? ] bi and ;

: P_OID ( -- name ) "_p_oid" ; inline
: P_INFO ( -- name ) "_p_info" ; inline

: P_SLOTS ( -- array )
    { "_p_oid" "_p_info" } ;

<PRIVATE

: P_VOCAB ( -- string )
    "mongodb.persistent" ; inline

:: define-persistent-tuple ( superclass name -- class )
    [let | pclass [ name P_VOCAB create ] |
        [ pclass pclass [  ] curry define ] with-compilation-unit
        [ pclass superclass P_SLOTS define-tuple-class
          pclass persistent-tuple add-mixin-instance ] with-compilation-unit
        pclass ] ; 
    
:: copy-slots ( tuple 'tuple -- 'tuple )
    [let | tm1 [ tuple <mirror> ]
           tm2 [ 'tuple <mirror> ] |
        tm1 [ swap tm2 set-at ] assoc-each
        tm2 object>> ] ;
    
PRIVATE>

GENERIC: persistent-tuple-class ( tuple -- class )

M: tuple persistent-tuple-class ( tuple -- class )
    class persistent-tuple-class ;

M: pinfo-hashtable persistent-tuple-class ( tuple -- class )
    [ MDB_CLASS swap at ] [ MDB_VOCAB swap at ] bi lookup
    persistent-tuple-class ;

M: tuple-class persistent-tuple-class ( class -- class' )
    [ [ vocabulary>> ] [ name>> ] bi ] keep ! name vocab class
    [ "%s_%s" sprintf ] dip swap dup   ! class new_name new_name
    P_VOCAB lookup dup                 ! class new_name vo/f vo/f
    [ [ drop drop ] dip ] [ drop define-persistent-tuple ] if ;


GENERIC: make-persistent ( tuple -- 'tuple )

M: tuple make-persistent ( tuple -- 'tuple )
    [let* | tuple [  ]
            tclass [ tuple class ]
            'tuple [ tclass persistent-tuple-class new ]
            pinfo  [ H{  } clone ] |
        tuple 'tuple copy-slots
        oid new >>_p_oid
        tclass name>> MDB_CLASS pinfo set-at
        tclass vocabulary>> MDB_VOCAB pinfo set-at
        0 MDB_MT pinfo set-at
        0 MDB_CT pinfo set-at
        "" MDB_COL pinfo set-at
         pinfo >>_p_info
    ] ; 

M: persistent-tuple make-persistent ( tuple -- tuple )
    ;
