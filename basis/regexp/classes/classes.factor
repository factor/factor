! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.order words combinators locals
ascii unicode.categories combinators.short-circuit sequences ;
IN: regexp.classes

SINGLETONS: any-char any-char-no-nl
letter-class LETTER-class Letter-class digit-class
alpha-class non-newline-blank-class
ascii-class punctuation-class java-printable-class blank-class
control-character-class hex-digit-class java-blank-class c-identifier-class
unmatchable-class terminator-class word-boundary-class ;

SINGLETONS: beginning-of-input ^ end-of-input $ ;

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
    class>> = [ f t ] [ f f ] if ;

M: integer combine-and
    swap 2dup class-member? [ drop t ] [ 2drop f t ] if ;

GENERIC: combine-or ( class1 class2 -- combined ? )

M: object combine-or replace-if-= ;

M: t combine-or
    drop f ;

M: f combine-or
    drop t ;

M: not-class combine-or
    class>> = [ t t ] [ f f ] if ;

M: integer combine-or
    2dup swap class-member? [ drop t ] [ 2drop f f ] if ;

: try-combine ( elt1 elt2 quot -- combined/f ? )
    3dup call [ [ 3drop ] dip t ] [ drop swapd call ] if ; inline

:: prefix-combining ( seq elt quot: ( elt1 elt2 -- combined/f ? ) -- newseq )
    f :> combined!
    seq [ elt quot try-combine swap combined! ] find drop
    [ seq remove-nth combined prefix ]
    [ seq elt prefix ] if* ; inline

:: combine ( seq quot: ( elt1 elt2 -- combined/f ? ) empty class -- newseq )
    seq { } [ quot prefix-combining ] reduce
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

: <not-class> ( class -- inverse )
    {
        { t [ f ] }
        { f [ t ] }
        [ dup not-class? [ class>> ] [ not-class boa ] if ]
    } case ;

M: not-class class-member?
    class>> class-member? not ;

M: primitive-class class-member?
    class>> class-member? ;

UNION: class primitive-class not-class or-class range ;
