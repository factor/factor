! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays compiler.units fry hashtables help.topics io
kernel math namespaces sequences sets help.vocabs
help.apropos vocabs help.markup ;
IN: help.home

SYMBOLS: recent-words recent-articles recent-vocabs recent-searches ;

CONSTANT: recent-count 10

{ recent-words recent-articles recent-vocabs recent-searches }
[ [ V{ } clone ] initialize ] each

GENERIC: add-recent-where ( obj -- obj symbol )

M: link add-recent-where recent-articles ;
M: word-link add-recent-where recent-words ;
M: vocab-spec add-recent-where recent-vocabs ;
M: apropos add-recent-where recent-searches ;
M: object add-recent-where f ;

: $recent ( element -- )
    first get [ nl ] [ 1array $pretty-link ] interleave ;

: $recent-searches ( element -- )
    drop recent-searches get [ <$link> ] map $list ;

: redisplay-recent-page ( -- )
    "help.home" >link dup associate
    notify-definition-observers ;

: expire ( seq -- )
    [ length recent-count - [ 0 > ] keep ] keep
    '[ 0 _ _ delete-slice ] when ;

: add-recent ( obj -- )
    add-recent-where dup
    [ get [ adjoin ] [ expire ] bi ] [ 2drop ] if
    redisplay-recent-page ;