! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes combinators
combinators.short-circuit combinators.smart hex-strings kernel
math math.order sequences sets unicode unicode.data ;
FROM: ascii => ascii? ;
IN: regexp.classes

SINGLETONS: dot letter-class LETTER-class Letter-class digit-class
alpha-class non-newline-blank-class
ascii-class punctuation-class java-printable-class blank-class
control-character-class hex-digit-class java-blank-class c-identifier-class
unmatchable-class terminator-class word-boundary-class ;

SINGLETONS: beginning-of-input ^crlf end-of-input $crlf end-of-file
^unix $unix word-break ;

TUPLE: range-class { from read-only } { to read-only } ;
C: <range-class> range-class

TUPLE: primitive-class { class read-only } ;
C: <primitive-class> primitive-class

TUPLE: category-class { category read-only } ;
C: <category-class> category-class

TUPLE: category-range-class { category read-only } ;
C: <category-range-class> category-range-class

TUPLE: script-class { script read-only } ;
C: <script-class> script-class

GENERIC: class-member? ( obj class -- ? )

M: t class-member? 2drop t ; inline

M: integer class-member? = ; inline

M: range-class class-member?
    [ from>> ] [ to>> ] bi between? ; inline

M: letter-class class-member?
    drop letter? ; inline

M: LETTER-class class-member?
    drop LETTER? ; inline

M: Letter-class class-member?
    drop Letter? ; inline

M: ascii-class class-member?
    drop ascii? ; inline

M: digit-class class-member?
    drop digit? ; inline

: c-identifier-char? ( ch -- ? )
    { [ alpha? ] [ CHAR: _ = ] } 1|| ;

M: c-identifier-class class-member?
    drop c-identifier-char? ; inline

M: alpha-class class-member?
    drop alpha? ; inline

: punct? ( ch -- ? )
    "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~" member? ;

M: punctuation-class class-member?
    drop punct? ; inline

: java-printable? ( ch -- ? )
    { [ alpha? ] [ punct? ] } 1|| ;

M: java-printable-class class-member?
    drop java-printable? ; inline

M: non-newline-blank-class class-member?
    drop { [ blank? ] [ CHAR: \n = not ] } 1&& ; inline

M: control-character-class class-member?
    drop control? ; inline

M: hex-digit-class class-member?
    drop hex-digit? ; inline

: java-blank? ( ch -- ? )
    {
        CHAR: \s CHAR: \t CHAR: \n
        CHAR: \v CHAR: \a CHAR: \r
    } member? ;

M: java-blank-class class-member?
    drop java-blank? ; inline

M: unmatchable-class class-member?
    2drop f ; inline

M: terminator-class class-member?
    drop "\r\n\u000085\u002029\u002028" member? ; inline

M: f class-member? 2drop f ; inline

M: script-class class-member?
    [ script-of ] [ script>> ] bi* = ; inline

M: category-class class-member?
    [ category ] [ category>> ] bi* = ; inline

M: category-range-class class-member? inline
    [ category first ] [ category>> ] bi* = ; inline

TUPLE: not-class { class read-only } ;

PREDICATE: not-integer < not-class class>> integer? ;

UNION: simple-class
    primitive-class range-class dot ;
PREDICATE: not-simple < not-class class>> simple-class? ;

M: not-class class-member?
    class>> class-member? not ; inline

TUPLE: or-class { seq read-only } ;

M: or-class class-member?
    seq>> [ class-member? ] with any? ; inline

TUPLE: and-class { seq read-only } ;

M: and-class class-member?
    seq>> [ class-member? ] with all? ; inline

DEFER: (substitute)

: flatten ( seq class -- newseq )
    '[ dup _ instance? [ seq>> ] [ 1array ] if ] map concat ; inline

:: sequence>instance ( seq empty class -- instance )
    seq length {
        { 0 [ empty ] }
        { 1 [ seq first ] }
        [ drop seq { } like class boa ]
    } case ; inline

TUPLE: class-partition integers not-integers simples not-simples and or other ;

: partition-classes ( seq -- class-partition )
    members
    [ integer? ] partition
    [ not-integer? ] partition
    [ simple-class? ] partition
    [ not-simple? ] partition
    [ and-class? ] partition
    [ or-class? ] partition
    class-partition boa ;

: class-partition>sequence ( class-partition -- seq )
    {
        [ integers>> ]
        [ not-integers>> ]
        [ simples>> ]
        [ not-simples>> ]
        [ and>> ]
        [ or>> ]
        [ other>> ]
    } cleave>array concat ;

: repartition ( partition -- partition' )
    ! This could be made more efficient; only and and or are effected
    class-partition>sequence partition-classes ;

: filter-not-integers ( partition -- partition' )
    dup
    [ simples>> ] [ not-simples>> ] [ or>> ] tri
    3append and-class boa
    '[ [ class>> _ class-member? ] filter ] change-not-integers ;

: answer-ors ( partition -- partition' )
    dup [ not-integers>> ] [ not-simples>> ] [ simples>> ] tri 3append
    '[ [ _ [ t (substitute) ] each ] map ] change-or ;

: contradiction? ( partition -- ? )
    {
        [ [ simples>> ] [ not-simples>> ] bi intersects? ]
        [ other>> f swap member? ]
    } 1|| ;

: make-and-class ( partition -- and-class )
    answer-ors repartition
    [ t swap remove ] change-other
    dup contradiction?
    [ drop f ]
    [ filter-not-integers class-partition>sequence members t and-class sequence>instance ] if ;

: <and-class> ( seq -- class )
    dup and-class flatten partition-classes
    dup integers>> length {
        { 0 [ nip make-and-class ] }
        { 1 [ integers>> first [ '[ _ swap class-member? ] all? ] verify ] }
        [ 3drop f ]
    } case ;

: filter-integers ( partition -- partition' )
    dup
    [ simples>> ] [ not-simples>> ] [ and>> ] tri
    3append or-class boa
    '[ [ _ class-member? ] reject ] change-integers ;

: answer-ands ( partition -- partition' )
    dup [ integers>> ] [ not-simples>> ] [ simples>> ] tri 3append
    '[ [ _ [ f (substitute) ] each ] map ] change-and ;

: tautology? ( partition -- ? )
    {
        [ [ simples>> ] [ not-simples>> ] bi intersects? ]
        [ other>> t swap member? ]
    } 1|| ;

: make-or-class ( partition -- and-class )
    answer-ands repartition
    [ f swap remove ] change-other
    dup tautology?
    [ drop t ]
    [ filter-integers class-partition>sequence members f or-class sequence>instance ] if ;

: <or-class> ( seq -- class )
    dup or-class flatten partition-classes
    dup not-integers>> length {
        { 0 [ nip make-or-class ] }
        { 1 [
            not-integers>> first
            [ class>> '[ _ swap class-member? ] any? ] keep or
        ] }
        [ 3drop t ]
    } case ;

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

: <minus-class> ( a b -- a-b )
    <not-class> 2array <and-class> ;

: <sym-diff-class> ( a b -- a~b )
    2array [ <or-class> ] [ <and-class> ] bi <minus-class> ;

M: primitive-class class-member?
    class>> class-member? ; inline

TUPLE: condition question yes no ;
C: <condition> condition

GENERIC#: answer 2 ( class from to -- new-class )

M:: object answer ( class from to -- new-class )
    class from = to class ? ;

: replace-compound ( class from to -- seq )
    [ seq>> ] 2dip '[ _ _ answer ] map ;

M: and-class answer
    replace-compound <and-class> ;

M: or-class answer
    replace-compound <or-class> ;

M: not-class answer
    [ class>> ] 2dip answer <not-class> ;

GENERIC#: (substitute) 1 ( class from to -- new-class )
M: object (substitute) answer ;
M: not-class (substitute) [ <not-class> ] bi@ answer ;

: assoc-answer ( table question answer -- new-table )
    '[ _ _ (substitute) ] assoc-map sift-values ;

: assoc-answers ( table questions answer -- new-table )
    '[ _ assoc-answer ] each ;

DEFER: make-condition

: (make-condition) ( table questions question -- condition )
    [ 2nip ]
    [ swap [ t assoc-answer ] dip make-condition ]
    [ swap [ f assoc-answer ] dip make-condition ] 3tri
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
        [ condition-states ] bi@ union
    ] [ 1array ] if ;

: condition-at ( condition assoc -- new-condition )
    '[ _ at ] condition-map ;
