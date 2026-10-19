define i32 @m88k_urem8(i32 %a, i32 %b) {
  %x = trunc i32 %a to i8
  %y = trunc i32 %b to i8
  %r = urem i8 %x, %y
  %result = zext i8 %r to i32
  ret i32 %result
}
define i32 @m88k_urem16(i32 %a, i32 %b) {
  %x = trunc i32 %a to i16
  %y = trunc i32 %b to i16
  %r = urem i16 %x, %y
  %result = zext i16 %r to i32
  ret i32 %result
}
define i32 @m88k_srem8(i32 %a, i32 %b) {
  %x = trunc i32 %a to i8
  %y = trunc i32 %b to i8
  %r = srem i8 %x, %y
  %result = sext i8 %r to i32
  ret i32 %result
}
define i32 @m88k_srem16(i32 %a, i32 %b) {
  %x = trunc i32 %a to i16
  %y = trunc i32 %b to i16
  %r = srem i16 %x, %y
  %result = sext i16 %r to i32
  ret i32 %result
}
