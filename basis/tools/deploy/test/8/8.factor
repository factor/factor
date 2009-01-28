USING: kernel ;
IN: tools.deploy.test.8

: literal-merge-test-1 ( -- x ) H{ { "lil" "wayne" } } ;
: literal-merge-test-2 ( -- x ) H{ { "lil" "wayne" } } ;

: literal-merge-test ( -- )
    literal-merge-test-1
    literal-merge-test-2 eq? t assert= ;

MAIN: literal-merge-test
