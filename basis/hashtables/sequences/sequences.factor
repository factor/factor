! Copyright (C) 2011 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs combinators hashtables
hashtables.wrapped kernel parser sequences vocabs.loader ;

IN: hashtables.sequences

TUPLE: sequence-wrapper < wrapped-key ;

C: <sequence-wrapper> sequence-wrapper

M: sequence-wrapper equal?
    over sequence-wrapper?
    [ [ underlying>> ] bi@ sequence= ]
    [ 2drop f ] if ; inline

M: sequence-wrapper hashcode*
    underlying>> [ sequence-hashcode ] recursive-hashcode ; inline

TUPLE: sequence-hashtable < wrapped-hashtable ;

: <sequence-hashtable> ( n -- ihash )
    <hashtable> sequence-hashtable boa ; inline

M: sequence-hashtable wrap-key drop <sequence-wrapper> ;

M: sequence-hashtable clone
    underlying>> clone sequence-hashtable boa ; inline

: >sequence-hashtable ( assoc -- shashtable )
    [ assoc-size <sequence-hashtable> ] keep assoc-union! ;

SYNTAX: SH{ \ } [ >sequence-hashtable ] parse-literal ;

{ "hashtables.sequences" "prettyprint" } "hashtables.sequences.prettyprint" require-when
