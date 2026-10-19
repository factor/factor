.text
.globl capture_hfa
.type capture_hfa,@function
capture_hfa:
 # A 32-byte HFA consumes four parameter doublewords, not eight.
 # Its members occupy f1..f8; the following pointer and integer use r7/r8.
 stfs 1,0(7)
 stfs 2,4(7)
 stfs 3,8(7)
 stfs 4,12(7)
 stfs 5,16(7)
 stfs 6,20(7)
 stfs 7,24(7)
 stfs 8,28(7)
 std 8,32(7)
 blr
.size capture_hfa,.-capture_hfa
# ELFv2 permits an HFA to straddle the available FPRs and stack slots.
.globl capture_split
.type capture_split,@function
capture_split:
 stfs 7,0(3)
 stfs 8,4(3)
 stfs 9,8(3)
 stfs 10,12(3)
 stfs 11,16(3)
 stfs 12,20(3)
 stfs 13,24(3)
 # Pointer + six doubles consume seven parameter slots before the HFA.
 # Its eighth float is at linkage32 + sevenSlots56 + memberOffset28.
 lfs 0,116(1)
 stfs 0,28(3)
 blr
.size capture_split,.-capture_split
.globl capture_scalar_spill
.type capture_scalar_spill,@function
capture_scalar_spill:
 # Unlike an HFA member, a scalar float occupies a complete eight-byte slot.
#if __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
 lfs 0,148(1)
#else
 lfs 0,144(1)
#endif
 stfs 0,0(3)
 blr
.size capture_scalar_spill,.-capture_scalar_spill
.section .note.GNU-stack,"",@progbits
