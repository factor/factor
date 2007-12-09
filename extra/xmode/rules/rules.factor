USING: xmode.tokens xmode.keyword-map kernel
sequences vectors assocs strings memoize regexp ;
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
;

: init-rule-set ( ruleset -- )
    #! Call after constructor.
    >r H{ } clone H{ } clone V{ } clone r>
    {
        set-rule-set-rules
        set-rule-set-props
        set-rule-set-imports
    } set-slots ;

: <rule-set> ( -- ruleset )
    rule-set construct-empty dup init-rule-set ;

MEMO: standard-rule-set ( id -- ruleset )
    <rule-set> [ set-rule-set-default ] keep ;

: import-rule-set ( import ruleset -- )
    rule-set-imports push ;

: inverted-index ( hashes key index -- )
    [ swapd [ ?push ] change-at ] 2curry each ;

: ?push-all ( seq1 seq2 -- seq1+seq2 )
    [
        over [ >r V{ } like r> over push-all ] [ nip ] if
    ] when* ;

: rule-set-no-word-sep* ( ruleset -- str )
    dup rule-set-no-word-sep
    swap rule-set-keywords dup [ keyword-map-no-word-sep* ] when
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

: construct-rule ( class -- rule )
    >r rule construct-empty r> construct-delegate ; inline

TUPLE: seq-rule ;

TUPLE: span-rule ;

TUPLE: eol-span-rule ;

: init-span ( rule -- )
    dup rule-delegate [ drop ] [
        dup rule-body-token standard-rule-set
        swap set-rule-delegate
    ] if ;

: init-eol-span ( rule -- )
    dup init-span
    t swap set-rule-no-line-break? ;

TUPLE: mark-following-rule ;

TUPLE: mark-previous-rule ;

TUPLE: escape-rule ;

: <escape-rule> ( string -- rule )
    f <string-matcher> f f f <matcher>
    escape-rule construct-rule
    [ set-rule-start ] keep ;

GENERIC: text-hash-char ( text -- ch )

M: f text-hash-char ;

M: string-matcher text-hash-char string-matcher-string first ;

M: regexp text-hash-char drop f ;

: rule-chars* ( rule -- string )
    dup rule-chars
    swap rule-start matcher-text
    text-hash-char [ add ] when* ;

: add-rule ( rule ruleset -- )
    >r dup rule-chars* >upper swap
    r> rule-set-rules inverted-index ;

: add-escape-rule ( string ruleset -- )
    over [
        >r <escape-rule> r>
        2dup set-rule-set-escape-rule
        add-rule
    ] [
        2drop
    ] if ;
