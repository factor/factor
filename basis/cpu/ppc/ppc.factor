USING: accessors cpu.ppc.architecture cpu.ppc.intrinsics
cpu.architecture namespaces alien.c-types kernel system
combinators ;

{
    { [ os macosx? ] [
        4 "longlong" c-type (>>align)
        4 "ulonglong" c-type (>>align)
        4 "double" c-type (>>align)
    ] }
    { [ os linux? ] [
        t "longlong" c-type (>>stack-align?)
        t "ulonglong" c-type (>>stack-align?)
    ] }
} cond
