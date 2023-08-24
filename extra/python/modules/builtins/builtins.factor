USING: python.syntax ;
IN: python.modules.builtins

PY-FROM: builtins =>
    callable ( obj -- ? )
    dir ( obj -- seq )
    int ( val -- s )
    len ( seq -- n )
    open ( name mode -- file )
    range ( n -- seq )
    repr ( obj -- str ) ;

PY-METHODS: obj =>
    __name__ ( self -- n )
    __str__ ( o -- str ) ;

PY-METHODS: file =>
    close ( self -- )
    fileno ( self -- n )
    tell ( self -- n ) ;

PY-METHODS: str =>
    lower ( self -- self' )
    partition ( self sep -- bef sep aft )
    startswith ( self str -- ? )
    title ( self -- self' )
    zfill ( self n -- str' ) ;

PY-METHODS: list =>
    append ( list obj -- )
    remove ( list obj -- ) ;
