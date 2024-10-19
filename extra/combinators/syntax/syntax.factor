USING: kernel parser sequences vectors words lexer quotations combinators ;
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

: parse-cleave-like ( word acc -- acc ) 100 <vector> [ (parse-cleave-like) ] loop swap [ suffix! ] bi@ ;
PRIVATE>

SYNTAX: &[ \ cleave parse-cleave-like ;

SYNTAX: *[ \ spread parse-cleave-like ;

