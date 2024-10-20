USING: kernel parser sequences vectors words lexer quotations combinators generalizations  ;
IN: combinators.syntax


: | ( -- ) ; delimiter
<PRIVATE
! unlike normal parse-until, this also pushes the thing that matched the predicate into the accumulator as well 
: (parse-until-pred) ( acc end-pred -- ... seq ) [
        ?scan-datum {
            { [ [ swap call ] 2keep rot ] [ pick push drop f ] }
            { [ dup not ] [ drop throw-unexpected-eof ] }
            { [ dup delimiter? ] [ unexpected ] }
            { [ dup parsing-word? ] [ nip execute-parsing t ] }
            [ pick push drop t ]
        } cond
    ] curry loop ; inline

: parse-until-pred ( end-pred -- seq ) 100 <vector> swap (parse-until-pred) ; inline

: (parse-cleave-like) ( acc -- acc continue? ) [ [ \ | eq? ] [ \ ] eq? ] bi or ] parse-until-pred unclip-last [ >quotation suffix! ] dip \ | eq? ;

: parse-cleave-quotations ( -- quotations ) 100 <vector> [ (parse-cleave-like) ] loop  ;

: parse-cleave-like ( acc word -- acc ) parse-cleave-quotations swap [ suffix! ] bi@ ;

! couldn't think of a better name. napply, nspread, ncleave ect. are all macros that take in numbers as the top parameter on the stack, meaning that you have to do a bit of shuffling around before they work
: parse-number-macro-input ( acc word parser-quot -- acc  ) [ unclip-last ] [ 1quotation ] [ call( -- quot ) ] tri* -rot 2curry append! ;

: 2parse-number-macro-input ( acc word parser-quot -- acc  ) [ 2 cut* ] 2dip [ suffix! >quotation ] dip call( -- quot ) swap curry append! ;

: parse-ncleave-like ( acc word  -- acc ) [ parse-cleave-quotations ] parse-number-macro-input  ;

: parse-apply ( acc -- acc ) \ napply [ \ ] parse-until >quotation ] parse-number-macro-input ;

: parse-mnapply ( acc -- acc ) \ mnapply [ \ ] parse-until >quotation ] 2parse-number-macro-input ;

PRIVATE>

SYNTAX: &[ \ cleave parse-cleave-like ;

SYNTAX: *[ \ spread parse-cleave-like ;

SYNTAX: n&[ \ ncleave parse-ncleave-like ;

SYNTAX: n*[ \ nspread parse-ncleave-like ;

SYNTAX: @[ parse-apply ;

SYNTAX: n@[ parse-mnapply ;

