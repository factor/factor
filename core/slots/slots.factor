! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel kernel.private math namespaces
sequences strings words effects generic generic.standard
classes slots.private ;
IN: slots

TUPLE: slot-spec type name offset reader writer ;

C: <slot-spec> slot-spec

: define-typecheck ( class generic quot -- )
    <method> over define-simple-generic -rot define-method ;

: define-slot-word ( class slot word quot -- )
    rot >fixnum add* define-typecheck ;

: reader-effect ( class spec -- effect )
    >r ?word-name 1array r> slot-spec-name 1array <effect> ;

: reader-quot ( decl -- quot )
    [
        \ slot ,
        dup object bootstrap-word eq?
        [ drop ] [ 1array , \ declare , ] if
    ] [ ] make ;

PREDICATE: compound slot-reader
    "reading" word-prop >boolean ;

: set-reader-props ( class spec -- )
    2dup reader-effect
    over slot-spec-reader
    swap "declared-effect" set-word-prop
    slot-spec-reader swap "reading" set-word-prop ;

: define-reader ( class spec -- )
    dup slot-spec-reader [
        [ set-reader-props ] 2keep
        dup slot-spec-offset
        over slot-spec-reader
        rot slot-spec-type reader-quot
        define-slot-word
    ] [
        2drop
    ] if ;

: writer-effect ( class spec -- effect )
    slot-spec-name swap ?word-name 2array 0 <effect> ;

PREDICATE: compound slot-writer
    "writing" word-prop >boolean ;

: set-writer-props ( class spec -- )
    2dup writer-effect
    over slot-spec-writer
    swap "declared-effect" set-word-prop
    slot-spec-writer swap "writing" set-word-prop ;

: define-writer ( class spec -- )
    dup slot-spec-writer [
        [ set-writer-props ] 2keep
        dup slot-spec-offset
        swap slot-spec-writer
        [ set-slot ]
        define-slot-word
    ] [
        2drop
    ] if ;

: define-slot ( class spec -- )
    2dup define-reader define-writer ;

: define-slots ( class specs -- )
    [ define-slot ] curry* each ;

: reader-word ( class name vocab -- word )
    >r >r "-" r> 3append r> create ;

: writer-word ( class name vocab -- word )
    >r [ swap "set-" % % "-" % % ] "" make r> create ;

: (simple-slot-word) ( class name -- class name vocab )
    over word-vocabulary >r >r word-name r> r> ;

: simple-reader-word ( class name -- word )
    (simple-slot-word) reader-word ;

: simple-writer-word ( class name -- word )
    (simple-slot-word) writer-word ;

: simple-slot ( class name # -- spec )
    >r object bootstrap-word over r> f f <slot-spec>
    pick pick simple-reader-word over set-slot-spec-reader
    rot rot simple-writer-word over set-slot-spec-writer ;

: simple-slots ( class slots base -- specs )
    over length [ + ] curry* map
    [ >r >r dup r> r> simple-slot ] 2map nip ;

: slot-of-reader ( reader specs -- spec/f )
    [ slot-spec-reader eq? ] curry* find nip ;

: slot-of-writer ( writer specs -- spec/f )
    [ slot-spec-writer eq? ] curry* find nip ;
