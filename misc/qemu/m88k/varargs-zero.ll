target triple = "m88k-unknown-openbsd"

declare void @llvm.va_start(ptr)
declare void @llvm.va_end(ptr)

define i32 @zero(...) {
  %ap = alloca { i32, ptr, ptr }, align 4
  call void @llvm.va_start(ptr %ap)
  %index = load i32, ptr %ap, align 4
  %valid_index = icmp eq i32 %index, 0
  %regs_field = getelementptr { i32, ptr, ptr }, ptr %ap, i32 0, i32 2
  %regs = load ptr, ptr %regs_field, align 4
  %first = load i32, ptr %regs, align 4
  %second_ptr = getelementptr i32, ptr %regs, i32 1
  %second = load i32, ptr %second_ptr, align 4
  %valid_first = icmp eq i32 %first, 1234
  %valid_second = icmp eq i32 %second, 42
  %values = and i1 %valid_first, %valid_second
  %valid = and i1 %values, %valid_index
  call void @llvm.va_end(ptr %ap)
  %result = zext i1 %valid to i32
  ret i32 %result
}
