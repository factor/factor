#ifndef FACTOR_NETBSD_ALPHA_SIGNAL_FPU_HPP
#define FACTOR_NETBSD_ALPHA_SIGNAL_FPU_HPP
#include <stdint.h>
#include <ucontext.h>

namespace factor {

// NetBSD's Alpha mcontext overlays software FP_C onto the saved FPCR word.
// Preserve interrupted dynamic rounding, then encode the handler's edited
// software controls in both forms consumed by stock cpu_setmcontext.
inline uint64_t netbsd_alpha_sigreturn_fpcr(uint64_t entry_fpcr,
                                          uint64_t fp_c) {
  const uint64_t software_mask = UINT64_C(0x7ffffe);
  const uint64_t status_mask = UINT64_C(0x3e0000);
  uint64_t flags = (fp_c >> 17) & 63;
  uint64_t traps = (fp_c >> 1) & 63;
  uint64_t disables = flags & ~traps;
  uint64_t hardware = entry_fpcr & (UINT64_C(3) << 58);
  hardware |= (disables & 24) << 58;
  hardware |= (disables & 7) << 49;
  hardware |= (fp_c & status_mask) << 35;
  hardware |= (fp_c & (UINT64_C(1) << 12)) << 36;
  if (fp_c & status_mask) hardware |= UINT64_C(1) << 63;
  if (fp_c & (UINT64_C(1) << 13))
    hardware |= (UINT64_C(1) << 60) | (UINT64_C(1) << 61);
  hardware |= (~fp_c & (UINT64_C(1) << 6)) << 41;
  return hardware | (fp_c & software_mask);
}

class netbsd_alpha_signal_fpu_scope {
  ucontext_t* context;
  uint64_t entry_fpcr;

 public:
  explicit netbsd_alpha_signal_fpu_scope(void* raw)
      : context(static_cast<ucontext_t*>(raw)), entry_fpcr(0) {
    if (!context || !(context->uc_flags & _UC_FPU)) {
      context = 0;
      return;
    }
    // The first instruction may enable lazy FP ownership; its result is a sink.
    // This boundary prime does not claim to repair arbitrary FEN preemption.
    __asm__ volatile("mf_fpcr $f31\n\texcb\n\tmf_fpcr %0\n\texcb"
                     : "=f"(entry_fpcr) :: "memory");
  }

  void restore() {
    if (context && (context->uc_flags & _UC_FPU))
      context->uc_mcontext.__fpregs.__fp_fpcr = netbsd_alpha_sigreturn_fpcr(
          entry_fpcr, context->uc_mcontext.__fpregs.__fp_fpcr);
    context = 0;
  }

  ~netbsd_alpha_signal_fpu_scope() { restore(); }

 private:
  netbsd_alpha_signal_fpu_scope(const netbsd_alpha_signal_fpu_scope&);
  netbsd_alpha_signal_fpu_scope& operator=(const netbsd_alpha_signal_fpu_scope&);
};

}
#endif
