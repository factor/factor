! Copyright (C) 2010 Dmitry Shubin.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators.smart kernel locals math math.ranges
sequences sequences.private ;
IN: z-algorithm

: lcp ( seq1 seq2 -- n )
    [ min-length ] 2keep mismatch [ nip ] when* ;

<PRIVATE

:: out-of-zbox ( seq Z l r k -- seq Z l r )
    seq k tail-slice seq lcp :> Zk
    Zk Z push seq Z
    Zk 0 > [ k Zk k + 1 - ] [ l r ] if ; inline

:: inside-zbox ( seq Z l r k -- seq Z l r )
    k l - Z nth :> Zk'
    r k - 1 +   :> b
    seq Z Zk' b <
    [ Zk' Z push l r ] ! still inside
    [
        seq r 1 + seq b [ tail-slice ] 2bi@ lcp :> q
        q b + Z push k q r +
    ] if ; inline

: (z-value) ( seq Z l r k -- seq Z l r )
    2dup < [ out-of-zbox ] [ inside-zbox ] if ; inline

:: (z-values) ( seq -- Z )
    V{ } clone 0 0 seq length :> ( Z l r len )
    len Z push [ seq Z l r 1 len [a,b) [ (z-value) ] each ]
    drop-outputs Z ; inline

PRIVATE>

: z-values ( seq -- Z )
    dup length 0 > [ (z-values) ] when >array ;
