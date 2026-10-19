#include <cstdio>
extern "C" void m88k_catch_pad_call();
int main() {
  std::puts("SjLj catch-pad invoke before throw"); std::fflush(stdout);
  try { throw 43; }
  catch (...) {
    std::puts("SjLj catch-pad invoke entered"); std::fflush(stdout);
    m88k_catch_pad_call();
  }
  std::puts("SjLj catch-pad invoke PASS");
}
