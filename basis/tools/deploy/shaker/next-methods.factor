USING: kernel words ;
IN: generic

: (call-next-method) ( method -- )
    dup "next-method" word-prop execute ;
