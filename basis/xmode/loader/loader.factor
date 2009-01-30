USING: xmode.loader.syntax xmode.tokens xmode.rules
xmode.keyword-map xml.data xml.utilities xml assocs kernel
combinators sequences math.parser namespaces parser
xmode.utilities parser-combinators.regexp io.files accessors ;
IN: xmode.loader

! Based on org.gjt.sp.jedit.XModeHandler

! RULES and its children
<TAGS: parse-rule-tag ( rule-set tag -- )

TAG: PROPS
    parse-props-tag >>props drop ;

TAG: IMPORT
    "DELEGATE" attr swap import-rule-set ;

TAG: TERMINATE
    "AT_CHAR" attr string>number >>terminate-char drop ;

RULE: SEQ seq-rule
    shared-tag-attrs delegate-attr literal-start ;

RULE: SEQ_REGEXP seq-rule
    shared-tag-attrs delegate-attr regexp-attr regexp-start ;

RULE: SPAN span-rule
    shared-tag-attrs delegate-attr match-type-attr span-attrs parse-begin/end-tags init-span-tag ;

RULE: SPAN_REGEXP span-rule
    shared-tag-attrs delegate-attr match-type-attr span-attrs regexp-attr parse-begin/end-tags init-span-tag ;

RULE: EOL_SPAN eol-span-rule
    shared-tag-attrs delegate-attr match-type-attr literal-start init-eol-span-tag ;

RULE: EOL_SPAN_REGEXP eol-span-rule
    shared-tag-attrs delegate-attr match-type-attr regexp-attr regexp-start init-eol-span-tag ;

RULE: MARK_FOLLOWING mark-following-rule
    shared-tag-attrs match-type-attr literal-start ;

RULE: MARK_PREVIOUS mark-previous-rule
    shared-tag-attrs match-type-attr literal-start ;

TAG: KEYWORDS ( rule-set tag -- key value )
    ignore-case? get <keyword-map>
    swap child-tags [ over parse-keyword-tag ] each
    swap (>>keywords) ;

TAGS>

: ?<regexp> ( string/f -- regexp/f )
    dup [ ignore-case? get <regexp> ] when ;

: (parse-rules-tag) ( tag -- rule-set )
    <rule-set>
    {
        { "SET" string>rule-set-name (>>name) }
        { "IGNORE_CASE" string>boolean (>>ignore-case?) }
        { "HIGHLIGHT_DIGITS" string>boolean (>>highlight-digits?) }
        { "DIGIT_RE" ?<regexp> (>>digit-re) }
        { "ESCAPE" f add-escape-rule }
        { "DEFAULT" string>token (>>default) }
        { "NO_WORD_SEP" f (>>no-word-sep) }
    } init-from-tag ;

: parse-rules-tag ( tag -- rule-set )
    dup (parse-rules-tag) [
        dup ignore-case?>> ignore-case? [
            swap child-tags [ parse-rule-tag ] with each
        ] with-variable
    ] keep ;

: merge-rule-set-props ( props rule-set -- )
    [ assoc-union ] change-props drop ;

! Top-level entry points
: parse-mode-tag ( tag -- rule-sets )
    dup "RULES" tags-named [
        parse-rules-tag dup name>> swap
    ] H{ } map>assoc
    swap "PROPS" tag-named [
        parse-props-tag over values
        [ merge-rule-set-props ] with each
    ] when* ;

: parse-mode ( stream -- rule-sets )
    read-xml parse-mode-tag ;
