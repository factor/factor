USING: kernel generic syntax words parser assocs sequences ;
IN: visitor

: define-visitor ( word -- )
    dup dup reset-word define-simple-generic
    H{ } clone "visitors" set-word-prop ; 

: VISITOR:
    CREATE define-visitor ; parsing

: connect-method ( top-class generic method-word -- )
    [ swap ] swap add -rot define-method ;

: record-visitor ( top-class generic method-word -- )
    swap "visitors" word-prop swapd set-at ;

: new-vmethod ( method bottom-class top-class generic -- )
    gensym dup define-simple-generic
    3dup connect-method
    [ record-visitor ] keep
    define-method ;

: define-visitor-method ( method bottom-class top-class generic -- )
    >r >r >r \ swap add* r> r> r>
    2dup "visitors" word-prop at
    [ nip define-method ] [ new-vmethod ] ?if ;

: V:
    ! syntax: V: bottom-class top-class generic body... ;
    f set-word scan-word scan-word scan-word
    parse-definition -roll define-visitor-method ; parsing
