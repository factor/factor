#ifdef __APPLE__
#define TRAMPOLINE _trampoline
#define TRAMPOLINE2 _trampoline2
#else
#define TRAMPOLINE trampoline
#define TRAMPOLINE2 trampoline2
#endif

.global TRAMPOLINE
.global TRAMPOLINE2
.align 2
.text

#define IP0 X16
#define IP1 X17
#define CTX X20

TRAMPOLINE:
  STP FP, LR, [SP, -16]!
  MOV FP, SP
  STR FP, [CTX] // ctx.callstack_top
  BLR IP0
  LDP FP, LR, [SP], 16
  RET

TRAMPOLINE2:
  STP FP, LR, [IP1]
  MOV FP, IP1
  STR FP, [CTX]
  BLR IP0
  LDP FP, LR, [FP]
  RET
