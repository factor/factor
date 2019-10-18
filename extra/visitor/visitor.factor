USING: kernel generic.standard syntax words parser assocs
generic quotations sequences effects arrays classes definitions
prettyprint sorting prettyprint.backend shuffle ;
IN: visitor

: define-visitor ( word -- )
    dup dup reset-word define-simple-generic
    dup H{ } clone "visitor-methods" set-word-prop
    H{ } clone "visitors" set-word-prop ; 

: VISITOR:
    CREATE define-visitor ; parsing

: record-visitor ( top-class generic method-word -- )
    swap "visitors" word-prop swapd set-at ;

: define-1generic ( word -- )
    1 <standard-combination> define-generic ;

: copy-effect ( from to -- )
    swap stack-effect "declared-effect" set-word-prop ;

: new-vmethod ( method bottom-class top-class generic -- )
    gensym dup define-1generic
    2dup copy-effect
    3dup 1quotation -rot define-method
    [ record-visitor ] keep
    define-method ;

: define-visitor-method ( method bottom-class top-class generic -- )
    4dup >r 2array r> "visitor-methods" word-prop set-at
    2dup "visitors" word-prop at
    [ nip define-method ] [ new-vmethod ] ?if ;

: V:
    ! syntax: V: bottom-class top-class generic body... ;
    f set-word scan-word scan-word scan-word
    parse-definition -roll define-visitor-method ; parsing

! see instance:
! see must be redone because "methods" doesn't show methods

PREDICATE: standard-generic visitor "visitors" word-prop ;
PREDICATE: array triple length 3 = ;
PREDICATE: triple visitor-spec
    first3 visitor? >r [ class? ] 2apply and r> and ;

M: visitor-spec definer drop \ V: \ ; ;
M: visitor definer drop \ VISITOR: f ;

M: visitor-spec synopsis*
    ! same as method-spec#synopsis*
    dup definer drop pprint-word
    [ pprint-word ] each ;

M: visitor-spec definition
    first3 >r 2array r> "visitor-methods" word-prop at ;

M: visitor see
    dup (see)
    dup see-class
    dup "visitor-methods" word-prop keys natural-sort swap
    [ >r first2 r> 3array ] curry map see-all ;
