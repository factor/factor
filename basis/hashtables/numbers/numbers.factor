! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors assocs hashtables hashtables.wrapped kernel
math math.hashcodes parser vocabs.loader ;

IN: hashtables.numbers

<PRIVATE

TUPLE: number-wrapper
    { underlying number read-only } ;

C: <number-wrapper> number-wrapper

M: number-wrapper equal?
    over number-wrapper?
    [ [ underlying>> ] bi@ number= ]
    [ 2drop f ] if ; inline

M: number-wrapper hashcode*
    nip underlying>> number-hashcode ; inline

PRIVATE>

TUPLE: number-hashtable < wrapped-hashtable ;

: <number-hashtable> ( n -- shashtable )
    <hashtable> number-hashtable boa ; inline

M: number-hashtable wrap-key drop <number-wrapper> ;

M: number-hashtable clone
    underlying>> clone number-hashtable boa ; inline

: >number-hashtable ( assoc -- shashtable )
    [ assoc-size <number-hashtable> ] keep assoc-union! ;

M: number-hashtable new-assoc drop <number-hashtable> ;

SYNTAX: NH{ \ } [ >number-hashtable ] parse-literal ;

{ "hashtables.numbers" "prettyprint" } "hashtables.numbers.prettyprint" require-when
