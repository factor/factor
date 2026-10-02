#pragma once

#include <windows.h>
#include <new>
#include <string>

struct factor_file_copy {
  std::wstring source;
  std::wstring destination;
  HANDLE port;
  ULONG_PTR key;
  PTP_WORK work;
  DWORD error;
};

static VOID CALLBACK factor_file_copy_callback(PTP_CALLBACK_INSTANCE,
                                               PVOID context, PTP_WORK) {
  factor_file_copy* copy = static_cast<factor_file_copy*>(context);
  copy->error =
      CopyFileW(copy->source.c_str(), copy->destination.c_str(), FALSE)
          ? ERROR_SUCCESS : GetLastError();
  // Only the scheduler thread may resume Factor continuations.
  PostQueuedCompletionStatus(copy->port, 0, copy->key, NULL);
}

static factor_file_copy* begin_file_copy(const wchar_t* source,
                                        const wchar_t* destination,
                                        HANDLE port, ULONG_PTR key) {
  factor_file_copy* copy = NULL;
  try {
    copy = new factor_file_copy;
    // FFI strings may move or disappear as soon as this call returns.
    copy->source = source;
    copy->destination = destination;
  } catch (const std::bad_alloc&) {
    delete copy;
    SetLastError(ERROR_NOT_ENOUGH_MEMORY);
    return NULL;
  }
  copy->port = port;
  copy->key = key;
  copy->error = ERROR_SUCCESS;
  copy->work = CreateThreadpoolWork(factor_file_copy_callback, copy, NULL);
  if (!copy->work) {
    DWORD error = GetLastError();
    delete copy;
    SetLastError(error);
    return NULL;
  }
  SubmitThreadpoolWork(copy->work);
  return copy;
}

static DWORD finish_file_copy(factor_file_copy* copy) {
  // A dequeued packet can precede the native callback's return.
  WaitForThreadpoolWorkCallbacks(copy->work, FALSE);
  CloseThreadpoolWork(copy->work);
  DWORD error = copy->error;
  delete copy;
  return error;
}
