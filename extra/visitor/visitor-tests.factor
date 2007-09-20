USING: visitor math sequences math.parser strings tools.test kernel ;

VISITOR: ++ ( object object -- object )
! acts like +, coercing string arguments to a number, unless both arguments are strings, in which case it appends them

V: number string ++
    string>number + ;
V: string number ++
    >r string>number r> + ;
V: number number ++
    + ;
V: string string ++
    append ;

[ 3 ] [ 1 2 ++ ] unit-test
[ 3 ] [ "1" 2 ++ ] unit-test
[ 3 ] [ 1 "2" ++ ] unit-test
[ "12" ] [ "1" "2" ++ ] unit-test
