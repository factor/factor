USING: compiler.cfg.hats compiler.cfg.intrinsics.simd.backend ;
IN: compiler.cfg.intrinsics.simd
! Exact lowering before d550dc352e, installed only in this test process.
: emit-simd-vshuffle-bytes ( node -- )
    { [ ^^shuffle-vector ] } emit-vv-vector-op ;
