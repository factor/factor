! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: parser generic kernel classes words slots io definitions
sequences sequences.private assocs prettyprint.sections arrays ;
IN: delegate

: define-protocol ( wordlist protocol -- )
    swap { } like "protocol-words" set-word-prop ;

: PROTOCOL:
    CREATE dup reset-generic dup define-symbol
    parse-definition swap define-protocol ; parsing

PREDICATE: word protocol "protocol-words" word-prop ;

GENERIC: group-words ( group -- words )

M: protocol group-words
    "protocol-words" word-prop ;

M: generic group-words
    1array ;

M: tuple-class group-words
    "slots" word-prop 1 tail ! The first slot is the delegate
    ! 1 tail should be removed when the delegate slot is removed
    dup [ slot-spec-reader ] map
    swap [ slot-spec-writer ] map append ;

: spin ( x y z -- z y x )
    swap rot ;

: define-consult-method ( word class quot -- )
    pick add <method> spin define-method ;

: define-consult ( class group quot -- )
    >r group-words r>
    swapd [ define-consult-method ] 2curry each ;

: CONSULT:
    scan-word scan-word parse-definition swapd define-consult ; parsing

PROTOCOL: sequence-protocol
    clone clone-like like new new-resizable nth nth-unsafe
    set-nth set-nth-unsafe length immutable set-length lengthen ;

PROTOCOL: assoc-protocol
    at* assoc-size >alist assoc-find set-at
    delete-at clear-assoc new-assoc assoc-like ;

PROTOCOL: stream-protocol
    stream-close stream-read1 stream-read stream-read-until
    stream-flush stream-write1 stream-write stream-format
    stream-nl make-span-stream make-block-stream stream-readln
    make-cell-stream stream-write-table set-timeout ;

PROTOCOL: definition-protocol
    where set-where forget uses redefined*
    synopsis* definer definition ;

PROTOCOL: prettyprint-section-protocol
    section-fits? indent-section? unindent-first-line?
    newline-after?  short-section? short-section long-section
    <section> delegate>block add-section ;

: define-mimic ( group mimicker mimicked -- )
    >r >r group-words r> r> [
        pick "methods" word-prop at dup
        [ method-def <method> spin define-method ] [ 3drop ] if
    ] 2curry each ; 

: MIMIC:
    scan-word scan-word scan-word define-mimic ; parsing
