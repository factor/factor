! (c) 2009 Joe Groff bsd license
USING: combinators combinators.short-circuit generalizations
kernel macros math math.ranges prettyprint.custom quotations
sequences words ;
IN: prettyprint.callables

<PRIVATE

CONSTANT: simple-combinators { dip call curry 2curry 3curry compose prepose }

: literal? ( obj -- ? ) word? not ;

MACRO: slice-match? ( quots -- quot: ( seq end -- ? ) )
    dup length
    [ 0 [a,b) [ [ - swap nth ] swap prefix prepend ] 2map ]
    [ nip \ nip swap \ >= [ ] 3sequence ] 2bi
    prefix \ 2&& [ ] 2sequence ;

: end-len>from-to ( seq end len -- from to seq )
    [ - ] [ drop 1 + ] 2bi rot ;

: slice-change ( seq end len quot -- seq' )
    [ end-len>from-to ] dip
    [ [ subseq ] dip call ] curry
    [ replace-slice ] 3bi ; inline

: when-slice-match ( seq i criteria quot -- seq' )
    [ [ 2dup ] dip slice-match? ] dip [ drop ] if ; inline
    
: simplify-dip ( quot i -- quot' )
    { [ literal? ] [ callable? ] }
    [ 2 [ first2 swap suffix ] slice-change ] when-slice-match ;

: simplify-call ( quot i -- quot' )
    { [ callable? ] }
    [ 1 [ first ] slice-change ] when-slice-match ;

: simplify-curry ( quot i -- quot' )
    { [ literal? ] [ callable? ] }
    [ 2 [ first2 swap prefix 1quotation ] slice-change ] when-slice-match ;

: simplify-2curry ( quot i -- quot' )
    { [ literal? ] [ literal? ] [ callable? ] }
    [ 3 [ [ 2 head ] [ third ] bi append 1quotation ] slice-change ] when-slice-match ;

: simplify-3curry ( quot i -- quot' )
    { [ literal? ] [ literal? ] [ literal? ] [ callable? ] }
    [ 4 [ [ 3 head ] [ fourth ] bi append 1quotation ] slice-change ] when-slice-match ;

: simplify-compose ( quot i -- quot' )
    { [ callable? ] [ callable? ] }
    [ 2 [ first2 append 1quotation ] slice-change ] when-slice-match ;

: simplify-prepose ( quot i -- quot' )
    { [ callable? ] [ callable? ] }
    [ 2 [ first2 swap append 1quotation ] slice-change ] when-slice-match ;

: (simplify-callable) ( quot -- quot' )
    dup [ simple-combinators member? ] find {
        { \ dip     [ simplify-dip     ] }
        { \ call    [ simplify-call    ] }
        { \ curry   [ simplify-curry   ] }
        { \ 2curry  [ simplify-2curry  ] }
        { \ 3curry  [ simplify-3curry  ] }
        { \ compose [ simplify-compose ] }
        { \ prepose [ simplify-prepose ] }
        [ 2drop ]
    } case ;

PRIVATE>

: simplify-callable ( quot -- quot' )
    [ (simplify-callable) ] to-fixed-point ;

M: callable >pprint-sequence simplify-callable ;
