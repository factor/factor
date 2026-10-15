define i32 @m88k_sext1(i32 %v) {
  %n = trunc i32 %v to i1
  %r = sext i1 %n to i32
  ret i32 %r
}
define i32 @m88k_sext8(i32 %v) {
  %n = trunc i32 %v to i8
  %r = sext i8 %n to i32
  ret i32 %r
}
define i32 @m88k_sext16(i32 %v) {
  %n = trunc i32 %v to i16
  %r = sext i16 %n to i32
  ret i32 %r
}
define i32 @m88k_phi8(i32 %count) {
entry:
  %n = trunc i32 %count to i8
  %empty = icmp eq i8 %n, 0
  br i1 %empty, label %zero, label %loop
zero:
  ret i32 0
loop:
  %i = phi i8 [0, %entry], [%next, %loop]
  %sum = phi i32 [0, %entry], [%total, %loop]
  %value = zext i8 %i to i32
  %total = add i32 %sum, %value
  %next = add i8 %i, 1
  %done = icmp uge i8 %next, %n
  br i1 %done, label %exit, label %loop
exit:
  ret i32 %total
}
