! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generic
USING: arrays kernel kernel-internals math namespaces
sequences strings words errors ;

TUPLE: slot-spec decl name # reader writer ;

: define-typecheck ( class generic quot effect -- )
    pick swap "declared-effect" set-word-prop
    over define-simple-generic
    -rot define-method ;

: define-slot-word ( class slot word quot effect -- )
    >r rot >fixnum add* r> define-typecheck ;

: reader-effect ( class spec -- effect )
    >r word-name 1array r> slot-spec-name 1array <effect> ;

: reader-quot ( decl -- quot )
    [
        \ slot ,
        dup object eq? [ drop ] [ 1array , \ declare , ] if
    ] [ ] make ;

: save-reader ( class spec -- )
    slot-spec-reader swap "reading" set-word-prop ;

: define-reader ( class spec -- )
    dup slot-spec-reader [
        [ save-reader ] 2keep
        [
            dup slot-spec-#
            over slot-spec-reader
            rot slot-spec-decl reader-quot
        ] 2keep reader-effect define-slot-word
    ] [
        2drop
    ] if ;

: writer-effect ( class spec -- effect )
    slot-spec-name swap word-name 2array 0 <effect> ;

: save-writer ( class spec -- )
    slot-spec-writer swap "writing" set-word-prop ;

: define-writer ( class spec -- )
    dup slot-spec-writer [
        [ save-writer ] 2keep
        [
            dup slot-spec-#
            swap slot-spec-writer
            [ set-slot ]
        ] 2keep writer-effect define-slot-word
    ] [
        2drop
    ] if ;

: define-slot ( class spec -- )
    2dup define-reader define-writer ;

: define-slots ( class specs -- )
    [ define-slot ] each-with ;

: reader-word ( class name vocab -- word )
    >r >r "-" r> 3append r> create ;

: writer-word ( class name vocab -- word )
    >r [ swap "set-" % % "-" % % ] "" make r> create ;

: (simple-slot-word) ( class name -- class name vocab )
    over word-vocabulary >r >r word-name r> r> ;

: tuple-reader-word ( class name -- word )
    (simple-slot-word) reader-word ;

: tuple-writer-word ( class name -- word )
    (simple-slot-word) writer-word ;

: simple-slot ( class name # -- spec )
    >r object over r> f f <slot-spec>
    pick pick tuple-reader-word over set-slot-spec-reader
    rot rot tuple-writer-word over set-slot-spec-writer ;

: simple-slots ( class slots base -- specs )
    over length [ + ] map-with
    [ >r >r dup r> r> simple-slot ] 2map nip ;

: slot-of-reader ( reader class -- slotspec/f )
    "slots" word-prop [ slot-spec-reader eq? ] find-with nip
    [ "No such slot" throw ] unless* ;

: slot-of-writer ( writer class -- slotspec/f )
    "slots" word-prop [ slot-spec-writer eq? ] find-with nip
    [ "No such slot" throw ] unless* ;
