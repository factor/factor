declare i64 @llvm.ctlz.i64(i64, i1)
declare i32 @llvm.ctlz.i32(i32, i1)
define i32 @m88k_clz32(i32 %v) {
  %r=call i32 @llvm.ctlz.i32(i32 %v,i1 false)
  ret i32 %r
}
define i64 @m88k_clz64(i64 %v) {
  %r=call i64 @llvm.ctlz.i64(i64 %v,i1 false)
  ret i64 %r
}
define i64 @m88k_clz64_undef(i64 %v) {
  %r=call i64 @llvm.ctlz.i64(i64 %v,i1 true)
  ret i64 %r
}
