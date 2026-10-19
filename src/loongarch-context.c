#include <stdint.h>
#include <signal.h>
#include <asm/sigcontext.h>
uintptr_t* factor_loongarch_signal_pc(void* p) { return (uintptr_t*)&((ucontext_t*)p)->uc_mcontext.__pc; }
uintptr_t* factor_loongarch_signal_sp(void* p) { return (uintptr_t*)&((ucontext_t*)p)->uc_mcontext.__gregs[3]; }
static uint32_t* fcsr(void* p) {
  struct sctx_info* info = (struct sctx_info*)((ucontext_t*)p)->uc_mcontext.__extcontext;
  while (info->magic && info->size >= sizeof(*info)) {
    void* body = (char*)info + sizeof(*info);
    if (info->magic == FPU_CTX_MAGIC) return &((struct fpu_context*)body)->fcsr;
    if (info->magic == LSX_CTX_MAGIC) return &((struct lsx_context*)body)->fcsr;
    if (info->magic == LASX_CTX_MAGIC) return &((struct lasx_context*)body)->fcsr;
    info = (struct sctx_info*)((char*)info + info->size);
  }
  return 0;
}
uint32_t factor_loongarch_signal_fcsr(void* p) { uint32_t* f = fcsr(p); return f ? *f : 0; }
void factor_loongarch_signal_clear_fcsr(void* p) { uint32_t* f = fcsr(p); if (f) *f &= ~UINT32_C(0x1f1f0000); }
