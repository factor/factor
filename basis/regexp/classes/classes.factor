! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.order words combinators locals
ascii unicode.categories combinators.short-circuit sequences
fry macros arrays assocs sets classes ;
IN: regexp.classes

SINGLETONS: any-char any-char-no-nl
letter-class LETTER-class Letter-class digit-class
alpha-class non-newline-blank-class
ascii-class punctuation-class java-printable-class blank-class
control-character-class hex-digit-class java-blank-class c-identifier-class
unmatchable-class terminator-class word-boundary-class ;

SINGLETONS: beginning-of-input ^ end-of-input $ end-of-file ;

TUPLE: range from to ;
C: <range> range

GENERIC: class-member? ( obj class -- ? )

M: t class-member? ( obj class -- ? ) 2drop t ;

M: integer class-member? ( obj class -- ? ) = ;

M: range class-member? ( obj class -- ? )
    [ from>> ] [ to>> ] bi between? ;

M: any-char class-member? ( obj class -- ? )
    2drop t ;

M: any-char-no-nl class-member? ( obj class -- ? )
    drop CHAR: \n = not ;

M: letter-class class-member? ( obj class -- ? )
    drop letter? ;
            
M: LETTER-class class-member? ( obj class -- ? )
    drop LETTER? ;

M: Letter-class class-member? ( obj class -- ? )
    drop Letter? ;

M: ascii-class class-member? ( obj class -- ? )
    drop ascii? ;

M: digit-class class-member? ( obj class -- ? )
    drop digit? ;

: c-identifier-char? ( ch -- ? )
    { [ alpha? ] [ CHAR: _ = ] } 1|| ;

M: c-identifier-class class-member? ( obj class -- ? )
    drop c-identifier-char? ;

M: alpha-class class-member? ( obj class -- ? )
    drop alpha? ;

: punct? ( ch -- ? )
    "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~" member? ;

M: punctuation-class class-member? ( obj class -- ? )
    drop punct? ;

: java-printable? ( ch -- ? )
    { [ alpha? ] [ punct? ] } 1|| ;

M: java-printable-class class-member? ( obj class -- ? )
    drop java-printable? ;

M: non-newline-blank-class class-member? ( obj class -- ? )
    drop { [ blank? ] [ CHAR: \n = not ] } 1&& ;

M: control-character-class class-member? ( obj class -- ? )
    drop control? ;

: hex-digit? ( ch -- ? )
    {
        [ CHAR: A CHAR: F between? ]
        [ CHAR: a CHAR: f between? ]
        [ CHAR: 0 CHAR: 9 between? ]
    } 1|| ;

M: hex-digit-class class-member? ( obj class -- ? )
    drop hex-digit? ;

: java-blank? ( ch -- ? )
    {
        CHAR: \s CHAR: \t CHAR: \n
        HEX: b HEX: 7 CHAR: \r
    } member? ;

M: java-blank-class class-member? ( obj class -- ? )
    drop java-blank? ;

M: unmatchable-class class-member? ( obj class -- ? )
    2drop f ;

M: terminator-class class-member? ( obj class -- ? )
    drop "\r\n\u000085\u002029\u002028" member? ;

M: ^ class-member? ( obj class -- ? )
    2drop f ;

M: $ class-member? ( obj class -- ? )
    2drop f ;

M: f class-member? 2drop f ;

TUPLE: primitive-class class ;
C: <primitive-class> primitive-class

TUPLE: or-class seq ;

TUPLE: not-class class ;

TUPLE: and-class seq ;

GENERIC: combine-and ( class1 class2 -- combined ? )

: replace-if-= ( object object -- object ? )
    over = ;

M: object combine-and replace-if-= ;

M: t combine-and
    drop t ;

M: f combine-and
    nip t ;

M: not-class combine-and
    class>> 2dup = [ 2drop f t ] [
        dup integer? [
            2dup swap class-member?
            [ 2drop f f ]
            [ drop t ] if
        ] [ 2drop f f ] if
    ] if ;

M: integer combine-and
    swap 2dup class-member? [ drop t ] [ 2drop f t ] if ;

GENERIC: combine-or ( class1 class2 -- combined ? )

M: object combine-or replace-if-= ;

M: t combine-or
    nip t ;

M: f combine-or
    drop t ;

M: not-class combine-or
    class>> = [ t t ] [ f f ] if ;

M: integer combine-or
    2dup swap class-member? [ drop t ] [ 2drop f f ] if ;

: flatten ( seq class -- newseq )
    '[ dup _ instance? [ seq>> ] [ 1array ] if ] map concat ; inline

: try-combine ( elt1 elt2 quot -- combined/f ? )
    3dup call [ [ 3drop ] dip t ] [ drop swapd call ] if ; inline

:: prefix-combining ( seq elt quot: ( elt1 elt2 -- combined/f ? ) -- newseq )
    f :> combined!
    seq [ elt quot try-combine swap combined! ] find drop
    [ seq remove-nth combined prefix ]
    [ seq elt prefix ] if* ; inline

:: combine ( seq quot: ( elt1 elt2 -- combined/f ? ) empty class -- newseq )
    seq class flatten
    { } [ quot prefix-combining ] reduce
    dup length {
        { 0 [ drop empty ] }
        { 1 [ first ] }
        [ drop class new swap >>seq ]
    } case ; inline

: <and-class> ( seq -- class )
    [ combine-and ] t and-class combine ;

M: and-class class-member?
    seq>> [ class-member? ] with all? ;

: <or-class> ( seq -- class )
    [ combine-or ] f or-class combine ;

M: or-class class-member?
    seq>> [ class-member? ] with any? ;

GENERIC: <not-class> ( class -- inverse )

M: object <not-class>
    not-class boa ;

M: not-class <not-class>
    class>> ;

M: and-class <not-class>
    seq>> [ <not-class> ] map <or-class> ;

M: or-class <not-class>
    seq>> [ <not-class> ] map <and-class> ;

M: t <not-class> drop f ;
M: f <not-class> drop t ;

M: not-class class-member?
    class>> class-member? not ;

M: primitive-class class-member?
    class>> class-member? ;

UNION: class primitive-class not-class or-class and-class range ;

TUPLE: condition question yes no ;
C: <condition> condition

GENERIC# replace-question 2 ( class from to -- new-class )

M:: object replace-question ( class from to -- new-class )
    class from = to class ? ;

: replace-compound ( class from to -- seq )
    [ seq>> ] 2dip '[ _ _ replace-question ] map ;

M: and-class replace-question
    replace-compound <and-class> ;

M: or-class replace-question
    replace-compound <or-class> ;

M: not-class replace-question
    [ class>> ] 2dip replace-question <not-class> ;

: answer ( table question answer -- new-table )
    '[ _ _ replace-question ] assoc-map
    [ nip ] assoc-filter ;

: answers ( table questions answer -- new-table )
    '[ _ answer ] each ;

DEFER: make-condition

: (make-condition) ( table questions question -- condition )
    [ 2nip ]
    [ swap [ t answer ] dip make-condition ]
    [ swap [ f answer ] dip make-condition ] 3tri
    2dup = [ 2nip ] [ <condition> ] if ;

: make-condition ( table questions -- condition )
    [ keys ] [ unclip (make-condition) ] if-empty ;

GENERIC: class>questions ( class -- questions )
: compound-questions ( class -- questions ) seq>> [ class>questions ] gather ;
M: or-class class>questions compound-questions ;
M: and-class class>questions compound-questions ;
M: not-class class>questions class>> class>questions ;
M: object class>questions 1array ;

: table>questions ( table -- questions )
    values [ class>questions ] gather >array t swap remove ;

: table>condition ( table -- condition )
    ! input table is state => class
    >alist dup table>questions make-condition ;

: condition-map ( condition quot: ( obj -- obj' ) -- new-condition ) 
    over condition? [
        [ [ question>> ] [ yes>> ] [ no>> ] tri ] dip
        '[ _ condition-map ] bi@ <condition>
    ] [ call ] if ; inline recursive

: condition-states ( condition -- states )
    dup condition? [
        [ yes>> ] [ no>> ] bi
        [ condition-states ] bi@ append prune
    ] [ 1array ] if ;

: condition-at ( condition assoc -- new-condition )
    '[ _ at ] condition-map ;
