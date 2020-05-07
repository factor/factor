! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs arrays combinators combinators.short-circuit
io io.encodings.utf8 io.files json.reader kernel math math.order
memoize modern.slices prettyprint sequences strings ;
IN: html5

: 1sbuf ( ch -- sbuf ) [ SBUF" " clone ] dip over push ; inline
: ?1sbuf ( ch -- sbuf ) [ SBUF" " clone ] dip [ over push ] when* ; inline

! https://html.spec.whatwg.org/multipage/parsing.html#tokenization

DEFER: data-state
DEFER: (data-state)
DEFER: rcdata-state
DEFER: (rcdata-state)
DEFER: rawtext-state
DEFER: (rawtext-state)
DEFER: script-data-state
DEFER: (script-data-state)
DEFER: plaintext-state
DEFER: (plaintext-state)
DEFER: tag-open-state
DEFER: (tag-open-state)
DEFER: end-tag-open-state
DEFER: (end-tag-open-state)
DEFER: tag-name-state
DEFER: (tag-name-state)
DEFER: rcdata-less-than-sign-state
DEFER: (rcdata-less-than-sign-state)
DEFER: rcdata-end-tag-open-state
DEFER: (rcdata-end-tag-open-state)
DEFER: rcdata-end-tag-name-state
DEFER: (rcdata-end-tag-name-state)
DEFER: rawtext-less-than-sign-state
DEFER: (rawtext-less-than-sign-state)
DEFER: rawtext-end-tag-open-state
DEFER: (rawtext-end-tag-open-state)
DEFER: rawtext-end-tag-name-state
DEFER: (rawtext-end-tag-name-state)
DEFER: script-data-less-than-sign-state
DEFER: (script-data-less-than-sign-state)
DEFER: script-data-end-tag-open-state
DEFER: (script-data-end-tag-open-state)
DEFER: script-data-end-tag-name-state
DEFER: (script-data-end-tag-name-state)
DEFER: script-data-escape-start-state
DEFER: (script-data-escape-start-state)
DEFER: script-data-escape-start-dash-state
DEFER: (script-data-escape-start-dash-state)
DEFER: script-data-escaped-state
DEFER: (script-data-escaped-state)
DEFER: script-data-escaped-dash-state
DEFER: (script-data-escaped-dash-state)
DEFER: script-data-escaped-dash-dash-state
DEFER: (script-data-escaped-dash-dash-state)
DEFER: script-data-escaped-less-than-sign-state
DEFER: (script-data-escaped-less-than-sign-state)
DEFER: script-data-escaped-end-tag-open-state
DEFER: (script-data-escaped-end-tag-open-state)
DEFER: script-data-escaped-end-tag-name-state
DEFER: (script-data-escaped-end-tag-name-state)
DEFER: script-data-double-escape-start-state
DEFER: (script-data-double-escape-start-state)
DEFER: script-data-double-escaped-state
DEFER: (script-data-double-escaped-state)
DEFER: script-data-double-escaped-dash-state
DEFER: (script-data-double-escaped-dash-state)
DEFER: script-data-double-escaped-dash-dash-state
DEFER: (script-data-double-escaped-dash-dash-state)
DEFER: script-data-double-escaped-less-than-sign-state
DEFER: (script-data-double-escaped-less-than-sign-state)
DEFER: script-data-double-escape-end-state
DEFER: (script-data-double-escape-end-state)
DEFER: before-attribute-name-state
DEFER: (before-attribute-name-state)
DEFER: attribute-name-state
DEFER: (attribute-name-state)
DEFER: after-attribute-name-state
DEFER: (after-attribute-name-state)
DEFER: before-attribute-value-state
DEFER: (before-attribute-value-state)
DEFER: attribute-value-double-quoted-state
DEFER: (attribute-value-double-quoted-state)
DEFER: attribute-value-single-quoted-state
DEFER: (attribute-value-single-quoted-state)
DEFER: attribute-value-unquoted-state
DEFER: (attribute-value-unquoted-state)
DEFER: after-attribute-value-quoted-state
DEFER: (after-attribute-value-quoted-state)
DEFER: self-closing-start-tag-state
DEFER: (self-closing-start-tag-state)
DEFER: bogus-comment-state
DEFER: (bogus-comment-state)
DEFER: markup-declaration-open-state
DEFER: (markup-declaration-open-state)
DEFER: comment-start-state
DEFER: (comment-start-state)
DEFER: comment-start-dash-state
DEFER: (comment-start-dash-state)
DEFER: comment-state
DEFER: (comment-state)
DEFER: comment-less-than-sign-state
DEFER: (comment-less-than-sign-state)
DEFER: comment-less-than-sign-bang-state
DEFER: (comment-less-than-sign-bang-state)
DEFER: comment-less-than-sign-bang-dash-state
DEFER: (comment-less-than-sign-bang-dash-state)
DEFER: comment-less-than-sign-bang-dash-dash-state
DEFER: (comment-less-than-sign-bang-dash-dash-state)
DEFER: comment-end-dash-state
DEFER: (comment-end-dash-state)
DEFER: comment-end-state
DEFER: (comment-end-state)
DEFER: comment-end-bang-state
DEFER: (comment-end-bang-state)
DEFER: doctype-state
DEFER: (doctype-state)
DEFER: before-doctype-name-state
DEFER: (before-doctype-name-state)
DEFER: doctype-name-state
DEFER: (doctype-name-state)
DEFER: after-doctype-name-state
DEFER: (after-doctype-name-state)
DEFER: after-doctype-public-keyword-state
DEFER: (after-doctype-public-keyword-state)
DEFER: before-doctype-public-identifier-state
DEFER: (before-doctype-public-identifier-state)
DEFER: doctype-public-identifier-double-quoted-state
DEFER: (doctype-public-identifier-double-quoted-state)
DEFER: doctype-public-identifier-single-quoted-state
DEFER: (doctype-public-identifier-single-quoted-state)
DEFER: after-doctype-public-identifier-state
DEFER: (after-doctype-public-identifier-state)
DEFER: between-doctype-public-and-system-identifiers-state
DEFER: (between-doctype-public-and-system-identifiers-state)
DEFER: after-doctype-system-keyword-state
DEFER: (after-doctype-system-keyword-state)
DEFER: before-doctype-system-identifier-state
DEFER: (before-doctype-system-identifier-state)
DEFER: doctype-system-identifier-double-quoted-state
DEFER: (doctype-system-identifier-double-quoted-state)
DEFER: doctype-system-identifier-single-quoted-state
DEFER: (doctype-system-identifier-single-quoted-state)
DEFER: after-doctype-system-identifier-state
DEFER: (after-doctype-system-identifier-state)
DEFER: bogus-doctype-state
DEFER: (bogus-doctype-state)
DEFER: cdata-section-state
DEFER: (cdata-section-state)
DEFER: cdata-section-bracket-state
DEFER: (cdata-section-bracket-state)
DEFER: cdata-section-end-state
DEFER: (cdata-section-end-state)
DEFER: character-reference-state
DEFER: (character-reference-state)
DEFER: named-character-reference-state
DEFER: (named-character-reference-state)
DEFER: ambiguous-ampersand-state
DEFER: (ambiguous-ampersand-state)
DEFER: numeric-character-reference-state
DEFER: (numeric-character-reference-state)
DEFER: hexadecimal-character-reference-start-state
DEFER: (hexadecimal-character-reference-start-state)
DEFER: decimal-character-reference-start-state
DEFER: (decimal-character-reference-start-state)
DEFER: hexadecimal-character-reference-state
DEFER: (hexadecimal-character-reference-state)
DEFER: decimal-character-reference-state
DEFER: (decimal-character-reference-state)
DEFER: numeric-character-reference-end-state
DEFER: (numeric-character-reference-end-state)


ERROR: unimplemented string ;
ERROR: unimplemented* ;

! Errors: https://html.spec.whatwg.org/multipage/parsing.html#parse-errors
ERROR: abrupt-closing-of-empty-comment ;
ERROR: abrupt-doctype-public-identifier ;
ERROR: abrupt-doctype-system-identifier ;
ERROR: absence-of-digits-in-numeric-character-reference ;
ERROR: cdata-in-html-content ;
ERROR: character-reference-outside-unicode-range ;
ERROR: control-character-in-input-stream ;
ERROR: control-character-reference ;
ERROR: end-tag-with-attributes ;
ERROR: duplicate-attribute ;
ERROR: end-tag-with-trailing-solidus ;
ERROR: eof-before-tag-name ;
ERROR: eof-in-cdata ;
ERROR: eof-in-comment ;
ERROR: eof-in-doctype ;
ERROR: eof-in-script-html-comment-like-text ;
ERROR: eof-in-tag ;
ERROR: incorrectly-closed-comment ;
ERROR: incorrectly-opened-comment ;
ERROR: invalid-character-sequence-after-doctype-name ;
ERROR: invalid-first-character-of-tag-name ;
ERROR: missing-attribute-value ;
ERROR: missing-doctype-name ;
ERROR: missing-doctype-public-identifier ;
ERROR: missing-doctype-system-identifier ;
ERROR: missing-end-tag-name ;
ERROR: missing-quote-before-doctype-public-identifier ;

ERROR: missing-quote-before-doctype-system-identifier ;
ERROR: missing-semicolon-after-character-reference ;
ERROR: missing-whitespace-after-doctype-public-keyword ;
ERROR: missing-whitespace-after-doctype-system-keyword ;
ERROR: missing-whitespace-before-doctype-name ;
ERROR: missing-whitespace-between-attributes ;
ERROR: missing-whitespace-between-doctype-public-and-system-identifiers ;
ERROR: nested-comment ;
ERROR: noncharacter-character-reference ;
ERROR: noncharacter-in-input-stream ;
ERROR: non-void-html-element-start-tag-with-trailing-solidus ;
ERROR: null-character-reference ;
ERROR: surrogate-character-reference ;
ERROR: surrogate-in-input-stream ;
ERROR: unexpected-character-after-doctype-system-identifier ;
ERROR: unexpected-character-in-attribute-name ;
ERROR: unexpected-character-in-unquoted-attribute-value ;
ERROR: unexpected-equals-sign-before-attribute-name ;
ERROR: unexpected-null-character ;
ERROR: unexpected-question-mark-instead-of-tag-name ;
ERROR: unexpected-solidus-in-tag ;
ERROR: unknown-named-character-reference ;

! Tree insertion modes
SINGLETONS: initial-mode before-html-mode before-head-mode
in-head-mode in-head-noscript-mode after-head-mode
in-body-mode text-mode in-table-mode in-table-text-mode
in-caption-mode in-column-group-mode in-table-body-mode
in-row-mode in-cell-mode in-select-mode in-select-in-table-mode in-template-mode
after-body-mode in-frameset-mode after-frameset-mode after-after-body-mode
after-after-frameset-mode ;

TUPLE: tag-state
name ;

TUPLE: start-tag self-closing? attributes ;
: <start-tag> ( -- start-tag )
    start-tag new
        H{ } clone >>attributes
    ; inline

TUPLE: end-tag self-closing? attributes ;
: <end-tag> ( -- start-tag )
    end-tag new
        H{ } clone >>attributes
    ; inline

: <tag-state> ( -- tag-state )
    tag-state new
    ; inline

TUPLE: document
quirks-mode?
tree
tree-insert-mode
doctype-token
tag
tag-name
attribute-name
attribute-value
temporary-buffer
comment-token
open-elements
return-state ;

TUPLE: doctype
    name
    public-identifier
    system-identifier
    quirks-flag ;

: <doctype> ( -- doctype )
    doctype new
        SBUF" " clone >>name ; inline

: make-doctype-token ( ch -- doctype )
    doctype new
        swap ?1sbuf >>name ; inline

TUPLE: tag
    name
    attributes ;

: <tag> ( -- tag )
    tag new
        SBUF" " clone >>name
        V{ } clone >>attributes ;


: <document> ( -- document )
    document new
        V{ } clone >>tree
        initial-mode >>tree-insert-mode
        <doctype> >>doctype-token
        <tag> >>tag
        SBUF" " clone >>tag-name
        SBUF" " clone >>attribute-name
        SBUF" " clone >>attribute-value
        SBUF" " clone >>temporary-buffer
        SBUF" " clone >>comment-token
        V{ } clone >>open-elements
    ; inline

: force-quirks-flag-on ( document -- )
    doctype-token>> t >>quirks-flag drop ;

: initialize-doctype-public-identifier ( document -- )
    [ SBUF" " clone ] dip doctype-token>> public-identifier<< ;

: initialize-doctype-system-identifier ( document -- )
    [ SBUF" " clone ] dip doctype-token>> system-identifier<< ;

: push-doctype-public-identifier ( ch document -- )
    doctype-token>> public-identifier>> push ;

: push-doctype-system-identifier ( ch document -- )
    doctype-token>> system-identifier>> push ;

GENERIC: tree-insert* ( document obj tree-insert-mode -- document )
M: initial-mode tree-insert*
    drop {
        { CHAR: \t [ ] }
        { CHAR: \n [ ] }
        { CHAR: \f [ ] }
        { CHAR: \r [ ] }
        { CHAR: \s [ ] }
        [ "initial-mode tree-insert*" unimplemented ]
    } case ;

M: before-html-mode tree-insert* drop unimplemented* ;
M: before-head-mode tree-insert* drop unimplemented* ;
M: in-head-mode tree-insert* drop unimplemented* ;
M: in-head-noscript-mode tree-insert* drop unimplemented* ;
M: after-head-mode tree-insert* drop unimplemented* ;
M: in-body-mode tree-insert* drop unimplemented* ;
M: text-mode tree-insert* drop unimplemented* ;
M: in-table-mode tree-insert* drop unimplemented* ;
M: in-table-text-mode tree-insert* drop unimplemented* ;
M: in-caption-mode tree-insert* drop unimplemented* ;
M: in-column-group-mode tree-insert* drop unimplemented* ;
M: in-table-body-mode tree-insert* drop unimplemented* ;
M: in-row-mode tree-insert* drop unimplemented* ;
M: in-cell-mode tree-insert* drop unimplemented* ;
M: in-select-mode tree-insert* drop unimplemented* ;
M: in-select-in-table-mode tree-insert* drop unimplemented* ;
M: in-template-mode tree-insert* drop unimplemented* ;
M: after-body-mode tree-insert* drop unimplemented* ;
M: in-frameset-mode tree-insert* drop unimplemented* ;
M: after-frameset-mode tree-insert* drop unimplemented* ;
M: after-after-body-mode tree-insert* drop unimplemented* ;
M: after-after-frameset-mode tree-insert* drop unimplemented* ;

: tree-insert ( document obj -- document )
    over tree-insert-mode>> tree-insert* ;

MEMO: load-entities ( -- assoc )
    "vocab:html5/entities.json" utf8 file-contents json> ;

: entity? ( string -- entity/string > )
    load-entities ?at ;


: push-doctype-name ( ch document -- ) doctype-token>> name>> push ;
: push-tag-name ( ch document -- ) tag-name>> push ;
: push-attribute-name ( ch document -- ) attribute-name>> push ;
: push-attribute-value ( ch document -- ) attribute-value>> push ;
: push-temporary-buffer ( ch document -- ) temporary-buffer>> push ;
: reset-temporary-buffer ( document -- ) SBUF" " clone temporary-buffer<< ;
: reset-end-tag ( document -- ) SBUF" " clone end-tag-name<< ;
: push-comment-token ( ch document -- ) comment-token>> push ;
: push-all-comment-token ( string document -- ) comment-token>> push-all ;

: current-attribute ( document -- attribute/f )
    [ attribute-name>> >string f like ]
    [ attribute-value>> >string f like ] bi
    2dup or [ 2array ] [ 2drop f ] if ;

: push-when ( obj/f seq -- )
    over [ push ] [ 2drop ] if ; inline

: reset-attribute ( document -- )
    SBUF" " clone >>attribute-name
    SBUF" " clone >>attribute-value drop ;

: push-attribute ( document -- )
    [ current-attribute ]
    [ tag>> attributes>> push-when ]
    [ reset-attribute ] tri ;

: flush-temporary-buffer ( document -- )
    "flushing character-reference: " write
    [ temporary-buffer>> >string . ]
    [ SBUF" " clone >>temporary-buffer drop ] bi ;

: emit-eof ( document -- ) drop "emit-eof" print ;
: emit-char ( char document -- ) drop "emit-char: " write 1string . ;
: emit-temporary-buffer-with ( string document -- ) "emit-temp-buffer: " write temporary-buffer>> append . ;
: emit-string ( char document -- ) drop "emit-string: " write . ;
: emit-tag ( document -- )
    "emit tag: " write
    {
        [ [ tag-name>> >string ] [ tag>> name<< ] bi ]
        [ push-attribute ]
        [ tag>> . ]
        [ <tag> >>tag drop ]
        [ SBUF" " clone >>tag-name drop ]
    } cleave ;
: emit-end-tag ( document -- ) "emit end tag: " write . ;
: emit-doctype-token ( document -- )
    "emit doctype: " write
    doctype-token>> . ;
: emit-comment-token ( document -- )
    "emit comment token: " write
    [ comment-token>> >string . ]
    [ SBUF" " clone comment-token<< ] bi ;


! check if matches open tag
: appropriate-end-tag-token? ( document -- ? )
    drop f ;

: ascii-upper-alpha? ( ch -- ? ) [ CHAR: A CHAR: Z between? ] [ f ] if* ; inline
: ascii-lower-alpha? ( ch -- ? ) [ CHAR: a CHAR: z between? ] [ f ] if* ; inline
: ascii-upper-hex-digit? ( ch -- ? ) [ CHAR: A CHAR: F between? ] [ f ] if* ; inline
: ascii-lower-hex-digit? ( ch -- ? ) [ CHAR: a CHAR: f between? ] [ f ] if* ; inline
: ascii-hex-alpha? ( ch -- ? ) { [ ascii-upper-hex-digit? ] [ ascii-lower-hex-digit? ] } 1|| ; inline

: ascii-digit? ( ch/f -- ? ) [ CHAR: 0 CHAR: 9 between? ] [ f ] if* ;
: ascii-alpha? ( ch/f -- ? ) { [ ascii-lower-alpha? ] [ ascii-upper-alpha? ] } 1|| ;
: ascii-alphanumeric? ( ch/f -- ? ) { [ ascii-alpha? ] [ ascii-digit? ] } 1|| ;
: ascii-hex-digit? ( ch/f -- ? ) { [ ascii-digit? ] [ ascii-hex-alpha? ] } 1|| ;

: (return-state) ( n/f string document ch/f -- document n'/f string )
    over return-state>> dup [ "no return state" throw ] unless
    [
        f >>return-state
    ] 2dip
    execute( n/f string document ch/f -- document n'/f string ) ;

: return-state ( n/f string document -- document n'/f string )
    over return-state>>
    [
        f >>return-state
    ] 2dip
    execute( n/f string document -- document n'/f string ) ;

: (data-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: & = ] [ drop \ data-state reach return-state<< character-reference-state ] }
        { [ dup CHAR: < = ] [ drop tag-open-state ] }
        { [ dup CHAR: \0 = ] [ unexpected-null-character ] }
        { [ dup f = ] [ drop pick emit-eof ] }
        [ reach emit-char data-state ]
    } cond ;

: data-state ( document n/f string -- document n'/f string )
    next-char-from (data-state) ;


: (rcdata-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: & = ] [ drop \ rcdata-state reach return-state<< character-reference-state ] }
        { [ dup CHAR: < = ] [ drop rcdata-less-than-sign-state ] }
        { [ dup CHAR: \0 = ] [ unexpected-null-character ] }
        { [ dup f = ] [ drop pick emit-eof ] }
        [ reach emit-char rcdata-state ]
    } cond ;

: rcdata-state ( document n/f string -- document n'/f string )
    next-char-from (rcdata-state) ;


: (rawtext-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: < = ] [ drop rawtext-less-than-sign-state ] }
        { [ dup CHAR: \0 = ] [ drop unexpected-null-character ] }
        { [ dup f = ] [ drop pick emit-eof ] }
        [ reach emit-char rawtext-state ]
    } cond ;

: rawtext-state ( document n/f string -- document n'/f string )
    next-char-from (rawtext-state) ;


: (script-data-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: < = ] [ drop script-data-less-than-sign-state ] }
        { [ dup CHAR: \0 = ] [ drop unexpected-null-character ] }
        { [ dup f = ] [ drop pick emit-eof ] }
        [ reach emit-char script-data-state ]
    } cond ;

: script-data-state ( document n/f string -- document n'/f string )
    next-char-from (script-data-state) ;


: (plaintext-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: \0 = ] [ drop unexpected-null-character ] }
        { [ dup f = ] [ drop pick emit-eof ] }
        [ reach emit-char plaintext-state ]
    } cond ;

: plaintext-state ( document n/f string -- document n'/f string )
    next-char-from (plaintext-state) ;


: (tag-open-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alpha? ] [ (tag-name-state) ] }
        { [ dup CHAR: ! = ] [ drop markup-declaration-open-state ] }
        { [ dup CHAR: / = ] [ drop end-tag-open-state ] }
        { [ dup CHAR: ? = ] [ unexpected-question-mark-instead-of-tag-name ] }
        { [ dup f = ] [ eof-before-tag-name ] }
        [ invalid-first-character-of-tag-name ]
    } cond ;

: tag-open-state ( document n/f string -- document n'/f string )
    next-char-from (tag-open-state) ;


: (end-tag-open-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alpha? ] [ (tag-name-state) ] }
        { [ dup CHAR: > = ] [ missing-end-tag-name ] }
        { [ dup f = ] [ eof-before-tag-name ] }
        [ invalid-first-character-of-tag-name ]
    } cond ;

: end-tag-open-state ( document n/f string -- document n'/f string )
    next-char-from (end-tag-open-state) ;


: (tag-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-upper-alpha? ] [ 0x20 + reach push-tag-name tag-name-state ] }
        { [ dup "\t\n\f\s" member? ] [ drop before-attribute-name-state ] }
        { [ dup CHAR: / = ] [ drop self-closing-start-tag-state ] }
        { [ dup CHAR: > = ] [ drop pick emit-tag data-state ] }
        { [ dup CHAR: \0 = ] [ unexpected-null-character ] }
        { [ dup f = ] [ eof-before-tag-name ] }
        [ reach push-tag-name tag-name-state ]
    } cond ;

: tag-name-state ( document n/f string -- document n'/f string )
    next-char-from (tag-name-state) ;


: (rcdata-less-than-sign-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: / = ] [ drop pick reset-temporary-buffer rcdata-end-tag-open-state ] }
        [ [ CHAR: < reach emit-char ] dip (rcdata-state) ]
    } cond ;

: rcdata-less-than-sign-state ( document n/f string -- document n'/f string )
    next-char-from (rcdata-less-than-sign-state) ;


: (rcdata-end-tag-open-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alpha? ] [ reach reset-end-tag (rcdata-end-tag-name-state) ] }
        [ [ CHAR: < reach emit-char ] dip (rcdata-state) ]
    } cond ;

: rcdata-end-tag-open-state ( document n/f string -- document n'/f string )
    next-char-from (rcdata-end-tag-open-state) ;


: (rcdata-end-tag-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [
            drop pick appropriate-end-tag-token?
            [ before-attribute-name-state ] [ "</" reach emit-temporary-buffer-with rcdata-state ] if
        ] }
        { [ dup CHAR: / = ] [
            drop pick appropriate-end-tag-token?
            [ self-closing-start-tag-state ] [ "</" reach emit-temporary-buffer-with rcdata-state ] if
        ] }
        { [ dup CHAR: > = ] [
            drop pick appropriate-end-tag-token?
            [ pick emit-end-tag data-state ] [ "</" reach emit-temporary-buffer-with rcdata-state ] if
        ] }
        { [ dup ascii-upper-alpha? ] [ [ 0x20 + reach push-tag-name ] [ reach push-temporary-buffer ] bi rcdata-end-tag-name-state ] }
        { [ dup ascii-lower-alpha? ] [ [ reach push-tag-name ] [ reach push-temporary-buffer ] bi rcdata-end-tag-name-state ] }
        [ [ "</" reach emit-temporary-buffer-with ] dip (rcdata-state) ]
    } cond ;

: rcdata-end-tag-name-state ( document n/f string -- document n'/f string )
    next-char-from (rcdata-end-tag-name-state) ;


: (rawtext-less-than-sign-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: / = ] [ drop pick reset-temporary-buffer rawtext-end-tag-open-state ] }
        [ [ CHAR: < reach emit-char ] dip (rawtext-state) ]
    } cond ;

: rawtext-less-than-sign-state ( document n/f string -- document n'/f string )
    next-char-from (rawtext-less-than-sign-state) ;


: (rawtext-end-tag-open-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alpha? ] [ reach reset-end-tag (rawtext-end-tag-name-state) ] }
        [ [ CHAR: < reach emit-char ] dip (rawtext-state) ]
    } cond ;

: rawtext-end-tag-open-state ( document n/f string -- document n'/f string )
    next-char-from (rawtext-end-tag-open-state) ;


: (rawtext-end-tag-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [
            drop pick appropriate-end-tag-token?
            [ before-attribute-name-state ] [ "</" reach emit-temporary-buffer-with rawtext-state ] if
        ] }
        { [ dup CHAR: / = ] [
            drop pick appropriate-end-tag-token?
            [ self-closing-start-tag-state ] [ "</" reach emit-temporary-buffer-with rawtext-state ] if
        ] }
        { [ dup CHAR: > = ] [
            drop pick appropriate-end-tag-token?
            [ pick emit-end-tag data-state ] [ "</" reach emit-temporary-buffer-with rawtext-state ] if
        ] }
        { [ dup ascii-upper-alpha? ] [ [ 0x20 + reach push-tag-name ] [ reach push-temporary-buffer ] bi rawtext-end-tag-name-state ] }
        { [ dup ascii-lower-alpha? ] [ [ reach push-tag-name ] [ reach push-temporary-buffer ] bi rawtext-end-tag-name-state ] }
        [ [ "</" reach emit-temporary-buffer-with ] dip (rawtext-state) ]
    } cond ;

: rawtext-end-tag-name-state ( document n/f string -- document n'/f string )
    next-char-from (rawtext-end-tag-name-state) ;


: (script-data-less-than-sign-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: / = ] [ drop pick reset-temporary-buffer script-data-end-tag-open-state ] }
        { [ dup CHAR: ! = ] [ drop "<!" reach emit-string script-data-escape-start-state ] }
        [ [ CHAR: < reach emit-char ] dip (script-data-state) ]
    } cond ;

: script-data-less-than-sign-state ( document n/f string -- document n'/f string )
    next-char-from (script-data-less-than-sign-state) ;


: (script-data-end-tag-open-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alpha? ] [ reach reset-end-tag (script-data-end-tag-name-state) ] }
        [ [ "</" reach emit-string ] dip (script-data-state) ]
    } cond ;

: script-data-end-tag-open-state ( document n/f string -- document n'/f string )
    next-char-from (script-data-end-tag-open-state) ;


: (script-data-end-tag-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [
            drop pick appropriate-end-tag-token?
            [ before-attribute-name-state ] [ "</" reach emit-temporary-buffer-with script-data-state ] if
        ] }
        { [ dup CHAR: / = ] [
            drop pick appropriate-end-tag-token?
            [ self-closing-start-tag-state ] [ "</" reach emit-temporary-buffer-with script-data-state ] if
        ] }
        { [ dup CHAR: > = ] [
            drop pick appropriate-end-tag-token?
            [ pick emit-end-tag data-state ] [ "</" reach emit-temporary-buffer-with script-data-state ] if
        ] }
        { [ dup ascii-upper-alpha? ] [ [ 0x20 + reach push-tag-name ] [ reach push-temporary-buffer ] bi rawtext-end-tag-name-state ] }
        { [ dup ascii-lower-alpha? ] [ [ reach push-tag-name ] [ reach push-temporary-buffer ] bi rawtext-end-tag-name-state ] }
        [ [ "</" reach emit-temporary-buffer-with ] dip (script-data-state) ]
    } cond ;

: script-data-end-tag-name-state ( document n/f string -- document n'/f string )
    next-char-from (script-data-end-tag-name-state) ;


: (script-data-escape-start-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop script-data-escape-start-dash-state ] }
        [ (script-data-state) ]
    } cond ;

: script-data-escape-start-state ( document n/f string -- document n'/f string )
    next-char-from (script-data-escape-start-state) ;


: (script-data-escape-start-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop script-data-escaped-dash-dash-state ] }
        [ (script-data-state) ]
    } cond ;

: script-data-escape-start-dash-state ( document n/f string -- document n'/f string )
    next-char-from (script-data-escape-start-dash-state) ;


: (script-data-escaped-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop script-data-escaped-dash-state ] }
        { [ dup CHAR: < = ] [ drop script-data-escaped-less-than-sign-state ] }
        { [ dup CHAR: \0 = ] [ unexpected-null-character CHAR: replacement-character unimplemented* ] }
        { [ dup f = ] [ eof-in-script-html-comment-like-text ] }
        [ reach emit-char script-data-escaped-state ]
    } cond ;

: script-data-escaped-state ( document n/f string -- document n'/f string )
    next-char-from (script-data-escaped-state) ;


: (script-data-escaped-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop script-data-escaped-dash-dash-state ] }
        { [ dup CHAR: < = ] [ drop script-data-escaped-less-than-sign-state ] }
        { [ dup CHAR: \0 = ] [ unexpected-null-character script-data-escaped-state ] }
        { [ dup f = ] [ eof-in-script-html-comment-like-text ] }
        [ reach emit-char script-data-escaped-state ]
    } cond ;

: script-data-escaped-dash-state ( document n/f string -- document n'/f string )
    next-char-from (script-data-escaped-dash-state) ;


: (script-data-escaped-dash-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ reach emit-char script-data-escaped-dash-dash-state ] }
        { [ dup CHAR: < = ] [ drop script-data-escaped-less-than-sign-state ] }
        { [ dup CHAR: > = ] [ reach emit-char script-data-state ] }
        { [ dup CHAR: \0 = ] [ unexpected-null-character script-data-escaped-state ] }
        { [ dup f = ] [ eof-in-script-html-comment-like-text ] }
        [ reach emit-char script-data-escaped-state ]
    } cond ;

: script-data-escaped-dash-dash-state ( document n/f string -- document n'/f string )
    next-char-from (script-data-escaped-dash-dash-state) ;


: (script-data-escaped-less-than-sign-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: / = ] [ drop pick reset-temporary-buffer script-data-escaped-end-tag-open-state ] }
        { [ dup ascii-alpha? ] [ [ pick reset-temporary-buffer CHAR: < reach emit-char ] dip (script-data-double-escape-start-state) ] }
        [ [ CHAR: < reach emit-char ] dip (script-data-escaped-state) ]
    } cond ;

: script-data-escaped-less-than-sign-state ( document n/f string -- document n'/f string )
    next-char-from (script-data-escaped-less-than-sign-state) ;


: (script-data-escaped-end-tag-open-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alpha? ] [ [ pick reset-end-tag ] dip (script-data-escaped-end-tag-name-state) ] }
        [ [ "</" reach emit-string ] dip (script-data-escaped-state) ]
    } cond ;

: script-data-escaped-end-tag-open-state ( document n/f string -- document n'/f string )
    next-char-from (script-data-escaped-end-tag-open-state) ;


: (script-data-escaped-end-tag-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [
            drop pick appropriate-end-tag-token?
            [ before-attribute-name-state ] [ "</" reach emit-temporary-buffer-with script-data-escaped-state ] if
        ] }
        { [ dup CHAR: / = ] [
            drop pick appropriate-end-tag-token?
            [ self-closing-start-tag-state ] [ "</" reach emit-temporary-buffer-with script-data-escaped-state ] if
        ] }
        { [ dup CHAR: > = ] [
            drop pick appropriate-end-tag-token?
            [ pick emit-end-tag data-state ] [ "</" reach emit-temporary-buffer-with script-data-escaped-state ] if
        ] }
        { [ dup ascii-upper-alpha? ] [ [ 0x20 + reach push-tag-name ] [ reach push-temporary-buffer ] bi script-data-escaped-end-tag-name-state ] }
        { [ dup ascii-lower-alpha? ] [ [ reach push-tag-name ] [ reach push-temporary-buffer ] bi script-data-escaped-end-tag-name-state ] }
        [ [ "</" reach emit-temporary-buffer-with ] dip (script-data-escaped-state) ]
    } cond ;

: script-data-escaped-end-tag-name-state ( document n/f string -- document n'/f string )
    next-char-from (script-data-escaped-end-tag-name-state) ;


: (script-data-double-escape-start-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s/>" member? ] [
            reach emit-char
            pick temporary-buffer>> "script" sequence=
            [ script-data-double-escaped-state ] [ script-data-escaped-state ] if
        ] }
        { [ dup ascii-upper-alpha? ] [ [ 0x20 + reach push-tag-name ] [ reach push-temporary-buffer ] bi script-data-double-escape-start-state ] }
        { [ dup ascii-lower-alpha? ] [ [ reach push-tag-name ] [ reach push-temporary-buffer ] bi script-data-double-escape-start-state ] } ! todo
        [ (script-data-escaped-state) ]
    } cond ;

: script-data-double-escape-start-state ( document n/f string -- document n'/f string )
    next-char-from (script-data-double-escape-start-state) ;


: (script-data-double-escaped-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ reach emit-char script-data-double-escaped-dash-state ] }
        { [ dup CHAR: < = ] [ reach emit-char script-data-double-escaped-less-than-sign-state ] }
        { [ dup CHAR: \0 = ] [
            unexpected-null-character
            CHAR: replacement-character reach emit-char
            script-data-double-escaped-state
        ] }
        { [ dup f = ] [ eof-in-script-html-comment-like-text ] }
        [ reach emit-char script-data-double-escaped-state ]
    } cond ;

: script-data-double-escaped-state ( document n/f string -- document n'/f string )
    next-char-from (script-data-double-escaped-state) ;


: (script-data-double-escaped-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ reach emit-char script-data-double-escaped-dash-dash-state ] }
        { [ dup CHAR: < = ] [ reach emit-char script-data-double-escaped-less-than-sign-state ] }
        { [ dup CHAR: \0 = ] [
            unexpected-null-character
            CHAR: replacement-character reach emit-char
            script-data-double-escaped-state
        ] }
        { [ dup f = ] [ eof-in-script-html-comment-like-text ] }
        [ reach emit-char script-data-double-escaped-state ]
    } cond ;

: script-data-double-escaped-dash-state ( document n/f string -- document n'/f string )
    next-char-from (script-data-double-escaped-dash-state) ;


: (script-data-double-escaped-dash-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ reach emit-char script-data-double-escaped-dash-dash-state ] }
        { [ dup CHAR: < = ] [ reach emit-char script-data-double-escaped-less-than-sign-state ] }
        { [ dup CHAR: > = ] [ reach emit-char script-data-state ] }
        { [ dup CHAR: \0 = ] [
            unexpected-null-character
            CHAR: replacement-character reach emit-char
            script-data-double-escaped-state
        ] }
        { [ dup f = ] [ eof-in-script-html-comment-like-text ] }
        [ reach emit-char script-data-escaped-state ]
    } cond ;

: script-data-double-escaped-dash-dash-state ( document n/f string -- document n'/f string )
    next-char-from (script-data-double-escaped-dash-dash-state) ;


: (script-data-double-escaped-less-than-sign-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: / = ] [ reach emit-char pick reset-temporary-buffer script-data-double-escape-end-state ] }
        [ (script-data-double-escaped-state) ]
    } cond ;

: script-data-double-escaped-less-than-sign-state ( document n/f string -- document n'/f string )
    next-char-from (script-data-double-escaped-less-than-sign-state) ;


: (script-data-double-escape-end-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s/>" member? ] [
            reach emit-char
            pick temporary-buffer>> "script" sequence=
            [ script-data-escaped-state ] [ script-data-double-escaped-state ] if
        ] }
        { [ dup ascii-upper-alpha? ] [ [ 0x20 + reach push-tag-name ] [ reach push-temporary-buffer ] bi script-data-double-escape-end-state ] }
        { [ dup ascii-lower-alpha? ] [ [ reach push-tag-name ] [ reach push-temporary-buffer ] bi script-data-double-escape-end-state ] } ! todo
        [ (script-data-double-escaped-state) ]
    } cond ;

: script-data-double-escape-end-state ( document n/f string -- document n'/f string )
    next-char-from (script-data-double-escape-end-state) ;


: (before-attribute-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-attribute-name-state ] }
        { [ dup "/>" member? ] [ (after-attribute-name-state) ] }
        { [ dup f = ] [ (after-attribute-name-state) ] }
        { [ dup CHAR: = = ] [ unexpected-equals-sign-before-attribute-name ] }
        [ reach push-attribute (attribute-name-state) ]
    } cond ;

: before-attribute-name-state ( document n/f string -- document n'/f string )
    next-char-from (before-attribute-name-state) ;


: (attribute-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s/>" member? ] [ (after-attribute-name-state) ] }
        { [ dup f = ] [ (after-attribute-name-state) ] }
        { [ dup CHAR: = = ] [ drop before-attribute-value-state ] }
        { [ dup ascii-upper-alpha? ] [
            0x20 + reach push-attribute-name
            attribute-name-state
        ] }
        { [ dup CHAR: \0 = ] [ unexpected-null-character ] }
        { [ dup "\"'<" member? ] [
            unexpected-character-in-attribute-name
            reach push-attribute-name attribute-name-state
        ] }
        [ reach push-attribute-name attribute-name-state ]
    } cond ;

: attribute-name-state ( document n/f string -- document n'/f string )
    next-char-from (attribute-name-state) ;


: (after-attribute-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop after-attribute-name-state ] }
        { [ dup CHAR: / = ] [ drop self-closing-start-tag-state ] }
        { [ dup CHAR: = = ] [ drop before-attribute-value-state ] }
        { [ dup CHAR: > = ] [ drop pick emit-tag data-state ] }
        { [ dup f = ] [ eof-in-tag ] }
        [ [ pick push-attribute ] dip (attribute-name-state) ]
    } cond ;

: after-attribute-name-state ( document n/f string -- document n'/f string )
    next-char-from (after-attribute-name-state) ;


: (before-attribute-value-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-attribute-name-state ] }
        { [ dup CHAR: " = ] [ drop attribute-value-double-quoted-state ] }
        { [ dup CHAR: ' = ] [ drop attribute-value-single-quoted-state ] }
        { [ dup CHAR: > = ] [ drop missing-attribute-value ] }
        [ (attribute-value-unquoted-state) ]
    } cond ;

: before-attribute-value-state ( document n/f string -- document n'/f string )
    next-char-from (before-attribute-value-state) ;


: (attribute-value-double-quoted-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: " = ] [ drop after-attribute-value-quoted-state ] }
        { [ dup CHAR: & = ] [
            drop
            [ \ attribute-value-double-quoted-state >>return-state ] 2dip character-reference-state
        ] }
        { [ dup CHAR: \0 = ] [ unexpected-null-character ] }
        { [ dup f = ] [ eof-in-tag ] }
        [ reach push-attribute-value attribute-value-double-quoted-state ]
    } cond ;

: attribute-value-double-quoted-state ( document n/f string -- document n'/f string )
    next-char-from (attribute-value-double-quoted-state) ;


: (attribute-value-single-quoted-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: ' = ] [ drop after-attribute-value-quoted-state ] }
        { [ dup CHAR: & = ] [
            drop [ \ attribute-value-single-quoted-state >>return-state ] 2dip
            character-reference-state
        ] }
        { [ dup CHAR: \0 = ] [
            drop unexpected-null-character
            CHAR: replacement-character reach push-attribute-value
        ] }
        { [ dup f = ] [ eof-in-tag ] }
        [ reach push-attribute-value attribute-value-single-quoted-state ]
    } cond ;

: attribute-value-single-quoted-state ( document n/f string -- document n'/f string )
    next-char-from (attribute-value-single-quoted-state) ;


: (attribute-value-unquoted-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-attribute-name-state ] }
        { [ dup CHAR: & = ] [
            drop
            [ \ attribute-value-unquoted-state >>return-state ] 2dip character-reference-state
        ] }
        { [ dup CHAR: > = ] [ drop pick emit-tag data-state ] }
        { [ dup CHAR: \0 = ] [ drop unexpected-null-character CHAR: replacement-character reach push-attribute-value ] }
        { [ dup "\"'<=`" member? ] [
            unexpected-character-in-unquoted-attribute-value
            reach push-attribute-value
            attribute-value-unquoted-state
        ] }
        { [ dup f = ] [ eof-in-tag ] }
        [ reach push-attribute-value attribute-value-unquoted-state ]
    } cond ;

: attribute-value-unquoted-state ( document n/f string -- document n'/f string )
    next-char-from (attribute-value-unquoted-state) ;


: (after-attribute-value-quoted-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-attribute-name-state ] }
        { [ dup CHAR: / = ] [ drop self-closing-start-tag-state ] }
        { [ dup CHAR: > = ] [ drop pick emit-tag data-state ] }
        { [ dup f = ] [ eof-in-tag ] }
        [ missing-whitespace-between-attributes (before-attribute-name-state) ]
    } cond ;

: after-attribute-value-quoted-state ( document n/f string -- document n'/f string )
    next-char-from (after-attribute-value-quoted-state) ;


: (self-closing-start-tag-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: > = ] [ missing-end-tag-name ] }
        { [ dup f = ] [ eof-in-tag ] }
        [ unexpected-solidus-in-tag ]
    } cond ;

: self-closing-start-tag-state ( document n/f string -- document n'/f string )
    next-char-from (self-closing-start-tag-state) ;


: (bogus-comment-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: > = ] [ drop pick emit-comment-token data-state ] }
        { [ dup f = ] [ drop pick [ emit-comment-token ] [ emit-eof ] bi ] }
        { [ dup CHAR: \0 = ] [ drop unexpected-null-character CHAR: replacement-character reach push-comment-token ] }
        [ reach push-comment-token bogus-comment-state ]
    } cond ;

: bogus-comment-state ( document n/f string -- document n'/f string )
    next-char-from (bogus-comment-state) ;


: markup-declaration-open-state ( document n/f string -- document n'/f string )
    {
        { [ "--" take-from? ] [ comment-start-state ] }
        { [ "DOCTYPE" take-from-insensitive? ] [ doctype-state ] }
        { [ "[CDATA[" take-from-insensitive? ] [ unimplemented* ] }
        [
            incorrectly-opened-comment ! bogus-comment-state
        ]
    } cond ;

: (comment-start-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop comment-start-dash-state ] }
        { [ dup CHAR: > = ] [ drop abrupt-closing-of-empty-comment pick emit-comment-token data-state ] }
        [ (comment-state) ]
    } cond ;

: comment-start-state ( document n/f string -- document n'/f string )
    next-char-from (comment-start-state) ;


: (comment-start-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop comment-end-state ] }
        { [ dup CHAR: > = ] [ drop abrupt-closing-of-empty-comment ] }
        { [ dup f = ] [ eof-in-comment ] }
        [ [ CHAR: - reach push-comment-token ] dip (comment-state) ]
    } cond ;

: comment-start-dash-state ( document n/f string -- document n'/f string )
    next-char-from (comment-start-dash-state) ;


: (comment-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: < = ] [ reach push-comment-token comment-less-than-sign-state ] }
        { [ dup CHAR: - = ] [ drop comment-end-dash-state ] }
        { [ dup CHAR: \0 = ] [ drop unexpected-null-character ] }
        { [ dup f = ] [ eof-in-comment ] }
        [ reach push-comment-token comment-state ]
    } cond ;

: comment-state ( document n/f string -- document n'/f string )
    next-char-from (comment-state) ;


: (comment-less-than-sign-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: ! = ] [ reach push-comment-token comment-less-than-sign-bang-state ] }
        { [ dup CHAR: < = ] [ reach push-comment-token comment-less-than-sign-state ] }
        [ (comment-state) ]
    } cond ;

: comment-less-than-sign-state ( document n/f string -- document n'/f string )
    next-char-from (comment-less-than-sign-state) ;


: (comment-less-than-sign-bang-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ reach push-comment-token comment-less-than-sign-bang-dash-state ] }
        [ (comment-state) ]
    } cond ;

: comment-less-than-sign-bang-state ( document n/f string -- document n'/f string )
    next-char-from (comment-less-than-sign-bang-state) ;


: (comment-less-than-sign-bang-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop comment-less-than-sign-bang-dash-dash-state ] }
        [ (comment-end-dash-state) ]
    } cond ;

: comment-less-than-sign-bang-dash-state ( document n/f string -- document n'/f string )
    next-char-from (comment-less-than-sign-bang-dash-state) ;


: (comment-less-than-sign-bang-dash-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: > = ] [ (comment-end-state) ] }
        { [ dup f = ] [ (comment-end-state) ] }
        [ nested-comment (comment-end-state) ]
    } cond ;

: comment-less-than-sign-bang-dash-dash-state ( document n/f string -- document n'/f string )
    next-char-from (comment-less-than-sign-bang-dash-dash-state) ;


: (comment-end-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop comment-end-state ] }
        { [ dup f = ] [ eof-in-comment ] }
        [ [ CHAR: - reach push-comment-token ] dip (comment-state) ]
    } cond ;

: comment-end-dash-state ( document n/f string -- document n'/f string )
    next-char-from (comment-end-dash-state) ;


: (comment-end-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: > = ] [ drop pick emit-comment-token data-state ] }
        { [ dup CHAR: ! = ] [ drop comment-end-bang-state ] }
        { [ dup CHAR: - = ] [ reach push-comment-token comment-end-state ] }
        { [ dup f = ] [ drop eof-in-comment pick [ emit-comment-token ] [ emit-eof ] bi ] }
        [ [ "--" reach push-all-comment-token ] dip (comment-state) ]
    } cond ;

: comment-end-state ( document n/f string -- document n'/f string )
    next-char-from (comment-end-state) ;


: (comment-end-bang-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop comment-end-dash-state ] }
        { [ dup CHAR: > = ] [ drop incorrectly-closed-comment pick emit-comment-token data-state ] }
        { [ dup f = ] [ eof-in-comment ] }
        [ [ "--!" reach push-all-comment-token ] dip (comment-state) ]
    } cond ;

: comment-end-bang-state ( document n/f string -- document n'/f string )
    next-char-from (comment-end-bang-state) ;


: (doctype-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-doctype-name-state ] }
        { [ dup CHAR: > = ] [ (before-doctype-name-state) ] }
        { [ dup f = ] [ eof-in-doctype ] } ! todo force-quirks
        [ missing-whitespace-before-doctype-name ]
    } cond ;

: doctype-state ( document n/f string -- document n'/f string )
    next-char-from (doctype-state) ;


: (before-doctype-name-state) ( document n/f string ch/f -- document n'/f string )
B
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-doctype-name-state ] }
        { [ dup ascii-upper-alpha? ] [ 0x20 + reach push-tag-name tag-name-state ] }
        { [ dup CHAR: \0 = ] [
            drop
            unexpected-null-character
            CHAR: replacement-character make-doctype-token reach doctype-token<<
            doctype-name-state
        ] }
        [ make-doctype-token reach doctype-token<< doctype-name-state ]
    } cond ;

: before-doctype-name-state ( document n/f string -- document n'/f string )
    next-char-from (before-doctype-name-state) ;


: (doctype-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop after-doctype-name-state ] }
        { [ dup CHAR: > = ] [ drop pick emit-doctype-token data-state ] }
        { [ dup ascii-upper-alpha? ] [ 0x20 + reach push-doctype-name doctype-name-state ] }
        { [ dup CHAR: \0 = ] [
            drop unexpected-null-character
            CHAR: replacement-character pick push-doctype-name
            doctype-name-state
        ] }
        { [ dup f = ] [ drop eof-in-doctype pick [ emit-doctype-token ] [ emit-eof ] bi ] } ! force-quirks on for doctype-token
        [ reach push-doctype-name doctype-name-state ]
    } cond ;

: doctype-name-state ( document n/f string -- document n'/f string )
    next-char-from (doctype-name-state) ;


: (after-doctype-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop after-doctype-name-state ] }
        { [ dup CHAR: > = ] [ drop pick emit-doctype-token data-state ] }
        { [ dup f = ] [ eof-in-doctype ] }
        { [ [ "PUBLIC" take-from-insensitive? ] dip swap ] [ drop after-doctype-public-keyword-state ] }
        { [ [ "SYSTEM" take-from-insensitive? ] dip swap ] [ drop after-doctype-system-keyword-state ] }
        [ invalid-character-sequence-after-doctype-name ]
    } cond ;

: after-doctype-name-state ( document n/f string -- document n'/f string )
    next-char-from (after-doctype-name-state) ;


: (after-doctype-public-keyword-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-doctype-public-identifier-state ] }
        { [ dup CHAR: " = ] [ missing-whitespace-after-doctype-public-keyword ] }
        { [ dup CHAR: ' = ] [ missing-whitespace-after-doctype-public-keyword ] }
        { [ dup CHAR: > = ] [ drop missing-doctype-public-identifier force-quirks-flag-on data-state ] }
        { [ dup f = ] [ drop eof-in-doctype pick [ emit-doctype-token ] [ emit-eof ] bi ] }
        [
            missing-quote-before-doctype-public-identifier
            [ reach force-quirks-flag-on ] dip
            (bogus-doctype-state)
        ]
    } cond ;

: after-doctype-public-keyword-state ( document n/f string -- document n'/f string )
    next-char-from (after-doctype-public-keyword-state) ;


: (before-doctype-public-identifier-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-doctype-public-identifier-state ] }
        { [ dup CHAR: " = ] [
            drop pick initialize-doctype-public-identifier
            doctype-public-identifier-double-quoted-state
        ] }
        { [ dup CHAR: ' = ] [
            drop pick initialize-doctype-public-identifier
            doctype-public-identifier-single-quoted-state
        ] }
        { [ dup CHAR: > = ] [
            drop missing-doctype-public-identifier
            pick [ force-quirks-flag-on ] [ emit-doctype-token ] bi
            data-state
        ] }
        { [ dup f = ] [ drop eof-in-doctype pick [ emit-doctype-token ] [ emit-eof ] bi ] }
        [
            missing-quote-before-doctype-public-identifier
            [ reach force-quirks-flag-on ] dip
            (bogus-doctype-state)
        ]
    } cond ;

: before-doctype-public-identifier-state ( document n/f string -- document n'/f string )
    next-char-from (before-doctype-public-identifier-state) ;


: (doctype-public-identifier-double-quoted-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: " = ] [ drop after-doctype-public-identifier-state ] }
        { [ dup CHAR: \0 = ] [
            drop
            unexpected-null-character
            CHAR: replacement-character pick push-doctype-public-identifier
            doctype-public-identifier-double-quoted-state
        ] }
        { [ dup CHAR: > = ] [
            drop abrupt-doctype-public-identifier
            pick [ force-quirks-flag-on ] [ emit-doctype-token ] bi
            data-state
        ] }
        { [ dup f = ] [
            drop eof-in-doctype
            pick [ force-quirks-flag-on ] [ emit-doctype-token ] [ emit-eof ] tri
        ] }
        [ reach push-doctype-public-identifier doctype-public-identifier-double-quoted-state ]
    } cond ;

: doctype-public-identifier-double-quoted-state ( document n/f string -- document n'/f string )
    next-char-from (doctype-public-identifier-double-quoted-state) ;


: (doctype-public-identifier-single-quoted-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: ' = ] [ drop after-doctype-public-identifier-state ] }
        { [ dup CHAR: \0 = ] [
            drop
            unexpected-null-character
            CHAR: replacement-character pick push-doctype-public-identifier
            doctype-public-identifier-double-quoted-state
        ] }
        { [ dup CHAR: > = ] [
            drop abrupt-doctype-public-identifier
            pick [ force-quirks-flag-on ] [ emit-doctype-token ] bi
            data-state
        ] }
        { [ dup f = ] [
            drop eof-in-doctype
            pick [ force-quirks-flag-on ] [ emit-doctype-token ] [ emit-eof ] tri
        ] }
        [ reach push-doctype-public-identifier doctype-public-identifier-single-quoted-state ]
    } cond ;

: doctype-public-identifier-single-quoted-state ( document n/f string -- document n'/f string )
    next-char-from (doctype-public-identifier-single-quoted-state) ;


: (after-doctype-public-identifier-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop between-doctype-public-and-system-identifiers-state ] }
        { [ dup CHAR: > = ] [
            drop pick emit-doctype-token
            data-state
        ] }
        { [ dup CHAR: " = ] [
            drop missing-whitespace-between-doctype-public-and-system-identifiers
            pick initialize-doctype-system-identifier
            doctype-system-identifier-double-quoted-state
        ] }
        { [ dup CHAR: ' = ] [
            drop missing-whitespace-between-doctype-public-and-system-identifiers
            pick initialize-doctype-system-identifier
            doctype-system-identifier-single-quoted-state
        ] }
        { [ dup f = ] [ drop eof-in-doctype pick [ force-quirks-flag-on ] [ emit-doctype-token ] [ emit-eof ] tri ] }
        [
            missing-quote-before-doctype-system-identifier
            [ reach force-quirks-flag-on ] dip
            (bogus-doctype-state)
        ]
    } cond ;

: after-doctype-public-identifier-state ( document n/f string -- document n'/f string )
    next-char-from (after-doctype-public-identifier-state) ;


: (between-doctype-public-and-system-identifiers-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop between-doctype-public-and-system-identifiers-state ] }
        { [ dup CHAR: > = ] [
            drop pick emit-doctype-token
            data-state
        ] }
        { [ dup CHAR: " = ] [
            drop pick initialize-doctype-system-identifier
            doctype-system-identifier-double-quoted-state
        ] }
        { [ dup CHAR: ' = ] [
            drop pick initialize-doctype-system-identifier
            doctype-system-identifier-single-quoted-state
        ] }
        { [ dup f = ] [ drop eof-in-doctype pick [ force-quirks-flag-on ] [ emit-doctype-token ] [ emit-eof ] tri ] }
        [
            missing-quote-before-doctype-system-identifier
            [ reach force-quirks-flag-on ] dip
            (bogus-doctype-state)
        ]
    } cond ;

: between-doctype-public-and-system-identifiers-state ( document n/f string -- document n'/f string )
    next-char-from (between-doctype-public-and-system-identifiers-state) ;


: (after-doctype-system-keyword-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop between-doctype-public-and-system-identifiers-state ] }
        { [ dup CHAR: " = ] [
            drop missing-whitespace-after-doctype-system-keyword
            pick initialize-doctype-system-identifier
            doctype-system-identifier-double-quoted-state
        ] }
        { [ dup CHAR: ' = ] [
            drop missing-whitespace-after-doctype-system-keyword
            pick initialize-doctype-system-identifier
            doctype-system-identifier-single-quoted-state
        ] }
        { [ dup CHAR: > = ] [
            drop missing-doctype-system-identifier
            pick [ force-quirks-flag-on ] [ emit-doctype-token ] bi
            data-state
        ] }
        { [ dup f = ] [ drop eof-in-doctype pick [ force-quirks-flag-on ] [ emit-doctype-token ] [ emit-eof ] tri ] }
        [
            missing-quote-before-doctype-system-identifier
            [ reach force-quirks-flag-on ] dip
            (bogus-doctype-state)
        ]
    } cond ;

: after-doctype-system-keyword-state ( document n/f string -- document n'/f string )
    next-char-from (after-doctype-system-keyword-state) ;


: (before-doctype-system-identifier-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-doctype-system-identifier-state ] }
        { [ dup CHAR: " = ] [
            drop pick initialize-doctype-system-identifier
            doctype-system-identifier-double-quoted-state
        ] }
        { [ dup CHAR: ' = ] [
            drop pick initialize-doctype-system-identifier
            doctype-system-identifier-single-quoted-state
        ] }
        { [ dup CHAR: > = ] [
            drop missing-doctype-system-identifier
            pick [ force-quirks-flag-on ] [ emit-doctype-token ] bi
            data-state
        ] }
        { [ dup f = ] [ drop eof-in-doctype pick [ emit-doctype-token ] [ emit-eof ] bi ] }
        [
            missing-quote-before-doctype-system-identifier
            [ reach force-quirks-flag-on ] dip
            (bogus-doctype-state)
        ]
    } cond ;

: before-doctype-system-identifier-state ( document n/f string -- document n'/f string )
    next-char-from (before-doctype-system-identifier-state) ;


: (doctype-system-identifier-double-quoted-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: " = ] [ drop after-doctype-system-identifier-state ] }
        { [ dup CHAR: \0 = ] [
            drop
            unexpected-null-character
            CHAR: replacement-character pick push-doctype-system-identifier
            doctype-system-identifier-double-quoted-state
        ] }
        { [ dup CHAR: > = ] [
            drop abrupt-doctype-system-identifier
            pick [ force-quirks-flag-on ] [ emit-doctype-token ] bi
            data-state
        ] }
        { [ dup f = ] [
            drop eof-in-doctype
            pick [ force-quirks-flag-on ] [ emit-doctype-token ] [ emit-eof ] tri
        ] }
        [ reach push-doctype-system-identifier doctype-system-identifier-double-quoted-state ]
    } cond ;

: doctype-system-identifier-double-quoted-state ( document n/f string -- document n'/f string )
    next-char-from (doctype-system-identifier-double-quoted-state) ;


: (doctype-system-identifier-single-quoted-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: ' = ] [ drop after-doctype-system-identifier-state ] }
        { [ dup CHAR: \0 = ] [
            drop
            unexpected-null-character
            CHAR: replacement-character pick push-doctype-system-identifier
            doctype-system-identifier-double-quoted-state
        ] }
        { [ dup CHAR: > = ] [
            drop abrupt-doctype-system-identifier
            pick [ force-quirks-flag-on ] [ emit-doctype-token ] bi
            data-state
        ] }
        { [ dup f = ] [
            drop eof-in-doctype
            pick [ force-quirks-flag-on ] [ emit-doctype-token ] [ emit-eof ] tri
        ] }
        [ reach push-doctype-system-identifier doctype-system-identifier-single-quoted-state ]
    } cond ;

: doctype-system-identifier-single-quoted-state ( document n/f string -- document n'/f string )
    next-char-from (doctype-system-identifier-single-quoted-state) ;


: (after-doctype-system-identifier-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop after-doctype-system-identifier-state ] }
        { [ dup CHAR: > = ] [
            drop pick emit-doctype-token
            data-state
        ] }
        { [ dup f = ] [ drop eof-in-doctype pick [ force-quirks-flag-on ] [ emit-doctype-token ] [ emit-eof ] tri ] }
        [
            unexpected-character-after-doctype-system-identifier
            [ reach force-quirks-flag-on ] dip
            (bogus-doctype-state)
        ]
    } cond ;

: after-doctype-system-identifier-state ( document n/f string -- document n'/f string )
    next-char-from (after-doctype-system-identifier-state) ;


: (bogus-doctype-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: > = ] [ drop pick emit-doctype-token data-state ] }
        { [ dup CHAR: \0 = ] [ drop unexpected-null-character bogus-doctype-state ] }
        { [ dup f = ] [ drop eof-in-doctype pick emit-eof ] }
        [ drop bogus-doctype-state ]
    } cond ;

: bogus-doctype-state ( document n/f string -- document n'/f string )
    next-char-from (bogus-doctype-state) ;


: (cdata-section-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: ] = ] [ drop cdata-section-bracket-state ] }
        { [ dup f = ] [ drop eof-in-cdata pick emit-eof ] }
        [ reach emit-char cdata-section-state ]
    } cond ;

: cdata-section-state ( document n/f string -- document n'/f string )
    next-char-from (cdata-section-state) ;


: (cdata-section-bracket-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: ] = ] [ drop cdata-section-end-state ] }
        [ [ CHAR: ] reach emit-char ] dip (cdata-section-state) ]
    } cond ;

: cdata-section-bracket-state ( document n/f string -- document n'/f string )
    next-char-from (cdata-section-bracket-state) ;


: (cdata-section-end-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: ] = ] [ reach emit-char cdata-section-end-state ] }
        { [ dup CHAR: > = ] [ drop data-state ] }
        [ [ "]]" reach emit-string ] dip (cdata-section-state) ]
    } cond ;

: cdata-section-end-state ( document n/f string -- document n'/f string )
    next-char-from (cdata-section-end-state) ;


: (character-reference-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alphanumeric? ] [ (named-character-reference-state) ] }
        { [ dup CHAR: # = ] [ reach push-temporary-buffer numeric-character-reference-state ] }
        [ reach flush-temporary-buffer (return-state) ]
    } cond ;

: character-reference-state ( document n/f string -- document n'/f string )
    next-char-from (character-reference-state) ;


: (named-character-reference-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alphanumeric? ] [
            unimplemented*
            reach push-temporary-buffer
            named-character-reference-state
        ] }
        [ drop pick flush-temporary-buffer ambiguous-ampersand-state ]
    } cond ;

: named-character-reference-state ( document n/f string -- document n'/f string )
    next-char-from (named-character-reference-state) ;


: (ambiguous-ampersand-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alphanumeric? ] [
            unimplemented*
        ] }
        { [ dup CHAR: ; = ] [ unknown-named-character-reference (return-state) ] }
        [ (return-state) ]
    } cond ;

: ambiguous-ampersand-state ( document n/f string -- document n'/f string )
    next-char-from (ambiguous-ampersand-state) ;


: (numeric-character-reference-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "xX" member? ] [ reach push-temporary-buffer hexadecimal-character-reference-start-state ] }
        [ (decimal-character-reference-start-state) ]
    } cond ;

: numeric-character-reference-state ( document n/f string -- document n'/f string )
    next-char-from (numeric-character-reference-state) ;


: (hexadecimal-character-reference-start-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-hex-digit? ] [ (hexadecimal-character-reference-state) ] }
        [ absence-of-digits-in-numeric-character-reference reach flush-temporary-buffer (return-state) ]
    } cond ;

: hexadecimal-character-reference-start-state ( document n/f string -- document n'/f string )
    next-char-from (hexadecimal-character-reference-start-state) ;


: (decimal-character-reference-start-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-digit? ] [ (decimal-character-reference-state) ] }
        [ absence-of-digits-in-numeric-character-reference reach flush-temporary-buffer (return-state) ]
    } cond ;

: decimal-character-reference-start-state ( document n/f string -- document n'/f string )
    next-char-from (decimal-character-reference-start-state) ;


: (hexadecimal-character-reference-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-digit? ] [ unimplemented* ] }
        { [ dup ascii-upper-hex-digit? ] [ unimplemented* ] }
        { [ dup ascii-lower-hex-digit? ] [ unimplemented* ] }
        { [ dup CHAR: ; = ] [ drop numeric-character-reference-end-state ] }
        [ missing-semicolon-after-character-reference ]
    } cond ;

: hexadecimal-character-reference-state ( document n/f string -- document n'/f string )
    next-char-from (hexadecimal-character-reference-state) ;


: (decimal-character-reference-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-digit? ] [ unimplemented* ] }
        { [ dup CHAR: ; = ] [ drop numeric-character-reference-end-state ] }
        [ missing-semicolon-after-character-reference ]
    } cond ;

: decimal-character-reference-state ( document n/f string -- document n'/f string )
    next-char-from (decimal-character-reference-state) ;


: (numeric-character-reference-end-state) ( document n/f string ch/f -- document n'/f string )
    {
        [ missing-semicolon-after-character-reference ]
    } cond ;

: numeric-character-reference-end-state ( document n/f string -- document n'/f string )
    next-char-from (numeric-character-reference-end-state) ;



: parse-html5 ( string -- document )
    [ <document> 0 ] dip data-state 2drop ;