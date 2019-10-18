USING: arrays lazy-lists io strings sequences math namespaces
kernel ;
IN: lambda

: lambda-core ( -- expr-string-array )
    {
        ":0 (one.(zero.zero))"
        ":SUCC (num.(one.(zero.(one((num one) zero)))))"
    }
    
    0 lfrom 100 swap ltake list>array
    [ 
        [ ":" , dup 1 + number>string , " (SUCC " , number>string ,
        ")" , ] { } make concat
    ] map append
    
    0 lfrom 26 swap ltake list>array
    [
        [ ":" , 65 + dup 1string , " " , number>string , ] { } make concat
    ] map append
    
    {
        ":LF 10"
        ":FALSE (t.(f.f))"
        ":TRUE (t.(f.t))"
        ":AND (p.(q.((p q) FALSE)))"
        ":OR (p.(q.((p TRUE) q)))"
        ":ISZERO (num.((num (pred. FALSE)) TRUE))"
        ":ADD (num.(other.((num SUCC) other)))"
        ":MULT (num.(other.((num (ADD other)) 0)))"
        ":PRED (n.(f.(x.(((n (g.(h.(h(g f))))) (u. x)) (u.u)))))"
        ":SUBFROM (num.(other.((num PRED) other)))"
        ":EQUAL (num.(other.((AND (ISZERO ((SUBFROM num) other))) (ISZERO ((SUBFROM other) num)))))"
        ":FACT (fact.(num.(((ISZERO num) 1) ((MULT num) (fact (PRED num))))))"
        ":YCOMBINATOR (func.((y. (func (y y)))(y. (func (y y)))))"
        ":FACTORIAL (YCOMBINATOR FACT)"
        ":CONS (car.(cdr.(which.((which car) cdr))))"
        ":CAR (cons.(cons TRUE))"
        ":CDR (cons.(cons FALSE))"
        ":PCONS (pcons.(num.(cons.(((ISZERO num) (PRINTSPECIAL LF)) ((PRINTCHAR (CAR cons)) ((pcons (PRED num)) (CDR cons)))))))"
        ":PRINTCONS (YCOMBINATOR PCONS)"
        ":NUMTOCHAR (num. ((ADD 48) num))"
        ":PRINTNUM (num.(PRINTCHAR (NUMTOCHAR num)))"
        ":PRINTCHAR (char.([PRINTCHAR] (ALIENNUM char)))"
        ":PRINTSPECIAL (special.([PRINTCHAR] (ALIENNUM special)))"
        ":ALIEN0 alienbaseonenum"
        ":ALIENNUM (num.((num [ALIENSUCC]) ALIEN0))"
        ":HELLOCONS ((CONS H) ((CONS E) ((CONS Y) ((CONS 0) nil))))"
        ":HELLO ((PRINTCONS 3) HELLOCONS)"
        "(([HELLO] nil) ([INFO] nil))"
    } append ;

: print-return ( -- node )
    write "(nil.nil)" lambda-parse second ;
    
: HELLO ( node -- node )
    drop "\nHello and Welcome to Lambda!\n" print-return ;

: INFO ( node -- node )
    drop "Type HELLO and wait 10 seconds to see me flex my io muscles.\n" print-return ;

: ALIENSUCC ( node -- node )
    var-node-name "a" append <var-node> ;

: ALIENPRED ( node -- node )
    var-node-name 1 tail <var-node> ;

: ALIENISZERO ( node -- node )
    ;

: PRINTCHAR ( node -- node )
    #! takes a base one num and prints its char equivalent
    var-node-name length "alienbaseonenum" length - 1string print-return ;

: READCHAR ( node -- node )
    #! reads one character of input and stores it as a base one num
    "alienbaseonenum" read1 "a" <array> >string <var-node> ;

    