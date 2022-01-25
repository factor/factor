! Copyright (C) 2022 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors assocs continuations kernel math
math.statistics parser sequences spelling vocabs vocabs.parser ;

IN: did-you-mean

: did-you-mean ( name -- words )
    dup all-words [ [ name>> ] histogram-by corrections ] keep
    [ name>> swap member? ] with filter
    <no-word-error> throw-restarts no-word-restarted ;
