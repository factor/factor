! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors xmode.tokens xmode.keyword-map kernel
sequences vectors assocs strings memoize unicode
regexp ;
IN: xmode.rules

TUPLE: string-matcher string ignore-case? ;

C: <string-matcher> string-matcher

! Based on org.gjt.sp.jedit.syntax.ParserRuleSet
TUPLE: rule-set
name
props
keywords
rules
imports
terminate-char
ignore-case?
default
escape-rule
highlight-digits?
digit-re
no-word-sep
finalized?
;

: <rule-set> ( -- ruleset )
    rule-set new
        H{ } clone >>rules
        H{ } clone >>props
        V{ } clone >>imports ;

MEMO: standard-rule-set ( id -- ruleset )
    <rule-set> swap >>default ;

: import-rule-set ( import ruleset -- )
    imports>> push ;

: inverted-index ( hashes key index -- )
    [ swapd push-at ] 2curry each ;

: ?push-all ( seq1 seq2 -- seq1+seq2 )
    [
        over [ [ V{ } like ] dip append! ] [ nip ] if
    ] when* ;

: rule-set-no-word-sep* ( ruleset -- str )
    [ no-word-sep>> ]
    [ keywords>> ] bi
    dup [ keyword-map-no-word-sep* ] when
    "_" 3append ;

! Match restrictions
TUPLE: matcher text at-line-start? at-whitespace-end? at-word-start? ;

C: <matcher> matcher

! Based on org.gjt.sp.jedit.syntax.ParserRule
TUPLE: rule
no-line-break?
no-word-break?
no-escape?
start
end
match-token
body-token
delegate
chars
;

TUPLE: seq-rule < rule ;

TUPLE: span-rule < rule ;

TUPLE: eol-span-rule < rule ;

: init-span ( rule -- )
    dup delegate>> [ drop ] [
        dup body-token>> standard-rule-set
        swap delegate<<
    ] if ;

: init-eol-span ( rule -- )
    dup init-span
    t >>no-line-break? drop ;

TUPLE: mark-following-rule < rule ;

TUPLE: mark-previous-rule < rule ;

TUPLE: escape-rule < rule ;

: <escape-rule> ( string -- rule )
    f <string-matcher> f f f <matcher>
    escape-rule new swap >>start ;

GENERIC: text-hash-char ( text -- ch )

M: f text-hash-char ;

M: string-matcher text-hash-char string>> first ;

M: regexp text-hash-char drop f ;

: rule-chars* ( rule -- string )
    [ chars>> ] [ start>> ] bi text>>
    text-hash-char [ suffix ] when* ;

: add-rule ( rule ruleset -- )
    [ dup rule-chars* >upper swap ] dip rules>> inverted-index ;

: add-escape-rule ( string ruleset -- )
    over [
        [ <escape-rule> ] dip
        2dup escape-rule<<
        add-rule
    ] [
        2drop
    ] if ;
