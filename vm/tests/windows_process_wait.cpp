#include "../windows_process_wait.hpp"
#undef NDEBUG
#include <cassert>

int main() {
  HANDLE port = CreateIoCompletionPort(INVALID_HANDLE_VALUE, NULL, 0, 1);
  assert(port);
  const int count = 128; // Greater than MAXIMUM_WAIT_OBJECTS.
  HANDLE events[count];
  factor_process_wait* waits[count];
  bool received[count] = {};
  for (int i = 0; i < count; ++i) {
    // Exercise objects signaled both before and after registration.
    events[i] = CreateEvent(NULL, TRUE, i % 2 == 0, NULL);
    assert(events[i]);
    waits[i] = register_process_wait(events[i], port, i + 1);
    assert(waits[i]);
    assert(SetEvent(events[i]));
  }
  for (int i = 0; i < count; ++i) {
    DWORD bytes;
    ULONG_PTR key;
    OVERLAPPED* overlapped;
    assert(GetQueuedCompletionStatus(port, &bytes, &key, &overlapped, 5000));
    assert(bytes == 0 && overlapped == NULL);
    assert(key >= 1 && key <= count && !received[key - 1]);
    received[key - 1] = true;
  }
  for (int i = 0; i < count; ++i) {
    assert(unregister_process_wait(waits[i]));
    assert(CloseHandle(events[i]));
  }
  // Cancellation before signaling must prevent any callback.
  HANDLE event = CreateEvent(NULL, TRUE, FALSE, NULL);
  factor_process_wait* wait = register_process_wait(event, port, count + 1);
  assert(wait && unregister_process_wait(wait));
  assert(SetEvent(event));
  DWORD bytes;
  ULONG_PTR key;
  OVERLAPPED* overlapped;
  assert(!GetQueuedCompletionStatus(port, &bytes, &key, &overlapped, 50));
  assert(GetLastError() == WAIT_TIMEOUT);
  assert(CloseHandle(event));
  assert(CloseHandle(port));
}
