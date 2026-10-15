// Factor: r8=context, r12=frame pointer, r1=native callee.
// The native callee owns the 160-byte save area at r15. The Factor
// walkable frame follows it, so native register spills cannot clobber it.
.text
.p2align 1
.global trampoline
.type trampoline,@function
trampoline:
  lgr %r0,%r15
  aghi %r15,-176
  stg %r0,0(%r15)
  stg %r12,160(%r15)
  stg %r14,168(%r15)
  lay %r12,160(%r15)
  stg %r12,0(%r8)
  basr %r14,%r1
  lg %r14,168(%r15)
  lg %r12,160(%r15)
  aghi %r15,176
  br %r14
.size trampoline,.-trampoline
.global trampoline2
.type trampoline2,@function
trampoline2:
  // r0 points to a preallocated walkable header above the native area.
  // Register zero denotes no base in a memory operand. Use the context
  // slot to hold the parent while moving the header into the frame register.
  stg %r12,0(%r8)
  lgr %r12,%r0
  lg %r0,0(%r8)
  stg %r0,0(%r12)
  stg %r14,8(%r12)
  stg %r12,0(%r8)
  basr %r14,%r1
  lg %r14,8(%r12)
  lg %r12,0(%r12)
  br %r14
.size trampoline2,.-trampoline2
.section .note.GNU-stack,"",@progbits
