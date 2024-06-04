! Copyright (C) 2010 Dmitry Shubin.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel math ranges sequences sequences.private ;
IN: z-algorithm

: lcp ( seq1 seq2 -- n )
    [ min-length dup ] 2keep mismatch-unsafe or* drop ;

<PRIVATE

:: out-of-zbox ( seq Z l r k -- seq Z l r )
    seq k tail-slice seq lcp :> Zk
    Zk k Z set-nth seq Z
    Zk 0 > [ k Zk k + 1 - ] [ l r ] if ; inline

:: inside-zbox ( seq Z l r k -- seq Z l r )
    k l - Z nth :> Zk'
    r k - 1 +   :> b
    seq Z Zk' b <
    [ Zk' k Z set-nth l r ] ! still inside
    [
        seq r 1 + seq b [ tail-slice ] 2bi@ lcp :> q
        q b + k Z set-nth k q r +
    ] if ; inline

: z-value ( seq Z l r k -- seq Z l r )
    2dup < [ out-of-zbox ] [ inside-zbox ] if ; inline

:: (z-values) ( seq -- Z )
    seq length dup 0 <array> :> ( len Z )
    len 0 Z set-nth
    seq Z 0 0 len [1..b) [ z-value ] each 4drop
    Z ; inline

PRIVATE>

: z-values ( seq -- Z )
    [ { } ] [ (z-values) ] if-empty ;
