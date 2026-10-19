/* OpenBSD full user barrier; no arithmetic RMW capability is implied. */
void m88k_fence(void) { __atomic_thread_fence(__ATOMIC_SEQ_CST); }
