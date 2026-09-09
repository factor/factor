#include "../master.hpp"

namespace factor {
cell get_thread_pc(THREADHANDLE th);
}

static void* set_flag(void* arg) {
  InterlockedExchange(static_cast<volatile LONG*>(arg), 1);
  return arg;
}

static DWORD WINAPI wait_for_event(LPVOID event) {
  return WaitForSingleObject(event, INFINITE) == WAIT_OBJECT_0 ? 0 : 1;
}

int main() {
  factor::init_mvm();
  volatile LONG flag = 0;
  HANDLE thread = factor::start_thread(set_flag, (void*)&flag);
  if (WaitForSingleObject(thread, 5000) != WAIT_OBJECT_0 || flag != 1)
    return 1;
  DWORD exit_code;
  if (!GetExitCodeThread(thread, &exit_code) || exit_code != 0)
    return 2;
  CloseHandle(thread);

  // Profiling a thread already suspended by a debugger must preserve its
  // original suspend count rather than assert or resume it prematurely.
  HANDLE event = CreateEvent(NULL, TRUE, FALSE, NULL);
  if (!event)
    return 3;
  thread = CreateThread(NULL, 0, wait_for_event, event, CREATE_SUSPENDED, NULL);
  if (!thread)
    return 4;
  if (factor::get_thread_pc(thread) == 0)
    return 5;
  if (ResumeThread(thread) != 1)
    return 6;
  SetEvent(event);
  if (WaitForSingleObject(thread, 5000) != WAIT_OBJECT_0)
    return 7;
  CloseHandle(thread);
  CloseHandle(event);
  if (factor::get_thread_pc(NULL) != 0)
    return 8;
  return 0;
}
