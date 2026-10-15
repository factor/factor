define i32 @m88k_fcmp32_0(float %a, float %b) {
  %p = fcmp false float %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp32_1(float %a, float %b) {
  %p = fcmp oeq float %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp32_2(float %a, float %b) {
  %p = fcmp ogt float %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp32_3(float %a, float %b) {
  %p = fcmp oge float %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp32_4(float %a, float %b) {
  %p = fcmp olt float %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp32_5(float %a, float %b) {
  %p = fcmp ole float %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp32_6(float %a, float %b) {
  %p = fcmp one float %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp32_7(float %a, float %b) {
  %p = fcmp ord float %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp32_8(float %a, float %b) {
  %p = fcmp uno float %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp32_9(float %a, float %b) {
  %p = fcmp ueq float %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp32_10(float %a, float %b) {
  %p = fcmp ugt float %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp32_11(float %a, float %b) {
  %p = fcmp uge float %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp32_12(float %a, float %b) {
  %p = fcmp ult float %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp32_13(float %a, float %b) {
  %p = fcmp ule float %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp32_14(float %a, float %b) {
  %p = fcmp une float %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp32_15(float %a, float %b) {
  %p = fcmp true float %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp64_0(double %a, double %b) {
  %p = fcmp false double %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp64_1(double %a, double %b) {
  %p = fcmp oeq double %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp64_2(double %a, double %b) {
  %p = fcmp ogt double %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp64_3(double %a, double %b) {
  %p = fcmp oge double %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp64_4(double %a, double %b) {
  %p = fcmp olt double %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp64_5(double %a, double %b) {
  %p = fcmp ole double %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp64_6(double %a, double %b) {
  %p = fcmp one double %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp64_7(double %a, double %b) {
  %p = fcmp ord double %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp64_8(double %a, double %b) {
  %p = fcmp uno double %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp64_9(double %a, double %b) {
  %p = fcmp ueq double %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp64_10(double %a, double %b) {
  %p = fcmp ugt double %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp64_11(double %a, double %b) {
  %p = fcmp uge double %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp64_12(double %a, double %b) {
  %p = fcmp ult double %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp64_13(double %a, double %b) {
  %p = fcmp ule double %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp64_14(double %a, double %b) {
  %p = fcmp une double %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
define i32 @m88k_fcmp64_15(double %a, double %b) {
  %p = fcmp true double %a, %b
  %r = zext i1 %p to i32
  ret i32 %r
}
