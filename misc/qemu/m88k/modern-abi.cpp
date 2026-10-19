#include <exception>
#include <new>
#include <stdexcept>
#include <cstring>
#include <cstdio>
#include <pthread.h>

struct outer_error : std::exception {};
struct guard_value { int value; guard_value() : value(42) {} };
static int guarded_value() { static guard_value value; return value.value; }
struct worker_data { std::exception_ptr error; int result; };
static void* worker(void* arg) {
  worker_data& data = *static_cast<worker_data*>(arg);
  data.result = 1;
  for (int i = 0; i != 64; ++i) {
    std::exception_ptr copy = data.error;
    try { std::rethrow_exception(copy); }
    catch (const std::runtime_error& error) {
      if (std::strcmp(error.what(), "inner") != 0) return 0;
    }
    catch (...) { return 0; }
    if (guarded_value() != 42) return 0;
  }
  data.result = 0;
  return 0;
}
int main() {
  worker_data data;
  try { throw std::runtime_error("inner"); }
  catch (...) { data.error = std::current_exception(); }
  if (!data.error) return 1;
  pthread_t thread;
  if (pthread_create(&thread, 0, worker, &data) != 0) return 2;
  for (int i = 0; i != 64; ++i) {
    std::exception_ptr copy = data.error;
    if (!copy || guarded_value() != 42) return 3;
  }
  if (pthread_join(thread, 0) != 0 || data.result != 0) return 4;
  data.error = std::exception_ptr();
  bool nested_ok = false;
  try {
    try { throw std::runtime_error("nested"); }
    catch (...) { std::throw_with_nested(outer_error()); }
  }
  catch (const outer_error& outer) {
    try { std::rethrow_if_nested(outer); }
    catch (const std::runtime_error& inner) {
      nested_ok = std::strcmp(inner.what(), "nested") == 0;
    }
  }
  if (!nested_ok) return 5;
  bool array_ok = false;
  try { throw std::bad_array_new_length(); }
  catch (const std::bad_array_new_length& error) {
    array_ok = std::strcmp(error.what(), "bad_array_new_length") == 0;
  }
  if (!array_ok) return 6;
  std::puts("m88k modern C++ ABI PASS");
}
