! Test-only Windows ABI selection; keep the macOS native stub and runtime.
USING: accessors alien alien.c-types alien.varargs arrays assocs
compiler.cfg.builder.alien compiler.cfg.builder.alien.boxing
compiler.cfg.builder.alien.params compiler.cfg.hats compiler.cfg.stacks
compiler.cfg.stacks.local cpu.architecture kernel locals math namespaces
sequences stack-checker.alien stack-checker.backend system ;
IN: compiler.cfg.builder.alien
:: box-parameters ( vregs reps params -- )
    params varargs?>> [
        vregs reps params parameters>>
        [ base-type box-windows-vararg-parameter ds-push ] 3each
    ] [ vregs reps params parameters>> [ base-type box-parameter ds-push ] 3each ] if ;
:: named-callee-parameters ( params -- vregs reps )
    params varargs?>> [
        f compact-stack-params? set
        params parameters>> [ base-type flatten-windows-vararg-type ] map
        [ [ [ dup prepare-parameter-group [ first3 ] [ param-natural-size ] bi callee-parameter ] map ] map ]
        [ [ keys ] map ] bi
    ] [ params parameters>> [ base-type ] map (callee-parameters) ] if ;
:: emit-va-cursor-inputs ( layout -- )
    layout first3 :> ( stack-offset gp-left fp-left )
    ^^callback-stack :> entry-sp
    entry-sp gp-left 0 > [ gp-left 8 * ^^sub-imm ] [ stack-offset ^^add-imm ] if
    ^^box-alien ds-push
    f ^^load-literal ds-push f ^^load-literal ds-push
    0 ^^load-literal ds-push 0 ^^load-literal ds-push ;
IN: alien.varargs
: <va-cursor> ( stack gr-top vr-top gr-offs vr-offs -- cursor )
    windows <platform-va-cursor> ;
: cursor>native-va-list ( cursor -- ptr )
    dup check-va-list stack>> ;

USING: alien.private kernel.private stack-checker.visitor words ;
IN: stack-checker.alien
: callback-bottom ( params -- )
    "( callback )" <uninterned-word> >>xt
    dup [ xt>> ] [ varargs?>> ] bi "callback-varargs" set-word-prop
    xt>> '[ _ callback-xt { alien } declare ] infer-quot-here ;
