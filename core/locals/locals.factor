! Copyright (C) 2007, 2009 Slava Pestov, Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
! USING: fry kernel lexer locals.errors locals.parser locals.types
! macros memoize namespaces sequences vocabs vocabs.loader words ;
USING: sequences vocabs vocabs.loader ;
IN: locals

! SYNTAX: :>
    ! in-lambda? get [ :>-outside-lambda-error ] unless
    ! scan-token parse-def suffix! ;

! SYNTAX: \|[ parse-lambda append! ;

! SYNTAX: \let[ parse-let append! ;
! SYNTAX: \'let[ H{ } clone (parse-lambda) [ fry call <let> ?rewrite-closures call ] curry append! ;

! SYNTAX: \:: (::) define-declared ;

! SYNTAX: \M:: (M::) define ;

! SYNTAX: \MACRO:: (::) define-macro ;

! SYNTAX: \MEMO:: (::) define-memoized ;

! SYNTAX: \IDENTITY-MEMO:: (::) define-identity-memoized ;

! { "locals.macros" "locals.fry" } [ require ] each

! { "locals" "prettyprint" } "locals.definitions" require-when
! { "locals" "prettyprint" } "locals.prettyprint" require-when



{
    "locals.parser"
    "locals.types"
    "locals.errors"
    "locals.macros"
    "locals.fry"
} [ require ] each

{ "locals" "prettyprint" } "locals.definitions" require-when
{ "locals" "prettyprint" } "locals.prettyprint" require-when
