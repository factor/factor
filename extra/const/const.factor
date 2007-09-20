USING: kernel parser words sequences ;
IN: const

: define-const ( word value -- )
    [ parsed ] curry dupd define-compound
    t "parsing" set-word-prop ;

: CONST:
    CREATE scan-word dup parsing?
    [ execute dup pop ] when define-const ; parsing

: define-enum ( words -- )
    dup length [ define-const ] 2each ;

: ENUM:
    ";" parse-tokens [ create-in ] map define-enum ; parsing
