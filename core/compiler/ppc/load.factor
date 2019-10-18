PROVIDE: core/compiler/ppc
{ +files+ {
    "assembler.factor"
    "architecture.factor"
    "allot.factor"
    "intrinsics.factor"
} } ;

USING: alien kernel ;

{
    { [ macosx? ] [
        4 "longlong" c-type set-c-type-align
        4 "ulonglong" c-type set-c-type-align
    ] }
    { [ os "linux" = ] [
        t "longlong" c-type set-c-type-stack-align?
        t "ulonglong" c-type set-c-type-stack-align?
    ] }
} cond
