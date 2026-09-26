#pragma once

// Native thread-pool callbacks must never enter the Factor VM.
// The completion port transfers notification to the scheduler thread.
#include <windows.h>
#include <new>

struct factor_process_wait {
  HANDLE wait;
  HANDLE port;
  ULONG_PTR key;
};

static VOID CALLBACK factor_process_wait_callback(PVOID context, BOOLEAN) {
  factor_process_wait* wait = static_cast<factor_process_wait*>(context);
  PostQueuedCompletionStatus(wait->port, 0, wait->key, NULL);
}

static factor_process_wait* register_process_wait(HANDLE process, HANDLE port,
                                                 ULONG_PTR key) {
  factor_process_wait* wait = new (std::nothrow) factor_process_wait;
  if (!wait) {
    SetLastError(ERROR_NOT_ENOUGH_MEMORY);
    return NULL;
  }
  wait->port = port;
  wait->key = key;
  if (!RegisterWaitForSingleObject(&wait->wait, process,
                                  factor_process_wait_callback, wait, INFINITE,
                                  WT_EXECUTEONLYONCE)) {
    DWORD error = GetLastError();
    delete wait;
    SetLastError(error);
    return NULL;
  }
  return wait;
}

static BOOL unregister_process_wait(factor_process_wait* wait) {
  // Wait for a callback already in flight before freeing its context.
  if (!UnregisterWaitEx(wait->wait, INVALID_HANDLE_VALUE))
    return FALSE;
  delete wait;
  return TRUE;
}
