USING: help.markup help.syntax literals make multiline stack-checker.alien ;
IN: compiler.cfg.builder.alien

<<
STRING: ex-caller-return
USING: compiler.cfg.builder.alien make prettyprint ;
[
    T{ ##alien-invoke { reg-outputs { { 1 int-rep RAX } } } } ,
    T{ alien-invoke-params { return pointer: void } }  caller-return
] { } make  .
{
    T{ ##alien-invoke { reg-outputs { { 1 int-rep RAX } } } }
    T{ ##box-alien { dst 116 } { src 1 } { temp 115 } }
}
;
>>

HELP: caller-return
{ $values { "params" alien-node-params } }
{ $description "If the last alien call returns a value, then this word will emit an instruction to the current sequence being constructed by " { $link make } " that boxes it." }
{ $examples { $unchecked-example $[ ex-caller-return ] } } ;
