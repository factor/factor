#include "master.hpp"

namespace factor {

HMODULE hFactorDll;

[[nodiscard]] bool set_memory_locked(cell base, cell size, bool locked) {
  const DWORD prot = locked ? PAGE_NOACCESS : PAGE_READWRITE;
  DWORD old_prot;
  const BOOL status = VirtualProtect(reinterpret_cast<void*>(base), static_cast<SIZE_T>(size), prot, &old_prot);
  return status != 0;
}

[[nodiscard]] void* native_dlopen(const char* path) {
  // Convert UTF-8 path to wide char for Unicode support
  int size_needed = MultiByteToWideChar(CP_UTF8, 0, path, -1, nullptr, 0);
  if (size_needed == 0) {
    return nullptr;
  }

  auto wide_path = std::make_unique<wchar_t[]>(size_needed);
  int result = MultiByteToWideChar(CP_UTF8, 0, path, -1, wide_path.get(), size_needed);
  if (result == 0) {
    return nullptr;
  }

  return LoadLibraryExW(wide_path.get(), nullptr, 0);
}

[[nodiscard]] void* native_dlsym(void* handle, const char* symbol) {
  return reinterpret_cast<void*>(GetProcAddress(static_cast<HMODULE>(handle), symbol));
}

void native_dlclose(void* handle) {
  FreeLibrary(static_cast<HMODULE>(handle));
}

void factor_vm::init_ffi() {
  hFactorDll = GetModuleHandle(nullptr);
  if (!hFactorDll)
    fatal_error("GetModuleHandle() failed", 0);
}

void factor_vm::ffi_dlopen(dll* dll) {
  dll->handle = LoadLibraryEx(reinterpret_cast<WCHAR*>(alien_offset(dll->path)), nullptr, 0);
}

std::optional<cell> factor_vm::ffi_dlsym(dll* dll, symbol_char* symbol) {
  void* addr = GetProcAddress(dll ? static_cast<HMODULE>(dll->handle) : hFactorDll, symbol);
  return addr ? std::optional<cell>(cell_from_ptr(addr)) : std::nullopt;
}

void factor_vm::ffi_dlclose(dll* dll) {
  FreeLibrary(static_cast<HMODULE>(dll->handle));
  dll->handle = nullptr;
}

[[nodiscard]] BOOL factor_vm::windows_stat(vm_char* path) {
  BY_HANDLE_FILE_INFORMATION bhfi;
  HANDLE h = CreateFileW(path, FILE_READ_ATTRIBUTES, 0, nullptr,
                         OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, nullptr);

  if (h == INVALID_HANDLE_VALUE) {
    // FindFirstFile is the only call that can stat c:\pagefile.sys
    WIN32_FIND_DATA st;
    h = FindFirstFile(path, &st);
    if (h == INVALID_HANDLE_VALUE)
      return false;
    FindClose(h);
    return true;
  }
  BOOL ret = GetFileInformationByHandle(h, &bhfi);
  CloseHandle(h);
  return ret;
}

// You must free() this yourself.
[[nodiscard]] const vm_char* factor_vm::default_image_path() {
  // Use heap allocation instead of stack to avoid C6262 warning (131KB stack usage)
  auto full_path = std::make_unique<vm_char[]>(MAX_UNICODE_PATH);
  vm_char* ptr;
  auto temp_path = std::make_unique<vm_char[]>(MAX_UNICODE_PATH);

  if (!GetModuleFileName(nullptr, full_path.get(), MAX_UNICODE_PATH))
    fatal_error("GetModuleFileName() failed", 0);

  if ((ptr = wcsrchr(full_path.get(), L'.')))
    *ptr = L'\0';

  // Fix C6053 warning: ensure nullptr termination
  wcsncpy_s(temp_path.get(), MAX_UNICODE_PATH, full_path.get(), _TRUNCATE);
  size_t full_path_len = wcslen(full_path.get());
  if (full_path_len < MAX_UNICODE_PATH - 7) // Reserve space for ".image" + nullptr terminator
    wcscat_s(temp_path.get(), MAX_UNICODE_PATH, L".image");

  return safe_strdup(temp_path.get());
}

// You must free() this yourself.
[[nodiscard]] const vm_char* factor_vm::vm_executable_path() {
  // Use heap allocation instead of stack to avoid C6262 warning (65KB stack usage)
  auto full_path = std::make_unique<vm_char[]>(MAX_UNICODE_PATH);
  if (!GetModuleFileName(nullptr, full_path.get(), MAX_UNICODE_PATH))
    fatal_error("GetModuleFileName() failed", 0);
  return safe_strdup(full_path.get());
}

void factor_vm::primitive_existsp() {
  vm_char* path = untag_check<byte_array>(ctx->pop())->data<vm_char>();
  ctx->push(tag_boolean(windows_stat(path)));
}

segment::segment(cell size_, bool executable_p) {
  size = size_;

  char* mem;
  long pagesize = getpagesize();
  cell guard_size = static_cast<cell>(segment_guard_pages) * pagesize;
  cell alloc_size = guard_size * 2 + size;
  if ((mem = static_cast<char*>(VirtualAlloc(
           nullptr, alloc_size, MEM_COMMIT,
           executable_p ? PAGE_EXECUTE_READWRITE : PAGE_READWRITE))) ==
      nullptr) {
    fatal_error("Out of memory in VirtualAlloc", alloc_size);
  }

  start = cell_from_ptr(mem) + guard_size;
  end = start + size;

  set_border_locked(true);
}

segment::~segment() {
  long pagesize = getpagesize();
  cell guard_size = static_cast<cell>(segment_guard_pages) * pagesize;
  if (!VirtualFree(reinterpret_cast<void*>(start - guard_size), 0, MEM_RELEASE))
    fatal_error("Segment deallocation failed", 0);
}


[[nodiscard]] long getpagesize() {
  static long g_pagesize = 0;
  if (!g_pagesize) {
    SYSTEM_INFO system_info;
    GetSystemInfo(&system_info);
    g_pagesize = system_info.dwPageSize;
  }
  return g_pagesize;
}

[[nodiscard]] bool move_file(const vm_char* path1, const vm_char* path2) {
  // MoveFileEx returns FALSE on fail.
  BOOL val = MoveFileEx((path1), (path2), MOVEFILE_REPLACE_EXISTING);
  if (val == FALSE) {
    // MoveFileEx doesn't set errno, which primitive_save_image()
    // reads the error code from. Instead of converting from
    // GetLastError() to errno values, we ust set it to the generic
    // EIO value.
    errno = EIO;
  }
  return val == TRUE;
}

void factor_vm::init_signals() {}

[[nodiscard]] THREADHANDLE start_thread(void* (*start_routine)(void*), void* args) {
  return CreateThread(nullptr, 0, reinterpret_cast<LPTHREAD_START_ROUTINE>(start_routine), args, 0, nullptr);
}

[[nodiscard]] uint64_t nano_count() {
  static double scale_factor;

  static uint32_t hi = 0;
  static uint32_t lo = 0;

  // Note: on older systems QueryPerformanceCounter may be unreliable
  // until you add /usepmtimer to Boot.ini. I had an issue where two
  // nano_count calls would show a difference of about 1 second,
  // while actually about 80 seconds have passed. The /usepmtimer
  // switch cured the issue on that PC (WinXP Pro SP3 32-bit).
  // See also http://www.virtualdub.org/blog/pivot/entry.php?id=106
  LARGE_INTEGER count;
  BOOL ret = QueryPerformanceCounter(&count);
  if (ret == 0)
    fatal_error("QueryPerformanceCounter", 0);

  if (scale_factor == 0.0) {
    LARGE_INTEGER frequency;
    BOOL freq_ret = QueryPerformanceFrequency(&frequency);
    if (freq_ret == 0)
      fatal_error("QueryPerformanceFrequency", 0);
    scale_factor = (1000000000.0 / frequency.QuadPart);
  }

#ifdef FACTOR_64
  hi = count.HighPart;
#else
  // On VirtualBox, QueryPerformanceCounter does not increment
  // the high part every time the low part overflows.  Workaround.
  if (lo > count.LowPart)
    hi++;
#endif
  lo = count.LowPart;

  return static_cast<uint64_t>(((static_cast<uint64_t>(hi) << 32) | static_cast<uint64_t>(lo)) * scale_factor);
}

void sleep_nanos(uint64_t nsec) { Sleep(static_cast<DWORD>(nsec / 1000000)); }

#ifndef EXCEPTION_DISPOSITION
typedef enum _EXCEPTION_DISPOSITION {
  ExceptionContinueExecution = 0,
  ExceptionContinueSearch = 1,
  ExceptionNestedException = 2,
  ExceptionCollidedUnwind = 3
} EXCEPTION_DISPOSITION;
#endif

LONG factor_vm::exception_handler(PEXCEPTION_RECORD e, void* frame, PCONTEXT c,
                                  void* dispatch) {
  (void)frame;
  (void)dispatch;
  switch (e->ExceptionCode) {
    case EXCEPTION_ACCESS_VIOLATION:
      set_memory_protection_error(e->ExceptionInformation[1], c->EIP);
      dispatch_signal_handler(reinterpret_cast<cell*>(&c->ESP), reinterpret_cast<cell*>(&c->EIP),
                              cell_from_ptr(factor::memory_signal_handler_impl));
      break;

    case STATUS_FLOAT_DENORMAL_OPERAND:
    case STATUS_FLOAT_DIVIDE_BY_ZERO:
    case STATUS_FLOAT_INEXACT_RESULT:
    case STATUS_FLOAT_INVALID_OPERATION:
    case STATUS_FLOAT_OVERFLOW:
    case STATUS_FLOAT_STACK_CHECK:
    case STATUS_FLOAT_UNDERFLOW:
    case STATUS_FLOAT_MULTIPLE_FAULTS:
    case STATUS_FLOAT_MULTIPLE_TRAPS:
#ifdef FACTOR_64
      signal_fpu_status = fpu_status(MXCSR(c));
#else
      signal_fpu_status = fpu_status(X87SW(c) | MXCSR(c));

      // This seems to have no effect
      X87SW(c) = 0;
#endif
      MXCSR(c) &= 0xffffffc0;
      dispatch_signal_handler(reinterpret_cast<cell*>(&c->ESP), reinterpret_cast<cell*>(&c->EIP),
                              cell_from_ptr(factor::fp_signal_handler_impl));
      break;
    default:
      signal_number = e->ExceptionCode;
      dispatch_signal_handler(reinterpret_cast<cell*>(&c->ESP), reinterpret_cast<cell*>(&c->EIP),
                              cell_from_ptr(factor::synchronous_signal_handler_impl));
      break;
  }
  return ExceptionContinueExecution;
}

VM_C_API LONG exception_handler(PEXCEPTION_RECORD e, void* frame, PCONTEXT c,
                                void* dispatch) {
  factor_vm* vm = current_vm_p();
  if (factor_vm::fatal_erroring_p || !vm)
    return ExceptionContinueSearch;
  return vm->exception_handler(e, frame, c, dispatch);
}

// On Unix SIGINT (ctrl-c) automatically interrupts blocking io system
// calls. It doesn't on Windows, so we need to manually send some
// cancellation requests to unblock the thread.
VOID CALLBACK dummy_cb(ULONG_PTR dwParam) { (void)dwParam; }

static void wake_up_thread(HANDLE thread) {
  if (!CancelSynchronousIo(thread)) {
    DWORD err = GetLastError();
    // CancelSynchronousIo() didn't find anything to cancel, let's try
    // with QueueUserAPC() instead.
    if (err == ERROR_NOT_FOUND) {
      if (!QueueUserAPC(&dummy_cb, thread, 0)) {
        fatal_error("QueueUserAPC() failed", GetLastError());
      }
    } else {
      fatal_error("CancelSynchronousIo() failed", err);
    }
  }
}

static BOOL WINAPI ctrl_handler(DWORD dwCtrlType) {
  switch (dwCtrlType) {
    case CTRL_C_EVENT: {
      // The CtrlHandler runs in its own thread without stopping the main
      // thread. Since in practice nobody uses the multi-VM stuff yet, we just
      // grab the first VM we can get. This will not be a good idea when we
      // actually support native threads.
      FACTOR_ASSERT(thread_vms.size() == 1);
      auto [thread, vm] = *thread_vms.begin();
      vm->enqueue_fep();

      // Before leaving the ctrl_handler, try and wake up the main thread.
      wake_up_thread(factor::boot_thread);
      return TRUE;
    }
    default:
      return FALSE;
  }
}

void open_console() { handle_ctrl_c(); }

void ignore_ctrl_c() {
  SetConsoleCtrlHandler(factor::ctrl_handler, FALSE);
}

void handle_ctrl_c() {
  SetConsoleCtrlHandler(factor::ctrl_handler, TRUE);
}

constexpr int ctrl_break_sleep = 10; /* msec */

static DWORD WINAPI ctrl_break_thread_proc(LPVOID parent_vm) {
  bool ctrl_break_handled = false;
  factor_vm* vm = static_cast<factor_vm*>(parent_vm);
  while (vm->stop_on_ctrl_break) {
    if (GetAsyncKeyState(VK_CANCEL) >= 0) { /* Ctrl-Break is released. */
      ctrl_break_handled = false;  /* Wait for the next press. */
    } else if (!ctrl_break_handled) {
      /* Check if the VM thread has the same Id as the thread Id of the
         currently active window. Note that thread Id is not a handle. */
      DWORD fg_thd_id = GetWindowThreadProcessId(GetForegroundWindow(), nullptr);
      if ((fg_thd_id == vm->thread_id) && !vm->fep_p) {
        vm->enqueue_fep();
        ctrl_break_handled = true;
      }
    }
    Sleep(ctrl_break_sleep);
  }
  return 0;
}

void factor_vm::primitive_disable_ctrl_break() {
  stop_on_ctrl_break = false;
  if (ctrl_break_thread != nullptr) {
    DWORD wait_result = WaitForSingleObject(ctrl_break_thread,
                                            2 * ctrl_break_sleep);
    // Avoid TerminateThread (C6258) - give thread more time to exit gracefully
    if (wait_result != WAIT_OBJECT_0) {
      // Try waiting a bit longer before giving up
      wait_result = WaitForSingleObject(ctrl_break_thread, 1000);
      if (wait_result != WAIT_OBJECT_0) {
        // As last resort, terminate the thread (unavoidable in this context)
#if defined(_MSC_VER)
#pragma warning(suppress:6258)
#endif
        TerminateThread(ctrl_break_thread, 0);
      }
    }
    CloseHandle(ctrl_break_thread);
    ctrl_break_thread = nullptr;
  }
}

void factor_vm::primitive_enable_ctrl_break() {
  stop_on_ctrl_break = true;
  if (ctrl_break_thread == nullptr) {
    DisableProcessWindowsGhosting();
    ctrl_break_thread = CreateThread(nullptr, 0, factor::ctrl_break_thread_proc,
                                     static_cast<LPVOID>(this), 0, nullptr);
    // Fix C6387 warning: check for nullptr before calling SetThreadPriority
    if (ctrl_break_thread != nullptr) {
      SetThreadPriority(ctrl_break_thread, THREAD_PRIORITY_ABOVE_NORMAL);
    } else {
      fatal_error("CreateThread failed for ctrl_break_thread", GetLastError());
    }
  }
}

void lock_console() {}

void unlock_console() {}

void close_console() {}

[[nodiscard]] cell get_thread_pc(THREADHANDLE th) {
  DWORD suscount = SuspendThread(th);
  FACTOR_ASSERT(suscount == 0);

  CONTEXT context;
  memset(&context, 0, sizeof(CONTEXT));
  context.ContextFlags = CONTEXT_CONTROL;
  BOOL context_ok = GetThreadContext(th, &context);
  FACTOR_ASSERT(context_ok);

  suscount = ResumeThread(th);
  FACTOR_ASSERT(suscount == 1);

  (void)suscount, (void)context_ok; // use all variables

  return context.EIP;
}

void factor_vm::sampler_thread_loop() {
  LARGE_INTEGER counter, new_counter, units_per_second;
  DWORD ok;

  ok = QueryPerformanceFrequency(&units_per_second);
  FACTOR_ASSERT(ok);

  ok = QueryPerformanceCounter(&counter);
  FACTOR_ASSERT(ok);

  counter.QuadPart *= samples_per_second;
  while (atomic::load(&sampling_profiler_p)) {
    SwitchToThread();
    ok = QueryPerformanceCounter(&new_counter);
    FACTOR_ASSERT(ok);
    new_counter.QuadPart *= samples_per_second;
    cell sample_count = 0;
    while (new_counter.QuadPart - counter.QuadPart >
           units_per_second.QuadPart) {
      ++sample_count;
      counter.QuadPart += units_per_second.QuadPart;
    }
    if (sample_count == 0)
      continue;

    cell pc = get_thread_pc(thread);
    enqueue_samples(sample_count, pc, false);
  }

  (void)ok; // use all variables

}

static DWORD WINAPI sampler_thread_entry(LPVOID parent_vm) {
  static_cast<factor_vm*>(parent_vm)->sampler_thread_loop();
  return 0;
}

void factor_vm::start_sampling_profiler_timer() {
  sampler_thread = CreateThread(nullptr, 0, &sampler_thread_entry,
                                static_cast<LPVOID>(this), 0, nullptr);
}

void factor_vm::end_sampling_profiler_timer() {
  atomic::store(&sampling_profiler_p, false);
  DWORD wait_result =
      WaitForSingleObject(sampler_thread, 3000 * static_cast<DWORD>(samples_per_second));
  // Avoid TerminateThread (C6258) - give thread more time to exit gracefully
  if (wait_result != WAIT_OBJECT_0) {
    // Try waiting a bit longer before giving up
    wait_result = WaitForSingleObject(sampler_thread, 2000);
    if (wait_result != WAIT_OBJECT_0) {
      // As last resort, terminate the thread (unavoidable in this context)
#if defined(_MSC_VER)
#pragma warning(suppress:6258)
#endif
      TerminateThread(sampler_thread, 0);
    }
  }
  CloseHandle(sampler_thread);
  sampler_thread = nullptr;
}

[[noreturn]] void abort() { ::abort(); }

}


