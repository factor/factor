! Copyright (C) 2016-2017 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: skov.basis.code skov.basis.code.factor-abstraction continuations kernel models
ui.gadgets.borders ui.gadgets.labels
skov.basis.ui.tools.environment.tree ;

IN: skov.basis.ui.tools.environment.tree.help-tree

: <help-tree> ( factor-word -- gadget )
    word new swap call-from-factor add-element
    <model> <tree> { 20 10 } <filled-border> ;

: <definition-tree> ( factor-word -- gadget )
    [ word-from-factor <model> <tree> { 5 5 } <border> ]
    [ drop drop "(cannot be displayed)" <label> ] recover ;
