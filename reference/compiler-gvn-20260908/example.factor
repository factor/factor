USING: vocabs.loader vocabs.refresh ;
<< "resource:reference/compiler-gvn-20260908/metrics-root" add-vocab-root "compiler" refresh >>
USING: accessors arrays assocs compiler.cfg.metrics compiler.cfg.value-numbering
compiler.units compiler.utilities kernel locals math math.bitwise namespaces prettyprint sequences typed ;
IN: gvn-example
TYPED:: example ( x: fixnum flag: boolean -- y: fixnum )
    x 7 bitxor :> a
    flag [ a 3 bitand ] [ a 1 bitand ] if
    x 7 bitxor bitxor ;
f global-value-numbering? set
\ example measure-compilation .
t global-value-numbering? set
\ example measure-compilation .
