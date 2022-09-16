USING: classes kernel parser words ;
IN: classes.parser

: create-class ( string vocab -- word )
    create-word dup t "defining-class" set-word-prop
    dup set-last-word
    dup create-predicate-word drop ;
