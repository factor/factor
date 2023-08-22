! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors assocs hashtables hashtables.wrapped kernel
math parser sequences vocabs.loader ;

IN: hashtables.sequences

<PRIVATE

TUPLE: sequence-wrapper
    { underlying sequence read-only } ;

C: <sequence-wrapper> sequence-wrapper

M: sequence-wrapper equal?
    over sequence-wrapper?
    [ [ underlying>> ] bi@ sequence= ]
    [ 2drop f ] if ; inline

M: sequence-wrapper hashcode*
    underlying>> [ sequence-hashcode ] recursive-hashcode ; inline

PRIVATE>

TUPLE: sequence-hashtable < wrapped-hashtable ;

: <sequence-hashtable> ( n -- shashtable )
    <hashtable> sequence-hashtable boa ; inline

M: sequence-hashtable wrap-key drop <sequence-wrapper> ;

M: sequence-hashtable clone
    underlying>> clone sequence-hashtable boa ; inline

: >sequence-hashtable ( assoc -- shashtable )
    [ assoc-size <sequence-hashtable> ] keep assoc-union! ;

M: sequence-hashtable new-assoc drop <sequence-hashtable> ;

SYNTAX: SH{ \ } [ >sequence-hashtable ] parse-literal ;

{ "hashtables.sequences" "prettyprint" } "hashtables.sequences.prettyprint" require-when
