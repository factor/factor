; Native checked semantics for integer truncation and zero extension.
define i32 @m88k_trunc1(i32 %v) {
  %n = trunc i32 %v to i1
  %r = zext i1 %n to i32
  ret i32 %r
}
define i32 @m88k_trunc8(i32 %v) {
  %n = trunc i32 %v to i8
  %r = zext i8 %n to i32
  ret i32 %r
}
define i32 @m88k_trunc16(i32 %v) {
  %n = trunc i32 %v to i16
  %r = zext i16 %n to i32
  ret i32 %r
}
define i32 @m88k_trunc32(i64 %v) {
  %r = trunc i64 %v to i32
  ret i32 %r
}
