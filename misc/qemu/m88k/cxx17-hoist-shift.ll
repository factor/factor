target triple = "m88k-unknown-openbsd"
define i32 @m88k_hoist_shift(i32 %x) noinline optnone {
  %o = or i32 %x, 1
  %s = shl i32 %o, 2
  ret i32 %s
}
define i32 @m88k_hoist_variable(i32 %x, i32 %y) noinline optnone {
  %a = shl i32 %x, 2
  %b = shl i32 %y, 2
  %o = or i32 %a, %b
  ret i32 %o
}
