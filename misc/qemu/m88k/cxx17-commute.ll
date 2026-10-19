define i32 @m88k_commute_both_zero() noinline optnone {
  %v = xor i32 0, 0
  ret i32 %v
}
define i32 @m88k_commute_both() noinline optnone {
  %v = xor i32 7, 11
  ret i32 %v
}
define i32 @m88k_commute_left(i32 %x) noinline optnone {
  %v = xor i32 7, %x
  ret i32 %v
}
define i32 @m88k_commute_right(i32 %x) noinline optnone {
  %v = xor i32 %x, 7
  ret i32 %v
}
; Legalization creates a high-word G_XOR with two zero constants, after IR folds.
define i64 @m88k_commute_wide(i32 %x, i32 %y) noinline optnone {
  %a = zext i32 %x to i64
  %b = zext i32 %y to i64
  %v = xor i64 %a, %b
  ret i64 %v
}
