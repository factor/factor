USING: kernel sequences system ;
IN: tools.test.unix

: test-shell ( -- path )
    os android? [ "/system/bin/sh" ] [ "/bin/sh" ] if ;

: test-script ( body -- script )
    test-shell "#!" prepend "\n" append swap append ;
