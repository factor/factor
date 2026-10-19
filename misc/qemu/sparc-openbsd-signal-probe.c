/* Copyright (C) 2026 Doug Coleman. BSD license. */
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>

static unsigned char altstack[65536];
static volatile sig_atomic_t handled;
static void handler(int sig, siginfo_t* info, void* raw) {
  struct sigcontext* sc = raw;
  uintptr_t local = (uintptr_t)&sc;
  if (sig != SIGILL || !info || local < (uintptr_t)altstack ||
      local >= (uintptr_t)(altstack + sizeof(altstack))) _exit(91);
  if (sc->sc_npc != sc->sc_pc + 4 || ((sc->sc_sp + 2047) & 15)) _exit(92);
  /* Keep the original authenticated context in place. */
  sc->sc_pc = sc->sc_npc;
  sc->sc_npc += 4;
  handled = 1;
}
int main(void) {
  stack_t ss;
  struct sigaction sa;
  static const unsigned char instructions[] = {
    0x00,0x00,0x00,0x00, /* unimp: native SIGILL */
    0x81,0xc3,0xe0,0x08, /* retl */
    0x90,0x10,0x20,0x2a  /* mov 42, o0 */
  };
  size_t size = getpagesize();
  void* code = mmap(NULL, size, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANON, -1, 0);
  if (code == MAP_FAILED) return 1;
  memset(&ss, 0, sizeof(ss)); ss.ss_sp = altstack; ss.ss_size = sizeof(altstack);
  memset(&sa, 0, sizeof(sa)); sa.sa_sigaction = handler;
  sa.sa_flags = SA_SIGINFO | SA_ONSTACK; sigemptyset(&sa.sa_mask);
  if (sigaltstack(&ss, NULL) || sigaction(SIGILL, &sa, NULL)) return 2;
  memcpy(code, instructions, sizeof(instructions));
  __asm__ volatile("membar #StoreStore" ::: "memory");
  size_t offset;
  for (offset = 0; offset < sizeof(instructions); offset += 4)
    __asm__ volatile("flush %0" : : "r"((char*)code + offset) : "memory");
  __asm__ volatile("membar #Sync" ::: "memory");
  if (mprotect(code, size, PROT_READ|PROT_EXEC)) return 3;
  if (((long(*)(void))code)() != 42 || !handled) return 4;
  printf("PASS native OpenBSD SPARC64 SA_SIGINFO altstack PC/NPC paired redirect stack bias authenticated sigreturn\n");
  return munmap(code, size) != 0;
}
