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

int main() {
  volatile bool ready = false;
  factor::cell payload = 0;
  constexpr factor::cell rounds = 100000;
  std::thread producer([&] {
    for (factor::cell i = 1; i <= rounds; ++i) {
      while (factor::atomic::load(&ready)) std::this_thread::yield();
      payload = i;
      factor::atomic::store(&ready, true);
    }
  });
  for (factor::cell i = 1; i <= rounds; ++i) {
    while (!factor::atomic::load(&ready)) std::this_thread::yield();
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
  volatile factor::fixnum signed_value = 0;
  factor::atomic::store(&signed_value, factor::fixnum(-42));
  assert(factor::atomic::load(&signed_value) == -42);
}
