#include <stdint.h>
#include <stdio.h>
struct hfa { float members[8]; };
struct captured { float members[8]; uint64_t following; };
extern void capture_hfa(struct hfa values, struct captured* result, uint64_t following);
extern void capture_split(struct captured* result, double a, double b, double c, double d, double e, double f, struct hfa values);
extern void capture_scalar_spill(struct captured* result, float a1, float a2, float a3, float a4, float a5, float a6, float a7, float a8, float a9, float a10, float a11, float a12, float a13, float a14);
int main(void) {
  struct hfa values = {{1,2,3,4,5,6,7,8}};
  struct captured result = {{0},0};
  capture_hfa(values, &result, UINT64_C(0x1122334455667788));
  for (int i=0;i<8;i++) if (result.members[i] != values.members[i]) return 1;
  if (result.following != UINT64_C(0x1122334455667788)) return 2;
  capture_split(&result, 9,10,11,12,13,14,values);
  for (int i=0;i<8;i++) if (result.members[i] != values.members[i]) return 3;
  capture_scalar_spill(&result,1,2,3,4,5,6,7,8,9,10,11,12,13,14);
  if (result.members[0] != 14) return 4;
  puts("PASS ELFv2 eight-float HFA arguments and following GPR positions");
  return 0;
}
