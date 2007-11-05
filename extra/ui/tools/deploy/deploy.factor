! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: ui.gadgets colors kernel ui.render namespaces
ui.gadgets.controls models sequences ui.gadgets.buttons
ui.gadgets.packs ui.gadgets.labels tools.deploy.config
namespaces ui.gadgets.editors ui.gadgets.borders ui.gestures
ui.commands assocs ui.gadgets.tracks ui ui.tools.listener
tools.deploy.app vocabs ui.tools.workspace ui.operations ;
IN: ui.tools.deploy

TUPLE: deploy-gadget vocab settings ;

: bundle-name ( -- )
    "bundle-name" get <field>
    "Bundle name:" label-on-left gadget, ;

: deploy-ui ( -- )
    deploy-ui? get
    "Include user interface framework" <checkbox> gadget, ;

: exit-when-windows-closed ( -- )
    "stop-after-last-window?" get
    "Exit when last UI window closed" <checkbox> gadget, ;

: io-settings ( -- )
    "Input/output support:" <label> gadget,
    deploy-io get deploy-io-options <radio-buttons> gadget, ;

: reflection-settings ( -- )
    "Reflection support:" <label> gadget,
    deploy-reflection get deploy-reflection-options <radio-buttons> gadget, ;

: advanced-settings ( -- )
    "Advanced:" <label> gadget,
    deploy-compiler? get "Use optimizing compiler" <checkbox> gadget,
    deploy-math? get "Rational and complex number support" <checkbox> gadget,
    deploy-word-props? get "Include word properties" <checkbox> gadget,
    deploy-word-defs? get "Include word definitions" <checkbox> gadget,
    deploy-c-types? get "Include C types" <checkbox> gadget, ;

: deploy-settings-theme
    { 10 10 } over set-pack-gap
    1 swap set-pack-fill ;

: <deploy-settings> ( -- control )
    default-config [ <model> ] assoc-map [
        f <model> "bundle-name" set
        [
            bundle-name
            deploy-ui
            exit-when-windows-closed
            io-settings
            reflection-settings
            advanced-settings
        ] make-pile dup deploy-settings-theme
        namespace <mapping> swap [ 2drop ] <control>
    ] bind ;

: find-deploy-gadget
    [ deploy-gadget? ] find-parent ;

: find-deploy-vocab
    find-deploy-gadget deploy-gadget-vocab ;

: find-deploy-config
    find-deploy-vocab deploy.app-config ;

: find-deploy-settings
    find-deploy-gadget deploy-gadget-settings ;

: com-revert ( gadget -- )
    dup find-deploy-config
    swap find-deploy-settings set-control-value ;

: com-save ( gadget -- )
    dup find-deploy-settings control-value
    swap find-deploy-vocab set-deploy-config ;

: com-deploy ( gadget -- )
    dup com-save
    find-deploy-vocab [ deploy.app ] curry call-listener ;

: com-help ( -- )
    "ui-deploy" help-window ;

\ com-help H{
    { +nullary+ t }
} define-command

deploy-gadget "toolbar" f {
    { f com-help }
    { f com-revert }
    { f com-save }
    { T{ key-down f f "RETURN" } com-deploy }
} define-command-map

: buttons,
    g <toolbar> { 10 10 } over set-pack-gap gadget, ;

: <deploy-gadget> ( vocab -- gadget )
    f deploy-gadget construct-boa [
        <deploy-settings>
        g-> set-deploy-gadget-settings gadget,
        buttons,
    ] { 0 1 } build-pack
    dup deploy-settings-theme
    dup com-revert ;

: deploy-tool ( vocab -- )
    vocab-name dup <deploy-gadget> 10 <border>
    "Deploying \"" rot "\"" 3append open-window ;

[ vocab-spec? ] \ deploy-tool H{ } define-operation
