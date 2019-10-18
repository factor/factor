! Namespace tests.

"Namespace tests." print

<namespace> @test-namespace

: test-namespace ( -- )
    <namespace> dup [ namespace = ] bind ;

: test-this-1 ( -- )
    <namespace> dup [ this = ] bind ;

: test-this-2 ( -- )
    interpreter dup [ this = ] bind ;

[ t ] [   ] [ test-namespace ] test-word
[ t ] [   ] [ test-this-1    ] test-word
[ t ] [   ] [ test-this-2    ] test-word

! These stress-test a lot of code.
global describe
$dict describe

"Namespace tests passed." print
