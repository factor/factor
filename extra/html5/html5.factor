! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs combinators
combinators.short-circuit io io.encodings.utf8 io.files json
kernel math math.order memoize modern.slices prettyprint
sequences sequences.extras strings suffix-arrays words ;

IN: html5

: 1sbuf ( ch -- sbuf ) [ SBUF" " clone ] dip over push ; inline
: ?1sbuf ( ch -- sbuf ) [ SBUF" " clone ] dip [ over push ] when* ; inline

! https://html.spec.whatwg.org/multipage/parsing.html#tokenization

! https://infra.spec.whatwg.org/#namespaces
CONSTANT: html-namespace "https://www.w3.org/1999/xhtml"
CONSTANT: mathml-namespace "https://www.w3.org/1998/Math/MathML"
CONSTANT: svg-namespace "https://www.w3.org/2000/svg"
CONSTANT: xlink-namespace "https://www.w3.org/1999/xlink"
CONSTANT: xml-namespace "https://www.w3.org/XML/1998/namespace"
CONSTANT: xmlns-namespace "https://www.w3.org/2000/xmlns/"

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

TUPLE: document
quirks-mode?
limited-quirks-mode?
iframe-srcdoc?
scripting? ! set in constructor
frameset-ok? ! frameset-ok? but we want default to f
fostering-parent?
tree
tree-doctype
head-element-pointer ! set during insertion time
parser-cannot-change-mode-flag
insertion-mode
original-insertion-mode
last
node
context
doctype
tag
end-tag

tag-name
end-tag-name
attribute-name
attribute-value
temporary-buffer
comment-token
open-elements
return-state ;

! "reset the insertion mode appropriately"
! : reset-insertion-mode ( document -- document )
!     f >>last
!     dup open-elements>> ?last >>node
!     dup [ open-elements>> ?first ] [ node>> ] bi = [
!         t >>last dup node>> >>context
!     ] when
!     dup node>> {
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!         { [
!             dup name>> >lower { "td" "th" } member?
!             pick last>> f = and
!         ] [ drop in-select >>insertion-mode ] }
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!         { [ dup name>> >lower "select" = ] [ drop in-select >>insertion-mode ] }
!     } cond
!     ;

: temporary-buffer-attribute? ( document -- ? )
    return-state>>
    {
        attribute-value-unquoted-state
        attribute-value-single-quoted-state
        attribute-value-double-quoted-state
    } member? ;

! name, public/system identifier should not be empty strings
! until the state machine demands it
TUPLE: doctype
    name
    public-identifier
    system-identifier
    quirks? ;

: <doctype> ( -- doctype )
    doctype new ; inline

: new-doctype-from-ch ( ch document -- )
    [
        doctype new
            swap ?1sbuf >>name
    ] dip doctype<< ; inline

: new-doctype-with-quirks ( document -- )
    <doctype> t >>quirks? >>doctype drop ;

TUPLE: tag self-closing? name attributes children end-tag ;

: <tag> ( -- tag )
    tag new
        SBUF" " clone >>name
        V{ } clone >>attributes
        V{ } clone >>children ;

TUPLE: end-tag self-closing? name attributes ;

: <end-tag> ( -- tag )
    end-tag new
        SBUF" " clone >>name
        V{ } clone >>attributes ;

: new-tag ( document -- )
    <tag> >>tag drop ;

: new-end-tag ( document -- )
    <end-tag> >>tag drop ;

: set-self-closing ( document -- )
    tag>> t >>self-closing? drop ;

: <document> ( -- document )
    document new
        V{ } clone >>tree
        initial-mode >>insertion-mode
        <doctype> >>doctype
        t >>frameset-ok?
        ! SBUF" " clone >>tag-name
        SBUF" " clone >>attribute-name
        SBUF" " clone >>attribute-value
        SBUF" " clone >>temporary-buffer
        SBUF" " clone >>comment-token
        V{ } clone >>open-elements
    ; inline

TUPLE: comment open payload close ;

: <comment> ( payload -- comment )
    comment new
        swap >>payload ; inline

: force-quirks ( document -- )
    doctype>> t >>quirks? drop ;

: initialize-doctype-name ( document -- )
    [ SBUF" " clone ] dip doctype>> name<< ;

: initialize-doctype-public-identifier ( document -- )
    [ SBUF" " clone ] dip doctype>> public-identifier<< ;

: initialize-doctype-system-identifier ( document -- )
    [ SBUF" " clone ] dip doctype>> system-identifier<< ;

: push-doctype-name ( ch document -- )
    doctype>> name>> push ;

: push-doctype-public-identifier ( ch document -- )
    doctype>> public-identifier>> push ;

: push-doctype-system-identifier ( ch document -- )
    doctype>> system-identifier>> push ;

! XXX: not html5 spec, fix
ERROR: unmatched-closing-tag-error stack tag ;

: unclosed-tag? ( obj -- ? )
    { [ tag? ] [ end-tag>> not ] } 1&& ; inline

:: find-matching-tag ( name stack -- seq )
    stack [ { [ unclosed-tag? ] [ name>> name = ] } 1&& ] find-last drop [
        stack swap shorten*
    ] [
        stack name unmatched-closing-tag-error
    ] if* ;

DEFER: tree-insert
GENERIC: tree-insert* ( document obj insertion-mode -- document )

: limited-quirks-mode? ( doctype -- ? )
    {
        [ public-identifier>> "-//W3C//DTD XHTML 1.0 Frameset//" head? ]
        [ public-identifier>> "-//W3C//DTD XHTML 1.0 Transitional//" head? ]
        [ { [ system-identifier>> ] [ public-identifier>> "-//W3C//DTD HTML 4.01 Frameset//" head? ] } 1&& ]
        [ { [ system-identifier>> ] [ public-identifier>> "-//W3C//DTD HTML 4.01 Transitional//" head? ] } 1&& ]
    } 1|| ;

! https://html.spec.whatwg.org/multipage/parsing.html#the-initial-insertion-mode
M: initial-mode tree-insert*
    drop {
        { [ dup "\t\n\f\r\s" member? ] [ drop ] }
        { [ dup doctype? ] [
            >>tree-doctype before-html-mode >>insertion-mode
        ] }
        { [ dup comment? ] [ over tree>> push ] }
        { [ dup tag? ] [ over tree>> push ] }
        { [ dup end-tag? ] [
            dup name>> pick tree>> find-matching-tag
            unclip
                swap >>children
                swap >>end-tag
            over tree>> push
        ] }
        [
            over iframe-srcdoc?>> [
                over parser-cannot-change-mode-flag>> [
                    [ t >>quirks-mode? ] dip
                ] unless
            ] [
                "must be iframe-srcdoc here" throw
            ] if
            ! reprocess the token
            before-html-mode >>insertion-mode tree-insert
        ]
    } cond ;

! https://html.spec.whatwg.org/multipage/parsing.html#the-before-html-insertion-mode
M: before-html-mode tree-insert*
    drop {
        { [ dup doctype? ] [ drop ] }
        { [ dup comment? ] [ over tree>> push ] }
        { [ dup "\t\n\f\r\s" member? ] [ drop ] }
        { [ dup { [ tag? ] [ name>> "html" = ] } 1&& ] [
            over tree>> push
            before-head-mode >>insertion-mode
        ] }
        ! these tags are handled in the default case
        { [ dup { [ end-tag? ] [ name>> { "head" "body" "html" "br" } member? not ] } 1&& ] [
            ! error end-tag, ignore
            drop
        ] }
        [
            ! Create missing html tag and reprocess the token
            <tag> "html" >>name pick tree>> push
            before-head-mode >>insertion-mode tree-insert
        ]
    } cond ;

M: before-head-mode tree-insert*
    drop {
        { [ dup "\t\n\f\r\s" member? ] [ drop ] }
        { [ dup comment? ] [ over tree>> push ] }
        { [ dup doctype? ] [ drop ] }
        { [ dup { [ tag? ] [ name>> "html" = ] } 1&& ] [
            ! XXX: in-body-mode rules here for html tag
            ! B
            ! over tree>> push
            ! before-head-mode >>insertion-mode
            "handle html in-body-mode here" throw
        ] }
        { [ dup { [ tag? ] [ name>> "head" = ] } 1&& ] [
            [ swap tree>> push ]
            [ >>head-element-pointer drop ]
            [ drop in-head-mode >>insertion-mode ] 2tri
        ] }
        ! these tags are handled in the default case
        { [ dup { [ end-tag? ] [ name>> { "head" "body" "html" "br" } member? not ] } 1&& ] [
            ! error end-tag, ignore
            drop
        ] }
        ! ignore tag
        { [ dup tag? ] [ drop ] }
        [
            ! Create missing html tag and reprocess the token
            <tag>
            [ "head" >>name pick tree>> push ]
            [ >>head-element-pointer ] bi
            in-head-mode >>insertion-mode tree-insert
        ]
    } cond ;

M: in-head-mode tree-insert*
    drop {
        { [ dup "\t\n\f\r\s" member? ] [ over tree>> push ] }
        { [ dup comment? ] [ over tree>> push ] }
        { [ dup doctype? ] [ drop ] }
        { [ dup { [ tag? ] [ name>> "html" = ] } 1&& ] [
            ! XXX: in-body-mode rules here for html tag
            ! B
            ! over tree>> push
            ! before-head-mode >>insertion-mode
            "handle html in-body-mode here" throw
            unimplemented*
        ] }
        { [ dup { [ tag? ] [ name>> { "base" "basefont" "bgsound" "link" } member? ] } 1&& ] [
            ! non-void-html-element-start-tag-with-trailing-solidus soft error if not self-closing
            unimplemented*
        ] }
        { [ dup { [ tag? ] [ name>> "meta" = ] } 1&& ] [
            unimplemented*
        ] }
        { [ dup { [ tag? ] [ name>> "title" = ] } 1&& ] [
            ! https://html.spec.whatwg.org/multipage/parsing.html#generic-rcdata-element-parsing-algorithm
            "insert title node" throw
            unimplemented*
        ] }
        { [
            dup {
                [ { [ tag? ] [ name>> "noscript" = ] [ scripting?>> ] } 1&& ]
                [ { [ tag? ] [ name>> { "noframes" "style" } member? ] } 1&& ]
            } 1||
        ] [
            ! https://html.spec.whatwg.org/multipage/parsing.html#generic-raw-text-element-parsing-algorithm
            unimplemented*
        ] }
        { [ dup { [ tag? ] [ name>> "noscript" = ] [ scripting?>> not ] } 1&& ] [
            unimplemented*
            over tree>> push
            in-head-noscript-mode >>insertion-mode
        ] }
        { [ dup { [ tag? ] [ name>> "script" = ] } 1&& ] [
            unimplemented*
            text-mode >>insertion-mode
        ] }
        { [ dup { [ end-tag? ] [ name>> "head" = ] } 1&& ] [
            over tree>> last end-tag<<
            after-head-mode >>insertion-mode
        ] }
        { [ dup { [ end-tag? ] [ name>> { "body" "html" "br" } member? ] } 1&& ] [
            ! non-void-html-element-start-tag-with-trailing-solidus soft error if not self-closing
            unimplemented*
        ] }
        { [ dup { [ tag? ] [ name>> "template" = ] } 1&& ] [
            unimplemented*
            in-template-mode >>insertion-mode
        ] }
        { [ dup { [ end-tag? ] [ name>> "template" = ] } 1&& ] [
            unimplemented*
        ] }
        ! XXX: revisit this
        { [ dup {
            [ { [ tag? ] [ name>> "head" = ] } 1&& ]
            [ end-tag? ]
            } 1|| ] [ drop "ignore here" throw ] }
        [
            ! end head tag should be here, pop off, reprocess
            over tree>> pop swap >>end-tag
            after-head-mode >>insertion-mode "omg" throw
        ]
    } cond ;

M: in-head-noscript-mode tree-insert* drop unimplemented* ;

M: after-head-mode tree-insert*
    drop {
        { [ dup "\t\n\f\r\s" member? ] [ over tree>> push ] }
        { [ dup comment? ] [ over tree>> push ] }
        { [ dup doctype? ] [ drop ] }
        { [ dup { [ tag? ] [ name>> "html" = ] } 1&& ] [
            ! XXX: in-body-mode rules here for html tag
            ! B
            ! over tree>> push
            ! before-head-mode >>insertion-mode
            "handle html in-body-mode here" throw
            unimplemented*
        ] }
        { [ dup { [ tag? ] [ name>> "html" = ] } 1&& ] [
            unimplemented*
        ] }
        { [ dup { [ tag? ] [ name>> "body" = ] } 1&& ] [
            over tree>> push
            f >>frameset-ok?
            in-body-mode >>insertion-mode
        ] }
        { [ dup { [ tag? ] [ name>> "frameset" = ] } 1&& ] [
            unimplemented*
        ] }
        { [ dup { [ tag? ] [
            name>> {
                "base" "basefont" "bgsound" "link" "meta"
                "noframes" "script" "style" "template" "title"
            } member? ] } 1&&
        ] [
            unimplemented*
        ] }
        { [ dup { [ end-tag? ] [ name>> "template" = ] } 1&& ] [
            unimplemented*
        ] }
        ! same as default case
        ! { [ dup { [ end-tag? ] [ name>> { "body" "html" "br" } member? not ] } 1&& ] [
        !     unimplemented*
        ! ] }
        { [
            dup {
                [ { [ tag? ] [ name>> "head" = ] } 1&& ]
                [ { [ end-tag? ] [ name>> { "body" "html" "br" } member? not ] } 1&& ]
            } 1||
        ] [
            "omg revisit this" throw
            unimplemented*
        ] }
        [
            B
            <tag> "body" >>name pick tree>> push
            in-body-mode >>insertion-mode tree-insert
        ]
    } cond ;

M: in-body-mode tree-insert*
    drop {
        { [ dup CHAR: \0 = ] [ drop ] }
        { [ dup "\t\n\f\r\s" member? ] [ over tree>> push ] }
        { [ dup comment? ] [ over tree>> push ] }
        { [ dup doctype? ] [ drop ] }
        { [ dup { [ tag? ] [ name>> "html" = ] } 1&& ] [ drop ] }
        { [ dup {
            [
                {
                    [ tag? ]
                    [
                        name>> {
                            "base" "basefont" "bgsound" "link" "meta"
                            "noframes" "script" "style" "template" "title"
                        } member?
                    ]
                } 1&&
            ] [
                { [ end-tag? ] [ name>> "template" = ] } 1&&
            ] } 1||
        ] [
            unimplemented*
        ] }
        ! XXX: parse error
        { [ dup { [ tag? ] [ name>> "body" = ] } 1&& ] [ drop unimplemented* ] }
        { [ dup { [ tag? ] [ name>> "frameset" = ] } 1&& ] [ drop unimplemented* ] }
        ! XXX: eof
        ! { [ ] [ ] }
        { [ dup { [ end-tag? ] [ name>> "body" = ] } 1&& ] [
            "body" pick tree>> find-matching-tag
            unclip
                swap >>children
                swap >>end-tag
            over tree>> push

            after-body-mode >>insertion-mode
        ] }
        { [ dup { [ end-tag? ] [ name>> "html" = ] } 1&& ] [ drop unimplemented* ] }
        ! { [ ] [ ] }
        [
            unimplemented*
        ]
    } cond ;

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
M: after-body-mode tree-insert*
    drop {
        { [ dup "\t\n\f\r\s" member? ] [ over tree>> push ] }
        { [ dup comment? ] [ over tree>> push ] }
        { [ dup doctype? ] [ drop ] }
        { [ dup { [ tag? ] [ name>> "html" = ] } 1&& ] [
            unimplemented*
        ] }
        { [ dup { [ end-tag? ] [ name>> "html" = ] } 1&& ] [
            ! XXX: make this a function
            "html" pick tree>> find-matching-tag
            unclip
                swap >>children
                swap >>end-tag
            over tree>> push

            after-after-body-mode >>insertion-mode
        ] }
        [
            unimplemented*
        ]
    } cond ;
M: in-frameset-mode tree-insert* drop unimplemented* ;
M: after-frameset-mode tree-insert* drop unimplemented* ;

M: after-after-body-mode tree-insert*
    drop {
        { [ dup comment? ] [ over tree>> push ] }
        { [ dup doctype? ] [ unimplemented*  ] }
        { [ dup "\t\n\f\r\s" member? ] [ unimplemented*  ] }
        { [ dup { [ tag? ] [ name>> "html" = ] } 1&& ] [ unimplemented* ] }
        ! eof
        { [ dup f = ] [ drop ] }
        [
            ! XXX: parse error
            [ in-body-mode >>insertion-mode ] dip tree-insert
        ]
    } cond ;

M: after-after-frameset-mode tree-insert* drop unimplemented* ;

: tree-insert ( document obj -- document )
    over insertion-mode>> tree-insert* ;

MEMO: load-entities ( -- assoc )
    "vocab:html5/entities.json" utf8 file-contents json> ;

MEMO: entities-suffix-array ( -- assoc )
    load-entities keys >suffix-array ;

: lookup-entity ( string -- entity/string ? )
    load-entities ?at ;

: named-character-match? ( document -- prefix? exact? )
    temporary-buffer>>
    [ entities-suffix-array query f like ]
    [ last CHAR: ; = ] bi ;

ERROR: unknown-named-entity entity ;
: take-named-character ( document -- )
    dup
    temporary-buffer>> >string lookup-entity [
        "characters" of
        SBUF" " clone-like >>temporary-buffer drop
    ] [
        unknown-named-entity
    ] if ;

! XXX: remove the tag>> name>> push part
: push-tag-name ( ch document -- )
    [ tag>> name>> push ]
    [
        2drop ! tag-name>> push
    ] 2bi ;
: push-attribute-name ( ch document -- ) attribute-name>> push ;
: push-attribute-value ( ch document -- ) attribute-value>> push ;
: push-comment-token ( ch document -- ) comment-token>> push ;
: push-all-comment-token ( string document -- ) comment-token>> push-all ;

ERROR: invalid-return-state obj ;
: check-return-state ( obj -- return-state )
    dup word? [ invalid-return-state ] unless ;

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

: emit-eof ( document -- )
    "emit-eof" print
    f tree-insert drop ;
: emit-char ( char document -- ) drop "emit-char: " write 1string . ;
: emit-string ( char document -- ) drop "emit-string: " write . ;
: emit-tag ( document -- )
    "emit-tag: " write
    {
        [ tag>> [ name>> >string ] [ name<< ] bi ]
        [ push-attribute ]
        [ tag>> . ]
        [ dup tag>> tree-insert drop ]
        [ f >>tag drop ]
    } cleave ;
: emit-end-tag ( document -- )
    "emit-end-tag: " write
    [ tag>> . ]
    [ f >>tag drop ] bi ;
: emit-comment-token ( document -- )
    "emit-comment-token: " write
    {
        [ comment-token>> >string . ]
        [ dup comment-token>> >string <comment> tree-insert drop ]
        [ SBUF" " clone >>comment-token drop ]
    } cleave ;
: emit-doctype ( document -- )
    "emit-doctype: " write dup doctype>> .
    {
        [ doctype>> [ >string ] change-name drop ]
        [
            ! XXX: handle iframe srcdoc document
            dup { [ doctype>> name>> "html" = not ] [ parser-cannot-change-mode-flag>> not ] } 1&& [
                t >>quirks-mode?
            ] [
                dup { [ iframe-srcdoc?>> not ] [ parser-cannot-change-mode-flag>> not ] } 1&& [
                    dup doctype>> limited-quirks-mode? [ t >>limited-quirks-mode? ] when
                ] when
            ] if
            drop
        ]
        [ dup doctype>> tree-insert drop ]
        [ f >>doctype drop ]
    } cleave ;

: reset-temporary-buffer ( document -- ) SBUF" " clone temporary-buffer<< ;
: ch>new-temporary-buffer ( ch document -- ) [ 1sbuf ] dip temporary-buffer<< ;
: string>new-temporary-buffer ( string document -- ) [ SBUF" " clone-like ] dip temporary-buffer<< ;
: temporary-buffer-last ( document -- ch/f ) temporary-buffer>> ?last ;
: push-temporary-buffer ( ch document -- ) temporary-buffer>> push ;
: push-all-temporary-buffer ( string document -- ) temporary-buffer>> push-all ;

: flush-temporary-buffer ( document -- )
    "flush-temporary-buffer: " write
    [ [ temporary-buffer>> ] keep [ emit-char ] curry each ]
    [ SBUF" " clone >>temporary-buffer drop ] bi ;

: emit-temporary-buffer-with ( string document -- )
    [ temporary-buffer>> push-all ]
    [ flush-temporary-buffer ] bi ;

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

: (return-state) ( document n/f string ch/f -- document n'/f string )
    reach [ f ] change-return-state drop check-return-state
    execute( document n/f string ch/f -- document n'/f string ) ;

: return-state ( document n/f string -- document n'/f string )
    pick [ f ] change-return-state drop check-return-state
    execute( document n/f string -- document n'/f string ) ;

: (data-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: & = ] [ drop [ \ data-state >>return-state ] 2dip character-reference-state ] }
        { [ dup CHAR: < = ] [ drop tag-open-state ] }
        { [ dup CHAR: \0 = ] [ unexpected-null-character ] }
        { [ dup f = ] [ drop pick emit-eof ] }
        [ reach emit-char data-state ]
    } cond ;

: data-state ( document n/f string -- document n'/f string )
    take-char (data-state) ;


: (rcdata-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: & = ] [ drop [ \ rcdata-state >>return-state ] 2dip character-reference-state ] }
        { [ dup CHAR: < = ] [ drop rcdata-less-than-sign-state ] }
        { [ dup CHAR: \0 = ] [ unexpected-null-character ] }
        { [ dup f = ] [ drop pick emit-eof ] }
        [ reach emit-char rcdata-state ]
    } cond ;

: rcdata-state ( document n/f string -- document n'/f string )
    take-char (rcdata-state) ;


: (rawtext-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: < = ] [ drop rawtext-less-than-sign-state ] }
        { [ dup CHAR: \0 = ] [ drop unexpected-null-character ] }
        { [ dup f = ] [ drop pick emit-eof ] }
        [ reach emit-char rawtext-state ]
    } cond ;

: rawtext-state ( document n/f string -- document n'/f string )
    take-char (rawtext-state) ;


: (script-data-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: < = ] [ drop script-data-less-than-sign-state ] }
        { [ dup CHAR: \0 = ] [ drop unexpected-null-character ] }
        { [ dup f = ] [ drop pick emit-eof ] }
        [ reach emit-char script-data-state ]
    } cond ;

: script-data-state ( document n/f string -- document n'/f string )
    take-char (script-data-state) ;


: (plaintext-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: \0 = ] [ drop unexpected-null-character ] }
        { [ dup f = ] [ drop pick emit-eof ] }
        [ reach emit-char plaintext-state ]
    } cond ;

: plaintext-state ( document n/f string -- document n'/f string )
    take-char (plaintext-state) ;


: (tag-open-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alpha? ] [ reach new-tag (tag-name-state) ] }
        { [ dup CHAR: ! = ] [ drop markup-declaration-open-state ] }
        { [ dup CHAR: / = ] [ drop end-tag-open-state ] }
        { [ dup CHAR: ? = ] [ unexpected-question-mark-instead-of-tag-name ] }
        { [ dup f = ] [ eof-before-tag-name ] }
        [ invalid-first-character-of-tag-name ]
    } cond ;

: tag-open-state ( document n/f string -- document n'/f string )
    take-char (tag-open-state) ;


: (end-tag-open-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alpha? ] [ reach new-end-tag (tag-name-state) ] }
        { [ dup CHAR: > = ] [ missing-end-tag-name ] }
        { [ dup f = ] [ eof-before-tag-name ] }
        [ invalid-first-character-of-tag-name ]
    } cond ;

: end-tag-open-state ( document n/f string -- document n'/f string )
    take-char (end-tag-open-state) ;


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
    take-char (tag-name-state) ;


: (rcdata-less-than-sign-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: / = ] [ drop pick reset-temporary-buffer rcdata-end-tag-open-state ] }
        [ [ CHAR: < reach emit-char ] dip (rcdata-state) ]
    } cond ;

: rcdata-less-than-sign-state ( document n/f string -- document n'/f string )
    take-char (rcdata-less-than-sign-state) ;


: (rcdata-end-tag-open-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alpha? ] [ reach new-end-tag (rcdata-end-tag-name-state) ] }
        [ [ CHAR: < reach emit-char ] dip (rcdata-state) ]
    } cond ;

: rcdata-end-tag-open-state ( document n/f string -- document n'/f string )
    take-char (rcdata-end-tag-open-state) ;


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
    take-char (rcdata-end-tag-name-state) ;


: (rawtext-less-than-sign-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: / = ] [ drop pick reset-temporary-buffer rawtext-end-tag-open-state ] }
        [ [ CHAR: < reach emit-char ] dip (rawtext-state) ]
    } cond ;

: rawtext-less-than-sign-state ( document n/f string -- document n'/f string )
    take-char (rawtext-less-than-sign-state) ;


: (rawtext-end-tag-open-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alpha? ] [ reach new-end-tag (rawtext-end-tag-name-state) ] }
        [ [ CHAR: < reach emit-char ] dip (rawtext-state) ]
    } cond ;

: rawtext-end-tag-open-state ( document n/f string -- document n'/f string )
    take-char (rawtext-end-tag-open-state) ;


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
    take-char (rawtext-end-tag-name-state) ;


: (script-data-less-than-sign-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: / = ] [ drop pick reset-temporary-buffer script-data-end-tag-open-state ] }
        { [ dup CHAR: ! = ] [ drop "<!" reach emit-string script-data-escape-start-state ] }
        [ [ CHAR: < reach emit-char ] dip (script-data-state) ]
    } cond ;

: script-data-less-than-sign-state ( document n/f string -- document n'/f string )
    take-char (script-data-less-than-sign-state) ;


: (script-data-end-tag-open-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alpha? ] [ reach new-end-tag (script-data-end-tag-name-state) ] }
        [ [ "</" reach emit-string ] dip (script-data-state) ]
    } cond ;

: script-data-end-tag-open-state ( document n/f string -- document n'/f string )
    take-char (script-data-end-tag-open-state) ;


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
    take-char (script-data-end-tag-name-state) ;


: (script-data-escape-start-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop script-data-escape-start-dash-state ] }
        [ (script-data-state) ]
    } cond ;

: script-data-escape-start-state ( document n/f string -- document n'/f string )
    take-char (script-data-escape-start-state) ;


: (script-data-escape-start-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop script-data-escaped-dash-dash-state ] }
        [ (script-data-state) ]
    } cond ;

: script-data-escape-start-dash-state ( document n/f string -- document n'/f string )
    take-char (script-data-escape-start-dash-state) ;


: (script-data-escaped-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop script-data-escaped-dash-state ] }
        { [ dup CHAR: < = ] [ drop script-data-escaped-less-than-sign-state ] }
        { [ dup CHAR: \0 = ] [ unexpected-null-character CHAR: replacement-character unimplemented* ] }
        { [ dup f = ] [ eof-in-script-html-comment-like-text ] }
        [ reach emit-char script-data-escaped-state ]
    } cond ;

: script-data-escaped-state ( document n/f string -- document n'/f string )
    take-char (script-data-escaped-state) ;


: (script-data-escaped-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop script-data-escaped-dash-dash-state ] }
        { [ dup CHAR: < = ] [ drop script-data-escaped-less-than-sign-state ] }
        { [ dup CHAR: \0 = ] [ unexpected-null-character script-data-escaped-state ] }
        { [ dup f = ] [ eof-in-script-html-comment-like-text ] }
        [ reach emit-char script-data-escaped-state ]
    } cond ;

: script-data-escaped-dash-state ( document n/f string -- document n'/f string )
    take-char (script-data-escaped-dash-state) ;


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
    take-char (script-data-escaped-dash-dash-state) ;


: (script-data-escaped-less-than-sign-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: / = ] [ drop pick reset-temporary-buffer script-data-escaped-end-tag-open-state ] }
        { [ dup ascii-alpha? ] [ [ pick reset-temporary-buffer CHAR: < reach emit-char ] dip (script-data-double-escape-start-state) ] }
        [ [ CHAR: < reach emit-char ] dip (script-data-escaped-state) ]
    } cond ;

: script-data-escaped-less-than-sign-state ( document n/f string -- document n'/f string )
    take-char (script-data-escaped-less-than-sign-state) ;


: (script-data-escaped-end-tag-open-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alpha? ] [ [ pick new-end-tag ] dip (script-data-escaped-end-tag-name-state) ] }
        [ [ "</" reach emit-string ] dip (script-data-escaped-state) ]
    } cond ;

: script-data-escaped-end-tag-open-state ( document n/f string -- document n'/f string )
    take-char (script-data-escaped-end-tag-open-state) ;


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
    take-char (script-data-escaped-end-tag-name-state) ;


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
    take-char (script-data-double-escape-start-state) ;


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
    take-char (script-data-double-escaped-state) ;


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
    take-char (script-data-double-escaped-dash-state) ;


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
    take-char (script-data-double-escaped-dash-dash-state) ;


: (script-data-double-escaped-less-than-sign-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: / = ] [ reach emit-char pick reset-temporary-buffer script-data-double-escape-end-state ] }
        [ (script-data-double-escaped-state) ]
    } cond ;

: script-data-double-escaped-less-than-sign-state ( document n/f string -- document n'/f string )
    take-char (script-data-double-escaped-less-than-sign-state) ;


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
    take-char (script-data-double-escape-end-state) ;


: (before-attribute-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-attribute-name-state ] }
        { [ dup "/>" member? ] [ (after-attribute-name-state) ] }
        { [ dup f = ] [ (after-attribute-name-state) ] }
        { [ dup CHAR: = = ] [ unexpected-equals-sign-before-attribute-name ] }
        [ reach push-attribute (attribute-name-state) ]
    } cond ;

: before-attribute-name-state ( document n/f string -- document n'/f string )
    take-char (before-attribute-name-state) ;


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
    take-char (attribute-name-state) ;


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
    take-char (after-attribute-name-state) ;


: (before-attribute-value-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-attribute-name-state ] }
        { [ dup CHAR: " = ] [ drop attribute-value-double-quoted-state ] }
        { [ dup CHAR: ' = ] [ drop attribute-value-single-quoted-state ] }
        { [ dup CHAR: > = ] [ drop missing-attribute-value ] }
        [ (attribute-value-unquoted-state) ]
    } cond ;

: before-attribute-value-state ( document n/f string -- document n'/f string )
    take-char (before-attribute-value-state) ;


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
    take-char (attribute-value-double-quoted-state) ;


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
    take-char (attribute-value-single-quoted-state) ;


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
    take-char (attribute-value-unquoted-state) ;


: (after-attribute-value-quoted-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-attribute-name-state ] }
        { [ dup CHAR: / = ] [ drop self-closing-start-tag-state ] }
        { [ dup CHAR: > = ] [ drop pick emit-tag data-state ] }
        { [ dup f = ] [ eof-in-tag ] }
        [ missing-whitespace-between-attributes (before-attribute-name-state) ]
    } cond ;

: after-attribute-value-quoted-state ( document n/f string -- document n'/f string )
    take-char (after-attribute-value-quoted-state) ;


: (self-closing-start-tag-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: > = ] [ drop pick [ set-self-closing ] [ emit-tag ] bi data-state ] }
        { [ dup f = ] [ eof-in-tag ] }
        [ unexpected-solidus-in-tag ]
    } cond ;

: self-closing-start-tag-state ( document n/f string -- document n'/f string )
    take-char (self-closing-start-tag-state) ;


: (bogus-comment-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: > = ] [ drop pick emit-comment-token data-state ] }
        { [ dup f = ] [ drop pick [ emit-comment-token ] [ emit-eof ] bi ] }
        { [ dup CHAR: \0 = ] [ drop unexpected-null-character CHAR: replacement-character reach push-comment-token ] }
        [ reach push-comment-token bogus-comment-state ]
    } cond ;

: bogus-comment-state ( document n/f string -- document n'/f string )
    take-char (bogus-comment-state) ;


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
    take-char (comment-start-state) ;


: (comment-start-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop comment-end-state ] }
        { [ dup CHAR: > = ] [ drop abrupt-closing-of-empty-comment ] }
        { [ dup f = ] [ eof-in-comment ] }
        [ [ CHAR: - reach push-comment-token ] dip (comment-state) ]
    } cond ;

: comment-start-dash-state ( document n/f string -- document n'/f string )
    take-char (comment-start-dash-state) ;


: (comment-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: < = ] [ reach push-comment-token comment-less-than-sign-state ] }
        { [ dup CHAR: - = ] [ drop comment-end-dash-state ] }
        { [ dup CHAR: \0 = ] [ drop unexpected-null-character ] }
        { [ dup f = ] [ eof-in-comment ] }
        [ reach push-comment-token comment-state ]
    } cond ;

: comment-state ( document n/f string -- document n'/f string )
    take-char (comment-state) ;


: (comment-less-than-sign-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: ! = ] [ reach push-comment-token comment-less-than-sign-bang-state ] }
        { [ dup CHAR: < = ] [ reach push-comment-token comment-less-than-sign-state ] }
        [ (comment-state) ]
    } cond ;

: comment-less-than-sign-state ( document n/f string -- document n'/f string )
    take-char (comment-less-than-sign-state) ;


: (comment-less-than-sign-bang-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ reach push-comment-token comment-less-than-sign-bang-dash-state ] }
        [ (comment-state) ]
    } cond ;

: comment-less-than-sign-bang-state ( document n/f string -- document n'/f string )
    take-char (comment-less-than-sign-bang-state) ;


: (comment-less-than-sign-bang-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop comment-less-than-sign-bang-dash-dash-state ] }
        [ (comment-end-dash-state) ]
    } cond ;

: comment-less-than-sign-bang-dash-state ( document n/f string -- document n'/f string )
    take-char (comment-less-than-sign-bang-dash-state) ;


: (comment-less-than-sign-bang-dash-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: > = ] [ (comment-end-state) ] }
        { [ dup f = ] [ (comment-end-state) ] }
        [ nested-comment (comment-end-state) ]
    } cond ;

: comment-less-than-sign-bang-dash-dash-state ( document n/f string -- document n'/f string )
    take-char (comment-less-than-sign-bang-dash-dash-state) ;


: (comment-end-dash-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop comment-end-state ] }
        { [ dup f = ] [ eof-in-comment ] }
        [ [ CHAR: - reach push-comment-token ] dip (comment-state) ]
    } cond ;

: comment-end-dash-state ( document n/f string -- document n'/f string )
    take-char (comment-end-dash-state) ;


: (comment-end-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: > = ] [ drop pick emit-comment-token data-state ] }
        { [ dup CHAR: ! = ] [ drop comment-end-bang-state ] }
        { [ dup CHAR: - = ] [ reach push-comment-token comment-end-state ] }
        { [ dup f = ] [ drop eof-in-comment pick [ emit-comment-token ] [ emit-eof ] bi ] }
        [ [ "--" reach push-all-comment-token ] dip (comment-state) ]
    } cond ;

: comment-end-state ( document n/f string -- document n'/f string )
    take-char (comment-end-state) ;


: (comment-end-bang-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: - = ] [ drop comment-end-dash-state ] }
        { [ dup CHAR: > = ] [ drop incorrectly-closed-comment pick emit-comment-token data-state ] }
        { [ dup f = ] [ eof-in-comment ] }
        [ [ "--!" reach push-all-comment-token ] dip (comment-state) ]
    } cond ;

: comment-end-bang-state ( document n/f string -- document n'/f string )
    take-char (comment-end-bang-state) ;


: (doctype-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-doctype-name-state ] }
        { [ dup CHAR: > = ] [ (before-doctype-name-state) ] }
        { [ dup f = ] [ drop eof-in-doctype pick [ new-doctype-with-quirks ] [ emit-doctype ] [ emit-eof ] tri ] }
        [ missing-whitespace-before-doctype-name ]
    } cond ;

: doctype-state ( document n/f string -- document n'/f string )
    take-char (doctype-state) ;


: (before-doctype-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-doctype-name-state ] }
        { [ dup ascii-upper-alpha? ] [ 0x20 + reach new-doctype-from-ch doctype-name-state ] }
        { [ dup CHAR: \0 = ] [
            drop
            unexpected-null-character
            CHAR: replacement-character reach new-doctype-from-ch
            doctype-name-state
        ] }
        { [ dup CHAR: > = ] [
            drop missing-doctype-name
            pick [ new-doctype-with-quirks ] [ emit-doctype ] bi
        ] }
        { [ dup f = ] [
            drop eof-in-doctype
            pick [ new-doctype-with-quirks ] [ emit-doctype ] [ emit-eof ] tri
        ] }
        [ reach new-doctype-from-ch doctype-name-state ]
    } cond ;

: before-doctype-name-state ( document n/f string -- document n'/f string )
    take-char (before-doctype-name-state) ;


: (doctype-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop after-doctype-name-state ] }
        { [ dup CHAR: > = ] [ drop pick emit-doctype data-state ] }
        { [ dup ascii-upper-alpha? ] [ 0x20 + reach push-doctype-name doctype-name-state ] }
        { [ dup CHAR: \0 = ] [
            drop unexpected-null-character
            CHAR: replacement-character pick push-doctype-name
            doctype-name-state
        ] }
        { [ dup f = ] [ drop eof-in-doctype pick [ emit-doctype ] [ emit-eof ] bi ] } ! force-quirks on for doctype
        [ reach push-doctype-name doctype-name-state ]
    } cond ;

: doctype-name-state ( document n/f string -- document n'/f string )
    take-char (doctype-name-state) ;


: (after-doctype-name-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop after-doctype-name-state ] }
        { [ dup CHAR: > = ] [ drop pick emit-doctype data-state ] }
        { [ dup f = ] [ eof-in-doctype ] }
        { [ [ "PUBLIC" take-from-insensitive? ] dip swap ] [ drop after-doctype-public-keyword-state ] }
        { [ [ "SYSTEM" take-from-insensitive? ] dip swap ] [ drop after-doctype-system-keyword-state ] }
        [ invalid-character-sequence-after-doctype-name ]
    } cond ;

: after-doctype-name-state ( document n/f string -- document n'/f string )
    take-char (after-doctype-name-state) ;


: (after-doctype-public-keyword-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop before-doctype-public-identifier-state ] }
        { [ dup CHAR: " = ] [ missing-whitespace-after-doctype-public-keyword ] }
        { [ dup CHAR: ' = ] [ missing-whitespace-after-doctype-public-keyword ] }
        { [ dup CHAR: > = ] [ drop missing-doctype-public-identifier force-quirks data-state ] }
        { [ dup f = ] [ drop eof-in-doctype pick [ emit-doctype ] [ emit-eof ] bi ] }
        [
            missing-quote-before-doctype-public-identifier
            [ reach force-quirks ] dip
            (bogus-doctype-state)
        ]
    } cond ;

: after-doctype-public-keyword-state ( document n/f string -- document n'/f string )
    take-char (after-doctype-public-keyword-state) ;


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
            pick [ force-quirks ] [ emit-doctype ] bi
            data-state
        ] }
        { [ dup f = ] [ drop eof-in-doctype pick [ emit-doctype ] [ emit-eof ] bi ] }
        [
            missing-quote-before-doctype-public-identifier
            [ reach force-quirks ] dip
            (bogus-doctype-state)
        ]
    } cond ;

: before-doctype-public-identifier-state ( document n/f string -- document n'/f string )
    take-char (before-doctype-public-identifier-state) ;


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
            pick [ force-quirks ] [ emit-doctype ] bi
            data-state
        ] }
        { [ dup f = ] [
            drop eof-in-doctype
            pick [ force-quirks ] [ emit-doctype ] [ emit-eof ] tri
        ] }
        [ reach push-doctype-public-identifier doctype-public-identifier-double-quoted-state ]
    } cond ;

: doctype-public-identifier-double-quoted-state ( document n/f string -- document n'/f string )
    take-char (doctype-public-identifier-double-quoted-state) ;


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
            pick [ force-quirks ] [ emit-doctype ] bi
            data-state
        ] }
        { [ dup f = ] [
            drop eof-in-doctype
            pick [ force-quirks ] [ emit-doctype ] [ emit-eof ] tri
        ] }
        [ reach push-doctype-public-identifier doctype-public-identifier-single-quoted-state ]
    } cond ;

: doctype-public-identifier-single-quoted-state ( document n/f string -- document n'/f string )
    take-char (doctype-public-identifier-single-quoted-state) ;


: (after-doctype-public-identifier-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop between-doctype-public-and-system-identifiers-state ] }
        { [ dup CHAR: > = ] [
            drop pick emit-doctype
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
        { [ dup f = ] [ drop eof-in-doctype pick [ force-quirks ] [ emit-doctype ] [ emit-eof ] tri ] }
        [
            missing-quote-before-doctype-system-identifier
            [ reach force-quirks ] dip
            (bogus-doctype-state)
        ]
    } cond ;

: after-doctype-public-identifier-state ( document n/f string -- document n'/f string )
    take-char (after-doctype-public-identifier-state) ;


: (between-doctype-public-and-system-identifiers-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop between-doctype-public-and-system-identifiers-state ] }
        { [ dup CHAR: > = ] [
            drop pick emit-doctype
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
        { [ dup f = ] [ drop eof-in-doctype pick [ force-quirks ] [ emit-doctype ] [ emit-eof ] tri ] }
        [
            missing-quote-before-doctype-system-identifier
            [ reach force-quirks ] dip
            (bogus-doctype-state)
        ]
    } cond ;

: between-doctype-public-and-system-identifiers-state ( document n/f string -- document n'/f string )
    take-char (between-doctype-public-and-system-identifiers-state) ;


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
            pick [ force-quirks ] [ emit-doctype ] bi
            data-state
        ] }
        { [ dup f = ] [ drop eof-in-doctype pick [ force-quirks ] [ emit-doctype ] [ emit-eof ] tri ] }
        [
            missing-quote-before-doctype-system-identifier
            [ reach force-quirks ] dip
            (bogus-doctype-state)
        ]
    } cond ;

: after-doctype-system-keyword-state ( document n/f string -- document n'/f string )
    take-char (after-doctype-system-keyword-state) ;


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
            pick [ force-quirks ] [ emit-doctype ] bi
            data-state
        ] }
        { [ dup f = ] [ drop eof-in-doctype pick [ emit-doctype ] [ emit-eof ] bi ] }
        [
            missing-quote-before-doctype-system-identifier
            [ reach force-quirks ] dip
            (bogus-doctype-state)
        ]
    } cond ;

: before-doctype-system-identifier-state ( document n/f string -- document n'/f string )
    take-char (before-doctype-system-identifier-state) ;


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
            pick [ force-quirks ] [ emit-doctype ] bi
            data-state
        ] }
        { [ dup f = ] [
            drop eof-in-doctype
            pick [ force-quirks ] [ emit-doctype ] [ emit-eof ] tri
        ] }
        [ reach push-doctype-system-identifier doctype-system-identifier-double-quoted-state ]
    } cond ;

: doctype-system-identifier-double-quoted-state ( document n/f string -- document n'/f string )
    take-char (doctype-system-identifier-double-quoted-state) ;


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
            pick [ force-quirks ] [ emit-doctype ] bi
            data-state
        ] }
        { [ dup f = ] [
            drop eof-in-doctype
            pick [ force-quirks ] [ emit-doctype ] [ emit-eof ] tri
        ] }
        [ reach push-doctype-system-identifier doctype-system-identifier-single-quoted-state ]
    } cond ;

: doctype-system-identifier-single-quoted-state ( document n/f string -- document n'/f string )
    take-char (doctype-system-identifier-single-quoted-state) ;


: (after-doctype-system-identifier-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "\t\n\f\s" member? ] [ drop after-doctype-system-identifier-state ] }
        { [ dup CHAR: > = ] [
            drop pick emit-doctype
            data-state
        ] }
        { [ dup f = ] [ drop eof-in-doctype pick [ force-quirks ] [ emit-doctype ] [ emit-eof ] tri ] }
        [
            unexpected-character-after-doctype-system-identifier
            [ reach force-quirks ] dip
            (bogus-doctype-state)
        ]
    } cond ;

: after-doctype-system-identifier-state ( document n/f string -- document n'/f string )
    take-char (after-doctype-system-identifier-state) ;


: (bogus-doctype-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: > = ] [ drop pick emit-doctype data-state ] }
        { [ dup CHAR: \0 = ] [ drop unexpected-null-character bogus-doctype-state ] }
        { [ dup f = ] [ drop eof-in-doctype pick emit-eof ] }
        [ drop bogus-doctype-state ]
    } cond ;

: bogus-doctype-state ( document n/f string -- document n'/f string )
    take-char (bogus-doctype-state) ;


: (cdata-section-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: ] = ] [ drop cdata-section-bracket-state ] }
        { [ dup f = ] [ drop eof-in-cdata pick emit-eof ] }
        [ reach emit-char cdata-section-state ]
    } cond ;

: cdata-section-state ( document n/f string -- document n'/f string )
    take-char (cdata-section-state) ;


: (cdata-section-bracket-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: ] = ] [ drop cdata-section-end-state ] }
        [ [ CHAR: ] reach emit-char ] dip (cdata-section-state) ]
    } cond ;

: cdata-section-bracket-state ( document n/f string -- document n'/f string )
    take-char (cdata-section-bracket-state) ;


: (cdata-section-end-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup CHAR: ] = ] [ reach emit-char cdata-section-end-state ] }
        { [ dup CHAR: > = ] [ drop data-state ] }
        [ [ "]]" reach emit-string ] dip (cdata-section-state) ]
    } cond ;

: cdata-section-end-state ( document n/f string -- document n'/f string )
    take-char (cdata-section-end-state) ;


: (character-reference-state) ( document n/f string ch/f -- document n'/f string )
    [ CHAR: & reach ch>new-temporary-buffer ] dip
    {
        { [ dup ascii-alphanumeric? ] [ (named-character-reference-state) ] }
        { [ dup CHAR: # = ] [ reach push-temporary-buffer numeric-character-reference-state ] }
        [ reach flush-temporary-buffer (return-state) ]
    } cond ;

: character-reference-state ( document n/f string -- document n'/f string )
    take-char (character-reference-state) ;


: (named-character-reference-state) ( document n/f string ch/f -- document n'/f string )
    reach push-temporary-buffer
    pick named-character-match?
    [
        drop ! exact match, drop prefix match
        ! XXX: check me
        {
            [ pick temporary-buffer-attribute? ]
            [ pick temporary-buffer>> ?last CHAR: ; = not ]
            [ 3dup peek-from { [ CHAR: = = ] [ ascii-alphanumeric? ] } 1|| ]
        } 0&& [
            unimplemented*
            flush-temporary-buffer
            return-state
        ] [
            pick [ take-named-character ] [ flush-temporary-buffer ] bi return-state
        ] if
    ] [
        ! prefix match?
        [ named-character-reference-state ]
        [ pick flush-temporary-buffer ambiguous-ampersand-state ] if
    ] if ;

: named-character-reference-state ( document n/f string -- document n'/f string )
    take-char (named-character-reference-state) ;


: (ambiguous-ampersand-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-alphanumeric? ] [
            unimplemented*
        ] }
        { [ dup CHAR: ; = ] [ unknown-named-character-reference (return-state) ] }
        [ (return-state) ]
    } cond ;

: ambiguous-ampersand-state ( document n/f string -- document n'/f string )
    take-char (ambiguous-ampersand-state) ;


: (numeric-character-reference-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup "xX" member? ] [ reach push-temporary-buffer hexadecimal-character-reference-start-state ] }
        [ (decimal-character-reference-start-state) ]
    } cond ;

: numeric-character-reference-state ( document n/f string -- document n'/f string )
    take-char (numeric-character-reference-state) ;


: (hexadecimal-character-reference-start-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-hex-digit? ] [ (hexadecimal-character-reference-state) ] }
        [ absence-of-digits-in-numeric-character-reference reach flush-temporary-buffer (return-state) ]
    } cond ;

: hexadecimal-character-reference-start-state ( document n/f string -- document n'/f string )
    take-char (hexadecimal-character-reference-start-state) ;


: (decimal-character-reference-start-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-digit? ] [ (decimal-character-reference-state) ] }
        [ absence-of-digits-in-numeric-character-reference reach flush-temporary-buffer (return-state) ]
    } cond ;

: decimal-character-reference-start-state ( document n/f string -- document n'/f string )
    take-char (decimal-character-reference-start-state) ;


: (hexadecimal-character-reference-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-digit? ] [ unimplemented* ] }
        { [ dup ascii-upper-hex-digit? ] [ unimplemented* ] }
        { [ dup ascii-lower-hex-digit? ] [ unimplemented* ] }
        { [ dup CHAR: ; = ] [ drop numeric-character-reference-end-state ] }
        [ missing-semicolon-after-character-reference ]
    } cond ;

: hexadecimal-character-reference-state ( document n/f string -- document n'/f string )
    take-char (hexadecimal-character-reference-state) ;


: (decimal-character-reference-state) ( document n/f string ch/f -- document n'/f string )
    {
        { [ dup ascii-digit? ] [ unimplemented* ] }
        { [ dup CHAR: ; = ] [ drop numeric-character-reference-end-state ] }
        [ missing-semicolon-after-character-reference ]
    } cond ;

: decimal-character-reference-state ( document n/f string -- document n'/f string )
    take-char (decimal-character-reference-state) ;


: (numeric-character-reference-end-state) ( document n/f string ch/f -- document n'/f string )
    {
        [ missing-semicolon-after-character-reference ]
    } cond ;

: numeric-character-reference-end-state ( document n/f string -- document n'/f string )
    take-char (numeric-character-reference-end-state) ;



: parse-html5 ( string -- document )
    [ <document> 0 ] dip data-state 2drop ;

