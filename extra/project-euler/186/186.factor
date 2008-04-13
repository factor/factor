USING: circular disjoint-set kernel math math.ranges
       sequences sequences.lib ;
IN: project-euler.186

: (generator) ( k -- n )
    dup sq 300007 * 200003 - * 100003 + 1000000 rem ;

: <generator> ( -- lag )
    55 [1,b] [ (generator) ] map <circular> ;

: advance ( lag -- )
    [ { 0 31 } nths sum 1000000 rem ] keep push-circular ;

: next ( lag -- n )
    [ first ] [ advance ] bi ;

: 2unless? ( x y ?quot quot -- )
    >r 2keep rot [ 2drop ] r> if ; inline

: (p186) ( generator counter unionfind -- counter )
    524287 over equiv-set-size 990000 <
    [
        pick [ next ] [ next ] bi
        [ = ] [
            pick equate
            [ 1+ ] dip
        ] 2unless? (p186)
    ] [
        drop nip
    ] if ;

: euler186 ( -- n )
    <generator> 0 1000000 <disjoint-set> (p186) ;

MAIN: euler186
