USING: alien.c-types alien.c-types.varargs combinators cpu.architecture math accessors assocs compiler.errors compiler.cfg.builder.alien compiler.cfg.builder.alien.params compiler.units
 debugger io kernel namespaces parser sequences stack-checker.alien system tools.test words ;
FROM: alien.c-types => float ;
<< "resource:reference/arm64-varargs-outgoing-20260908/refresh.factor" run-file >>
f restartable-tests? set-global
! Exercise Windows parameter lowering without changing the macOS runtime ABI.
[ \ windows-arm64-varargs-call? [ varargs?>> >boolean ] define
  \ handle-macos-arm64-varargs [ drop f varargs-named-count set f compact-stack-params? set ] define
  \ promote-vararg-type [
    dup lookup-c-type {
      { [ dup small-float-c-type? ] [ drop ] }
      { [ dup float lookup-c-type eq? ] [ 2drop double ] }
      { [ dup dup c-type? [ [ rep>> int-rep = ] [ heap-size 4 < ] bi and ] [ drop f ] if ] [ 2drop int ] }
      [ drop ]
    } cond
  ] define
] with-compilation-unit
"resource:reference/arm64-varargs-outgoing-20260908/windows-cases.factor" run-test-file
"resource:reference/arm64-varargs-outgoing-20260908/windows-more.factor" run-test-file
:test-failures compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and [ 0 ] [ 1 ] if exit
