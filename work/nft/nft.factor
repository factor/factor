! File: nft.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2017 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: io io.encodings.utf8 io.launcher kernel lexer namespaces peg
peg.ebnf splitting strings ;

IN: nft

TUPLE: family name ;
TUPLE: table name family hook ; 
TUPLE: chain name table ;
TUPLE: rule name family table chain handle ;


EBNF: nftable
space = (" " | "\r" | "\n" | "\t")
spaces = space* => [[ drop ignore ]]

family = ("ip" | "ip6" | "inet" | "arp" | "bridge" | "netdev") => [[ >string ]]
name = [a-zA-Z-] => [[ >string ]]
text = (.)* => [[ drop ignore ]]

table = "table"  
token = spaces table spaces family text 
tokens = token*
;EBNF

: nftget ( -- text )
    "ssh 10.1.1.1 nft -a list ruleset" utf8 <process-stream> stream-contents ;

: pullnft ( -- )
    nftget tabs>spaces
    "\n" split
    <lexer> lexer set
;

: pullnft1 ( -- )
    "ssh 10.1.1.1 nft -a list ruleset" utf8 <process-stream>
    [ ! [ readln dup print ] loop
B        readln <lexer> [ parse-token ] curry loop
    ] with-input-stream
    ;

: nfeb ( -- x )
    "table ip nat" nftable ; 
