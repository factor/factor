USING: accessors assocs fonts help.stylesheet help.tips
io.styles kernel listener memoize namespaces prettyprint.private
prettyprint.stylesheet sequences ui.gadgets.panes.private
ui.theme ui.theme.switching ui.tools.listener vectors
vocabs.prettyprint words ;
IN: ui.theme.switching.tools

: update-tools-style ( -- )
    ! fonts
    text-color default-font-foreground-color set-global
    content-background default-font-background-color set-global

    ! help.stylesheet
    default-style text-color foreground update-style
    link-style link-color foreground update-style
    title-style title-color foreground update-style
    title-style help-header-background page-color update-style
    help-path-style text-color foreground update-style
    help-path-style help-path-border-color table-border update-style
    heading-style heading-color foreground update-style
    snippet-style snippet-color foreground update-style
    code-style code-background-color page-color update-style
    code-style code-border-color border-color update-style
    code-style text-color foreground update-style
    output-style output-color foreground update-style
    url-style link-color foreground update-style
    warning-style warning-background-color page-color update-style
    warning-style warning-border-color border-color update-style
    deprecated-style deprecated-background-color page-color update-style
    deprecated-style deprecated-border-color border-color update-style
    table-style table-border-color table-border update-style

    ! help.tips
    tip-of-the-day-style tip-background-color page-color update-style

    ! prettyprint.stylesheet
    { POSTPONE: USING: POSTPONE: USE: POSTPONE: IN: }
    [ "word-style" word-prop [ dim-color foreground  ] dip set-at ] each
    base-word-style text-color foreground update-style
    highlighted-word-style highlighted-word-color foreground update-style
    base-string-style string-color foreground update-style
    base-vocab-style dim-color foreground update-style
    base-effect-style stack-effect-color foreground update-style

    ! prettyprint.private
    \ => "word-style" word-prop
    [ content-background foreground rot set-at ]
    [ text-color background rot set-at ] bi

    ! vocabs.prettyprint
    manifest-style code-background-color page-color update-style
    manifest-style code-border-color border-color update-style

    ! ui.gadgets.panes
    \ specified-font reset-memoized

    ! ui.tools.listener
    listener-input-style text-color foreground update-style
    listener-word-style text-color foreground update-style
    interactor-font get-global text-color >>foreground content-background >>background drop

    ! listener
    prompt-style prompt-background-color background update-style
    prompt-style text-color foreground update-style ;

\ update-stylesheet [ \ update-tools-style swap ?push ] change-global
