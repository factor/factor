// Standalone native-thread regression for VM publication primitives.
#include <cassert>
#include <cstdint>
#include <thread>
#include <vector>

namespace factor {
using cell = uintptr_t;
using fixnum = intptr_t;
}
#include "../atomic-gcc.hpp"

#ifdef FACTOR_OPENBSD_HPPA_MASKED_RMW
#include <sched.h>
#endif

static void yield_native_thread() {
#ifdef FACTOR_OPENBSD_HPPA_MASKED_RMW
  // This cross libstdc++ builds std::this_thread::yield() as a no-op.
  // Preserve the publication test's native scheduler-yield intent.
  sched_yield();
#else
  std::this_thread::yield();
#endif
}

int main() {
#ifdef FACTOR_OPENBSD_HPPA_MASKED_RMW
  assert(!factor::atomic::rmw_supported());
  volatile factor::cell before_init = 0;
  factor::atomic::store(&before_init, factor::cell(19));
  assert(factor::atomic::load(&before_init) == 19);
  assert(!factor::atomic::rmw_supported());
#endif
#ifdef FACTOR_NETBSD_RAS
  if (!factor::atomic::ras::initialize()) return 77;
#endif
#ifdef FACTOR_OPENBSD_HPPA_MASKED_RMW
  if (!factor::atomic::openbsd_hppa::initialize()) return 77;
#endif
  if (!factor::atomic::rmw_supported()) return 77;
  volatile bool ready = false;
  factor::cell payload = 0;
  constexpr factor::cell rounds = 100000;
  std::thread producer([&] {
    for (factor::cell i = 1; i <= rounds; ++i) {
      while (factor::atomic::load(&ready)) yield_native_thread();
      payload = i;
      factor::atomic::store(&ready, true);
    }
  });
  for (factor::cell i = 1; i <= rounds; ++i) {
    while (!factor::atomic::load(&ready)) yield_native_thread();
    assert(payload == i);
    factor::atomic::store(&ready, false);
  }
  producer.join();

  volatile factor::cell total = 0;
  std::vector<std::thread> workers;
  for (int i = 0; i < 4; ++i)
    workers.emplace_back([&] {
      for (factor::cell j = 0; j < rounds; ++j)
        factor::atomic::fetch_add(&total, factor::cell(1));
    });
  for (auto& worker : workers) worker.join();
  assert(factor::atomic::load(&total) == 4 * rounds);
  assert(factor::atomic::cas(&total, factor::cell(4 * rounds), factor::cell(17)));
  assert(!factor::atomic::cas(&total, factor::cell(18), factor::cell(99)));
  assert(factor::atomic::fetch_subtract(&total, factor::cell(5)) == 17);
  assert(factor::atomic::load(&total) == 12);
  volatile factor::fixnum signed_value = 0;
  factor::atomic::store(&signed_value, factor::fixnum(-42));
  assert(factor::atomic::load(&signed_value) == -42);
  assert(factor::atomic::fetch_add(&signed_value, factor::fixnum(-3)) == -42);
  assert(factor::atomic::fetch_subtract(&signed_value, factor::fixnum(-5)) == -45);
  assert(factor::atomic::load(&signed_value) == -40);
  assert(factor::atomic::cas(&signed_value, factor::fixnum(-40), factor::fixnum(-7)));
  assert(!factor::atomic::cas(&signed_value, factor::fixnum(-40), factor::fixnum(99)));
  assert(factor::atomic::load(&signed_value) == -7);

  // Race stores with arithmetic updates to the same word. A store of 100
  // racing add(1) from zero can finish as 100 or 101; 1 loses the store.
  // CAS(0,1) racing that store must finish as 100 in either legal ordering.
  volatile factor::cell mixed = 0, requested = 0;
  volatile factor::cell store_done = 0, update_done = 0;
  constexpr factor::cell mixed_rounds = 10000;
  std::thread mixed_store([&] {
    for (factor::cell round = 1; round <= mixed_rounds; ++round) {
      while (factor::atomic::load(&requested) != round) yield_native_thread();
      factor::atomic::store(&mixed, factor::cell(100));
      factor::atomic::store(&store_done, round);
    }
  });
  std::thread mixed_update([&] {
    for (factor::cell round = 1; round <= mixed_rounds; ++round) {
      while (factor::atomic::load(&requested) != round) yield_native_thread();
      if (round & 1) {
        auto previous = factor::atomic::fetch_add(&mixed, factor::cell(1));
        assert(previous == 0 || previous == 100);
      } else {
        factor::atomic::cas(&mixed, factor::cell(0), factor::cell(1));
      }
      factor::atomic::store(&update_done, round);
    }
  });
  for (factor::cell round = 1; round <= mixed_rounds; ++round) {
    factor::atomic::store(&mixed, factor::cell(0));
    factor::atomic::store(&requested, round);
    while (factor::atomic::load(&store_done) != round ||
           factor::atomic::load(&update_done) != round) yield_native_thread();
    auto result = factor::atomic::load(&mixed);
    if (round & 1) assert(result == 100 || result == 101);
    else assert(result == 100);
  }
  mixed_store.join();
  mixed_update.join();
  return 0;
}
