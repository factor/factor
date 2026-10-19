// Native load/store publication and signal-handler regression, including
// the seq_cst store-buffering litmus. No VM read-modify-write API is used.
#ifdef NDEBUG
#error "Publication controls require active assertions and setup"
#endif
#include <cassert>
#include <cstdint>
#include <pthread.h>
#include <signal.h>
#include <stdio.h>
#include <sched.h>
namespace factor { using cell = uintptr_t; using fixnum = intptr_t; }
#include "../../atomic-gcc.hpp"
using factor::atomic::load;
using factor::atomic::store;
#ifndef FACTOR_PUBLICATION_ROUNDS
#define FACTOR_PUBLICATION_ROUNDS 256
#endif
constexpr uint32_t rounds = FACTOR_PUBLICATION_ROUNDS;
static pthread_t consumer_thread;
static volatile bool ready;
static uint32_t payload;
static volatile uint32_t epoch, done[2], x, y;
static uint32_t result[2];
struct published {
  uint32_t value, inverse;
};
static published entries[rounds];
static published* volatile owner;
static volatile uint32_t signal_seen, signal_bad, async_epoch, async_ack;
static unsigned char alternate_stack[65536];

extern "C" __attribute__((noinline)) uint32_t publication_load_word(volatile uint32_t* p) { return load(p); }
extern "C" __attribute__((noinline)) void publication_store_word(volatile uint32_t* p, uint32_t v) { store(p, v); }
extern "C" __attribute__((noinline)) bool publication_load_byte(volatile bool* p) { return load(p); }
extern "C" __attribute__((noinline)) void publication_store_byte(volatile bool* p, bool v) { store(p, v); }

static void handler(int) {
  published* p = load(&owner);
  if (p && p->inverse != ~p->value) store(&signal_bad, uint32_t(1));
  store(&async_ack, load(&async_epoch));
  store(&signal_seen, uint32_t(1));
}

static void* producer(void*) {
  for (uint32_t i = 1; i <= rounds; ++i) {
    while (load(&ready)) sched_yield();
    payload = i;
    entries[i-1] = {i, ~i};
    store(&owner, &entries[i-1]);
    // Before ready, consumer cannot reach its synchronous raise(). Only the
    // producer's pthread_kill can acknowledge this new epoch.
    store(&async_epoch, i);
    assert(pthread_kill(consumer_thread, SIGUSR1) == 0);
    while (load(&async_ack) < i) sched_yield();
    store(&ready, true);
  }
  return nullptr;
}
static void* litmus(void* arg) {
  unsigned which = (unsigned)(uintptr_t)arg;
  for (uint32_t i = 1; i <= rounds; ++i) {
    while (load(&epoch) < i) sched_yield();
    if (which == 0) {
      store(&x, uint32_t(1));
      result[0] = load(&y);
    } else {
      store(&y, uint32_t(1));
      result[1] = load(&x);
    }
    store(&done[which], i);
  }
  return nullptr;
}
extern "C" __attribute__((noinline)) published* publication_load_pointer(published* volatile* p) { return load(p); }
extern "C" __attribute__((noinline)) void publication_store_pointer(published* volatile* p, published* v) { store(p, v); }
int main() {
  static_assert(sizeof(void*) == 4 && alignof(void*) == 4);
  static_assert(sizeof(bool) == 1 && alignof(uint32_t) == 4);
  printf("general RMW queries: byte=%d word=%d pointer=%d\n",
         __atomic_always_lock_free(1, nullptr),
         __atomic_always_lock_free(4, nullptr),
         __atomic_always_lock_free(sizeof(void*), nullptr));
#if defined(__NetBSD__) && defined(__SH3__)
  static_assert(factor::atomic::publication_lock_free<bool>());
  static_assert(factor::atomic::publication_lock_free<uint32_t>());
  static_assert(factor::atomic::publication_lock_free<published*>());
  static_assert(!factor::atomic::publication_lock_free<uint64_t>());
  assert(!factor::atomic::rmw_supported());
#endif
  consumer_thread = pthread_self();
  stack_t stack = {};
  stack.ss_sp = alternate_stack;
  stack.ss_size = sizeof(alternate_stack);
  assert(sigaltstack(&stack, nullptr) == 0);
  struct sigaction action = {};
  action.sa_handler = handler;
  action.sa_flags = SA_ONSTACK;
  sigemptyset(&action.sa_mask);
  assert(sigaction(SIGUSR1, &action, nullptr) == 0);
  pthread_t thread;
  assert(pthread_create(&thread, nullptr, producer, nullptr) == 0);
  for (uint32_t i = 1; i <= rounds; ++i) {
    while (!load(&ready)) sched_yield();
    assert(payload == i);
    assert(raise(SIGUSR1) == 0);
    store(&ready, false);
  }
  assert(pthread_join(thread, nullptr) == 0);
  store(&owner, (published*)nullptr);
  assert(raise(SIGUSR1) == 0);
  assert(load(&signal_seen) && !load(&signal_bad));
  assert(load(&async_ack) == rounds);

  puts("threaded payload and alternate-stack asynchronous signal passed");
  fflush(stdout);
  pthread_t workers[2];
  for (unsigned i = 0; i < 2; ++i)
    assert(pthread_create(&workers[i], nullptr, litmus, (void*)(uintptr_t)i) == 0);
  for (uint32_t i = 1; i <= rounds; ++i) {
    store(&x, uint32_t(0));
    store(&y, uint32_t(0));
    store(&epoch, i);
    while (load(&done[0]) < i || load(&done[1]) < i) sched_yield();
    assert(result[0] || result[1]);
  }
  for (auto worker : workers) assert(pthread_join(worker, nullptr) == 0);
  volatile int32_t signed_value;
  store(&signed_value, int32_t(-42));
  assert(load(&signed_value) == -42);
  puts("atomic publication: threaded payload, seq_cst ordering, signal byte/word/pointer passed");
}
