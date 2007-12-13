USING: xmode.tokens xmode.rules xmode.keyword-map xml.data
xml.utilities xml assocs kernel combinators sequences
math.parser namespaces parser xmode.utilities regexp io.files ;
IN: xmode.loader

! Based on org.gjt.sp.jedit.XModeHandler

SYMBOL: ignore-case?

! Attribute utilities
: string>boolean ( string -- ? ) "TRUE" = ;

: string>match-type ( string -- obj )
    {
        { "RULE" [ f ] }
        { "CONTEXT" [ t ] }
        [ string>token ]
    } case ;

: string>rule-set-name "MAIN" or ;

! PROP, PROPS
: parse-prop-tag ( tag -- key value )
    "NAME" over at "VALUE" rot at ;

: parse-props-tag ( tag -- assoc )
    child-tags
    [ parse-prop-tag ] H{ } map>assoc ;

: position-attrs ( tag -- at-line-start? at-whitespace-end? at-word-start? )
    ! XXX Wrong logic!
    { "AT_LINE_START" "AT_WHITESPACE_END" "AT_WORD_START" }
    swap [ at string>boolean ] curry map first3 ;

: parse-literal-matcher ( tag -- matcher )
    dup children>string
    ignore-case? get <string-matcher>
    swap position-attrs <matcher> ;

: parse-regexp-matcher ( tag -- matcher )
    dup children>string ignore-case? get <regexp>
    swap position-attrs <matcher> ;

! SPAN's children
<TAGS: parse-begin/end-tag

TAG: BEGIN
    ! XXX
    parse-literal-matcher swap set-rule-start ;

TAG: END
    ! XXX
    parse-literal-matcher swap set-rule-end ;

TAGS>

! RULES and its children
<TAGS: parse-rule-tag

TAG: PROPS ( rule-set tag -- )
    parse-props-tag swap set-rule-set-props ;

TAG: IMPORT ( rule-set tag -- )
    "DELEGATE" swap at swap import-rule-set ;

TAG: TERMINATE ( rule-set tag -- )
    "AT_CHAR" swap at string>number swap set-rule-set-terminate-char ;

: (parse-rule-tag) ( rule-set tag specs class -- )
    construct-rule swap init-from-tag swap add-rule ; inline

: RULE:
    scan scan-word
    parse-definition { } make
    swap [ (parse-rule-tag) ] 2curry (TAG:) ; parsing

: shared-tag-attrs
    { "TYPE" string>token set-rule-body-token } , ; inline

: delegate-attr
    { "DELEGATE" f set-rule-delegate } , ;

: regexp-attr
    { "HASH_CHAR" f set-rule-chars } , ;

: match-type-attr
    { "MATCH_TYPE" string>match-type set-rule-match-token } , ;

: span-attrs
    { "NO_LINE_BREAK" string>boolean set-rule-no-line-break? } ,
    { "NO_WORD_BREAK" string>boolean set-rule-no-word-break? } ,
    { "NO_ESCAPE" string>boolean set-rule-no-escape? } , ;

: literal-start
    [ parse-literal-matcher swap set-rule-start ] , ;

: regexp-start
    [ parse-regexp-matcher swap set-rule-start ] , ;

: literal-end
    [ parse-literal-matcher swap set-rule-end ] , ;

RULE: SEQ seq-rule
    shared-tag-attrs delegate-attr literal-start ;

RULE: SEQ_REGEXP seq-rule
    shared-tag-attrs delegate-attr regexp-attr regexp-start ;

: parse-begin/end-tags
    [
        ! XXX: handle position attrs on span tag itself
        child-tags [ parse-begin/end-tag ] curry* each
    ] , ;

: init-span-tag [ drop init-span ] , ;

: init-eol-span-tag [ drop init-eol-span ] , ;

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

: parse-keyword-tag ( tag keyword-map -- )
    >r dup name-tag string>token swap children>string r> set-at ;

TAG: KEYWORDS ( rule-set tag -- key value )
    ignore-case? get <keyword-map>
    swap child-tags [ over parse-keyword-tag ] each
    swap set-rule-set-keywords ;

TAGS>

: ?<regexp> dup [ ignore-case? get <regexp> ] when ;

: (parse-rules-tag) ( tag -- rule-set )
    <rule-set>
    {
        { "SET" string>rule-set-name set-rule-set-name }
        { "IGNORE_CASE" string>boolean set-rule-set-ignore-case? }
        { "HIGHLIGHT_DIGITS" string>boolean set-rule-set-highlight-digits? }
        { "DIGIT_RE" ?<regexp> set-rule-set-digit-re }
        { "ESCAPE" f add-escape-rule }
        { "DEFAULT" string>token set-rule-set-default }
        { "NO_WORD_SEP" f set-rule-set-no-word-sep }
    } init-from-tag ;

: parse-rules-tag ( tag -- rule-set )
    dup (parse-rules-tag) [
        dup rule-set-ignore-case? ignore-case? [
            swap child-tags [ parse-rule-tag ] curry* each
        ] with-variable
    ] keep ;

: merge-rule-set-props ( props rule-set -- )
    [ rule-set-props union ] keep set-rule-set-props ;

! Top-level entry points
: parse-mode-tag ( tag -- rule-sets )
    dup "RULES" tags-named [
        parse-rules-tag dup rule-set-name swap
    ] H{ } map>assoc
    swap "PROPS" tag-named [
        parse-props-tag over values
        [ merge-rule-set-props ] curry* each
    ] when* ;

: parse-mode ( stream -- rule-sets )
    read-xml parse-mode-tag ;
