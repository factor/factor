USING: help.markup.private io namespaces sequences
ui.tools.environment.tree.help-tree ui.gadgets.panes kernel ;
IN: help.markup

: $graph ( element -- )
    check-first <help-tree> nl nl output-stream get write-gadget ;

: $see ( element -- )
    check-first <definition-tree> nl output-stream get write-gadget ;

: $inputs ( element -- )
    "Inputs" $heading
    [ [ "none" print ] ($block) ]
    [ [ values-row ] map $table ] if-empty ;

: $outputs ( element -- )
    "Outputs" $heading
    [ [ "none" print ] ($block) ]
    [ [ values-row ] map $table ] if-empty ;
