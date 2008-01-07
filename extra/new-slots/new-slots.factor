! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: effects words kernel sequences slots slots.private
assocs parser mirrors ;
IN: new-slots

: reader-effect T{ effect f 1 1 } ; inline

: writer-effect T{ effect f 2 0 } ; inline

: create-accessor ( name effect -- word )
    >r "accessors" create dup r>
    "declared-effect" set-word-prop ;

: reader-word ( name -- word )
    ">>" append reader-effect create-accessor ;

: writer-word ( name -- word )
    ">>" swap append writer-effect create-accessor ;

: define-reader ( class slot name -- )
    reader-word [ slot ] define-slot-word ;

: define-writer ( class slot name -- )
    writer-word [ set-slot ] define-slot-word ;

: define-new-slots ( tuple-class -- )
    [ "slot-names" word-prop <enum> >alist ] keep
    [
        swap first2 >r 2 + r> 3dup define-reader define-writer
    ] curry each ;

: NEW-SLOTS: scan-word define-new-slots ; parsing
