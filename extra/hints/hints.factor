IN: hints
USING: parser words ;

: HINTS: 
    scan-word parse-definition "specializer" set-word-prop ;
    parsing
