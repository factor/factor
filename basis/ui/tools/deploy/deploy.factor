! Copyright (C) 2007, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel models models.mapping namespaces
sequences tools.deploy tools.deploy.config
tools.deploy.config.editor ui ui.commands ui.gadgets
ui.gadgets.borders ui.gadgets.buttons ui.gadgets.editors
ui.gadgets.labels ui.gadgets.packs ui.gadgets.toolbar
ui.gadgets.worlds ui.gestures ui.tools.browser ui.tools.common
ui.tools.listener vocabs ;
IN: ui.tools.deploy

TUPLE: deploy-gadget < pack vocab settings ;

: bundle-name ( parent -- parent )
    deploy-name get <model-field>
    "Executable name:" label-on-left add-gadget ;

: deploy-console ( parent -- parent )
    deploy-console? get
    "Deploy as console application" <checkbox> add-gadget ;

: deploy-ui ( parent -- parent )
    deploy-ui? get
    "Include user interface framework" <checkbox> add-gadget ;

: reflection-settings ( parent -- parent )
    "Reflection level:" <label> add-gadget
    deploy-reflection get deploy-reflection-options <radio-buttons> add-gadget ;

: advanced-settings ( parent -- parent )
    "Additional reflection:" <label> add-gadget
    deploy-unicode? get "Unicode character literal table" <checkbox> add-gadget
    deploy-word-props? get "Retain all word properties" <checkbox> add-gadget
    deploy-word-defs? get "Retain all word definitions" <checkbox> add-gadget
    deploy-c-types? get "Retain all C types" <checkbox> add-gadget
    deploy-help? get "Retain documentation" <checkbox> add-gadget ;

: deploy-settings-theme ( gadget -- gadget )
    { 10 10 } >>gap
    1 >>fill ;

: <deploy-settings> ( vocab -- control )
    default-config [ <model> ] assoc-map [
        <pile>
        bundle-name
        deploy-ui
        deploy-console
        reflection-settings
        advanced-settings

        deploy-settings-theme
        namespace <mapping> >>model
    ] with-variables ;

: find-deploy-gadget ( gadget -- deploy-gadget )
    [ deploy-gadget? ] find-parent ;

: find-deploy-vocab ( gadget -- vocab )
    find-deploy-gadget vocab>> ;

: find-deploy-config ( gadget -- config )
    find-deploy-vocab deploy-config ;

: find-deploy-settings ( gadget -- settings )
    find-deploy-gadget settings>> ;

: com-revert ( gadget -- )
    dup find-deploy-config
    swap find-deploy-settings set-control-value ;

: com-save ( gadget -- )
    dup find-deploy-settings control-value
    swap find-deploy-vocab set-deploy-config ;

: com-deploy ( gadget -- )
    [ com-save ]
    [ find-deploy-vocab '[ _ deploy ] \ deploy call-listener ]
    [ close-window ]
    tri ;

: com-help ( -- )
    "ui.tools.deploy" com-browse ;

\ com-help H{
    { +nullary+ t }
} define-command

: com-close ( gadget -- )
    close-window ;

deploy-gadget "misc" "Miscellaneous commands" {
    { T{ key-down f f "ESC" } com-close }
} define-command-map

deploy-gadget "toolbar" f {
    { T{ key-down f f "F1" } com-help }
    { f com-revert }
    { f com-save }
    { T{ key-down f f "RET" } com-deploy }
} define-command-map

: <deploy-gadget> ( vocab -- gadget )
    deploy-gadget new
      over >>vocab
      vertical >>orientation
      swap <deploy-settings> >>settings
      dup settings>> add-gadget
      dup <toolbar> { 10 10 } >>gap add-gadget
    deploy-settings-theme
    dup com-revert ;

: deploy-tool ( vocab -- )
    vocab-name
    [ <deploy-gadget> { 10 10 } <border> white-interior ]
    [
        <world-attributes>
            swap "Deploying '" "'" surround >>title
            [ { dialog-window } append ] change-window-controls
    ] bi
    open-window ;
