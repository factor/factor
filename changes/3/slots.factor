USING: accessors kernel sequences words ;
IN: slots

: reader-word ( name -- word )
    [ ">>" append "accessors" create-word ]
    [ " (accessor)" append >>name ] bi
    dup t "reader" set-word-prop ;

: writer-word ( name -- word )
    [ "<<" append "accessors" create-word ]
    [ " (writer)" append >>name ] bi
    dup t "writer" set-word-prop ;

: setter-word ( name -- word )
    [ ">>" prepend "accessors" create-word ]
    [ " (mutator)" append >>name ] bi ;

: changer-word ( name -- word )
    [ "change-" prepend "accessors" create-word ]
    [ "change " prepend >>name ] bi ;
