USING: namespaces parser vocabs vocabs.loader vocabs.refresh ;
<< auto-use? off "cpu.architecture" reload "alien.c-types" reload
   "alien" refresh "stack-checker" refresh
   "compiler" refresh "cpu" refresh >>
USING: accessors arrays assocs byte-arrays combinators.smart
compiler.errors compiler.units debugger fry io kernel kernel.private
locals math math.vectors math.vectors.simd namespaces parser prettyprint
random random.mersenne-twister sequences system tools.test words ;
IN: simd-x64.edges
auto-use? off restartable-tests? off
20260908 <mersenne-twister> random-generator set

: evaluator ( quot -- word )
    [ ( inputs -- result ) define-temp ] with-compilation-unit ;

:: check-operation ( class op arity -- )
    arity class <array> op '[ _ declare @ ] '[ _ input<sequence ] :> code
    code evaluator :> native
    t "always-inline-simd-intrinsics" [ code evaluator ] with-variable :> scalar
    class '[ 16 [ 256 random ] B{ } replicate-as _ boa ] :> generator
    50 [
        arity [ generator call( -- v ) ] replicate
        dup native execute( inputs -- result )
        over scalar execute( inputs -- result )
        2dup = [ 3drop ] [
            class . op . "INPUT / NATIVE / FALLBACK" print
            [ . ] tri@ "SIMD edge mismatch" throw
        ] if
    ] times ;

{ char-16 uchar-16 short-8 ushort-8 int-4 uint-4 longlong-2 ulonglong-2 } [| class |
    class . flush
    {
        [ v+ ] [ v- ] [ v* ] [ vs+ ] [ vs- ] [ vs* ]
        [ vmin ] [ vmax ] [ v< ] [ v<= ] [ v= ] [ v> ] [ v>= ]
        [ vbitand ] [ vbitandn ] [ vbitor ] [ vbitxor ]
        [ vabsdiff ] [ vdot ] [ vsad ] [ vavg ]
    } [ class swap 2 check-operation ] each
    {
        [ sum ] [ vabs ] [ vneg ] [ vbitnot ]
        [ vbit-count ] [ vclz ] [ vctz ] [ vbit-reverse ]
    } [ class swap 1 check-operation ] each
] each
"COMPILER ERRORS " write compiler-errors get assoc-size .
compiler-errors get values [ print-error ] each
compiler-errors get assoc-empty? 0 1 ? exit
