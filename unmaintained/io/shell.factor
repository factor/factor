USING: calendar io io-internals kernel math namespaces
nonblocking-io prettyprint quotations sequences ;
IN: shell

SYMBOL: shell
HOOK: directory* shell ( path -- seq )
HOOK: make-file shell ( bytes -- file )
HOOK: file. shell ( file -- )
HOOK: touch-file shell ( path -- )

: (ls) ( path -- )
    >r H{ } r> directory*
    [
        [ [ make-file file. ] with-row ] each
    ] curry tabular-output ;

: ls ( -- )
    cwd (ls) ;

: pwd ( -- )
    cwd pprint nl ;

: (slurp) ( quot -- )
    >r default-buffer-size read r> over [
        dup slip (slurp)
    ] [
        2drop
    ] if ;

: slurp ( stream quot -- )
    [ (slurp) ] curry with-stream ;

: cat ( path -- )
     <file-reader> stdio get
     duplex-stream-out <duplex-stream>
     [ write ] slurp ;

: copy-file ( path path -- )
    >r <file-reader> r>
    <file-writer> <duplex-stream> [ write ] slurp ;
