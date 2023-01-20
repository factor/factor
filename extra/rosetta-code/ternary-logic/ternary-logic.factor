! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: combinators kernel ;
IN: rosetta-code.ternary-logic

! https://rosettacode.org/wiki/Ternary_logic

! In logic, a three-valued logic (also trivalent, ternary, or
! trinary logic, sometimes abbreviated 3VL) is any of several
! many-valued logic systems in which there are three truth values
! indicating true, false and some indeterminate third value. This
! is contrasted with the more commonly known bivalent logics (such
! as classical sentential or boolean logic) which provide only for
! true and false. Conceptual form and basic ideas were initially
! created by Łukasiewicz, Lewis and Sulski. These were then
! re-formulated by Grigore Moisil in an axiomatic algebraic form,
! and also extended to n-valued logics in 1945.

! Task:

! * Define a new type that emulates ternary logic by storing data trits.

! * Given all the binary logic operators of the original
!   programming language, reimplement these operators for the new
!   Ternary logic type trit.

! * Generate a sampling of results using trit variables.

! * Kudos for actually thinking up a test case algorithm where
!   ternary logic is intrinsically useful, optimises the test case
!   algorithm and is preferable to binary logic.

SINGLETON: m
UNION: trit t m POSTPONE: f ;

GENERIC: >trit ( object -- trit )
M: trit >trit ;

: tnot ( trit1 -- trit )
    >trit { { t [ f ] } { m [ m ] } { f [ t ] } } case ;

: tand ( trit1 trit2 -- trit )
    >trit {
        { t [ >trit ] }
        { m [ >trit { { t [ m ] } { m [ m ] } { f [ f ] } } case ] }
        { f [ drop f ] }
    } case ;

: tor ( trit1 trit2 -- trit )
    >trit {
        { t [ drop t ] }
        { m [ >trit { { t [ t ] } { m [ m ] } { f [ m ] } } case ] }
        { f [ >trit ] }
    } case ;

: txor ( trit1 trit2 -- trit )
    >trit {
        { t [ tnot ] }
        { m [ drop m ] }
        { f [ >trit ] }
    } case ;

: t= ( trit1 trit2 -- trit )
    >trit {
        { t [ >trit ] }
        { m [ drop m ] }
        { f [ tnot ] }
    } case ;
