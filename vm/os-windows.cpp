#include "master.hpp"

namespace factor {

HMODULE hFactorDll;

bool set_memory_locked(cell base, cell size, bool locked) {
  int prot = locked ? PAGE_NOACCESS : PAGE_READWRITE;
  DWORD old_protection;
  int status = VirtualProtect((char*)base, size, prot, &old_protection);
  return status != 0;
}

void* native_dlopen(const char* path) {
  return LoadLibraryExA(path, NULL, 0);
}

void* native_dlsym(void* handle, const char* symbol) {
  return (void*)GetProcAddress((HMODULE)handle, symbol);
}

void native_dlclose(void* handle) {
  FreeLibrary((HMODULE)handle);
}

void factor_vm::init_ffi() {
  hFactorDll = GetModuleHandle(NULL);
  if (!hFactorDll)
    fatal_error("GetModuleHandle() failed", 0);
}

void factor_vm::ffi_dlopen(dll* dll) {
  dll->handle = LoadLibraryEx((WCHAR*)alien_offset(dll->path), NULL, 0);
}

cell factor_vm::ffi_dlsym(dll* dll, symbol_char* symbol) {
  return (cell)GetProcAddress(dll ? (HMODULE) dll->handle : hFactorDll,
                              symbol);
}

void factor_vm::ffi_dlclose(dll* dll) {
  FreeLibrary((HMODULE) dll->handle);
  dll->handle = NULL;
}

BOOL factor_vm::windows_stat(vm_char* path) {
  BY_HANDLE_FILE_INFORMATION bhfi;
  HANDLE h = CreateFileW(path, FILE_READ_ATTRIBUTES, 0, NULL,
                         OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, NULL);

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
const vm_char* factor_vm::default_image_path() {
  vm_char full_path[MAX_UNICODE_PATH];
  vm_char* ptr;
  vm_char temp_path[MAX_UNICODE_PATH];

  if (!GetModuleFileName(NULL, full_path, MAX_UNICODE_PATH))
    fatal_error("GetModuleFileName() failed", 0);

  ptr = wcsrchr(full_path, '.');
  if (ptr)
    *ptr = 0;

  wcsncpy(temp_path, full_path, MAX_UNICODE_PATH - 1);
  size_t full_path_len = wcslen(full_path);
  if (full_path_len < MAX_UNICODE_PATH - 1)
    wcsncat(temp_path, L".image", MAX_UNICODE_PATH - full_path_len - 1);
  temp_path[MAX_UNICODE_PATH - 1] = 0;

  return safe_strdup(temp_path);
}

// You must free() this yourself.
const vm_char* factor_vm::vm_executable_path() {
  vm_char full_path[MAX_UNICODE_PATH];
  if (!GetModuleFileName(NULL, full_path, MAX_UNICODE_PATH))
    fatal_error("GetModuleFileName() failed", 0);
  return safe_strdup(full_path);
}

void factor_vm::primitive_existsp() {
  vm_char* path = untag_check<byte_array>(ctx->pop())->data<vm_char>();
  ctx->push(tag_boolean(windows_stat(path)));
}

segment::segment(cell size_, bool executable_p, cell low_guard_size_) {
  size = size_;
  low_guard_size = std::max((cell)getpagesize(), align_page(low_guard_size_));

  char* mem;
  cell alloc_size = low_guard_size + getpagesize() + size;
  if ((mem = (char*)VirtualAlloc(
           NULL, alloc_size, MEM_COMMIT,
           executable_p ? PAGE_EXECUTE_READWRITE : PAGE_READWRITE)) ==
      0) {
    fatal_error("Out of memory in VirtualAlloc", alloc_size);
  }

  start = (cell)mem + low_guard_size;
  end = start + size;

  set_border_locked(true);
}

segment::~segment() {
  if (!VirtualFree((void*)(start - low_guard_size), 0, MEM_RELEASE))
    fatal_error("Segment deallocation failed", 0);
}

long getpagesize() {
  static long g_pagesize = 0;
  if (!g_pagesize) {
    SYSTEM_INFO system_info;
    GetSystemInfo(&system_info);
    g_pagesize = system_info.dwPageSize;
  }
  return g_pagesize;
}

bool move_file(const vm_char* path1, const vm_char* path2) {
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

struct windows_thread_args {
  void* (*start_routine)(void*);
  void* args;
};

static DWORD WINAPI windows_thread_entry(LPVOID arg) {
  windows_thread_args* args = static_cast<windows_thread_args*>(arg);
  windows_thread_args start = *args;
  delete args;
  start.start_routine(start.args);
  return 0;
}

THREADHANDLE start_thread(void* (*start_routine)(void*), void* args) {
  windows_thread_args* start = new windows_thread_args;
  start->start_routine = start_routine;
  start->args = args;
  HANDLE thread = CreateThread(NULL, 0, windows_thread_entry, start, 0, NULL);
  if (thread == NULL) {
    DWORD error = GetLastError();
    delete start;
    fatal_error("CreateThread() failed", error);
  }
  return thread;
}

uint64_t nano_count() {
  static const double scale_factor = []() {
    LARGE_INTEGER frequency;
    if (!QueryPerformanceFrequency(&frequency))
      fatal_error("QueryPerformanceFrequency", 0);
    return 1000000000.0 / frequency.QuadPart;
  }();

  LARGE_INTEGER count;
  BOOL ret = QueryPerformanceCounter(&count);
  if (ret == 0)
    fatal_error("QueryPerformanceCounter", 0);

  return (uint64_t)(count.QuadPart * scale_factor);
}

void sleep_nanos(uint64_t nsec) {
  uint64_t millis = nsec / 1000000;
  // INFINITE is reserved by Sleep; larger intervals also cannot be narrowed
  // to DWORD without wrapping. Split long finite sleeps into finite chunks.
  while (millis >= INFINITE) {
    Sleep(INFINITE - 1);
    millis -= INFINITE - 1;
  }
  Sleep((DWORD)millis);
}

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
    case EXCEPTION_STACK_OVERFLOW:
      // Unlike access violations, stack overflows do not promise fault
      // address parameters. Classify them using the current callstack guard.
      set_memory_protection_error(ctx->callstack_seg->start - 1, c->EIP);
      dispatch_signal_handler((cell*)&c->ESP, (cell*)&c->EIP,
                              (cell)factor::memory_signal_handler_impl);
      break;
    case STATUS_GUARD_PAGE_VIOLATION:
    case EXCEPTION_ACCESS_VIOLATION:
      set_memory_protection_error(e->ExceptionInformation[1], c->EIP);
      dispatch_signal_handler((cell*)&c->ESP, (cell*)&c->EIP,
                              (cell)factor::memory_signal_handler_impl);
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
#ifndef FACTOR_ARM64
#ifdef FACTOR_64
      signal_fpu_status = fpu_status(MXCSR(c));
#else
      signal_fpu_status = fpu_status(X87SW(c) | MXCSR(c));

      // This seems to have no effect
      X87SW(c) = 0;
#endif
      MXCSR(c) &= 0xffffffc0;
#else
      signal_fpu_status = fpu_status(c->Fpsr);
      c->Fpsr = 0;
#endif
      dispatch_signal_handler((cell*)&c->ESP, (cell*)&c->EIP,
                              (cell)factor::fp_signal_handler_impl);
      break;
    default:
      signal_number = e->ExceptionCode;
      dispatch_signal_handler((cell*)&c->ESP, (cell*)&c->EIP,
                              (cell)factor::synchronous_signal_handler_impl);
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
      factor_vm* vm = thread_vms.begin()->second;
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

const int ctrl_break_sleep = 10; /* msec */

static DWORD WINAPI ctrl_break_thread_proc(LPVOID parent_vm) {
  bool ctrl_break_handled = false;
  factor_vm* vm = static_cast<factor_vm*>(parent_vm);
  while (atomic::load(&vm->stop_on_ctrl_break)) {
    if (GetAsyncKeyState(VK_CANCEL) >= 0) { /* Ctrl-Break is released. */
      ctrl_break_handled = false;  /* Wait for the next press. */
    } else if (!ctrl_break_handled) {
      /* Check if the VM thread has the same Id as the thread Id of the
         currently active window. Note that thread Id is not a handle. */
      DWORD fg_thd_id = GetWindowThreadProcessId(GetForegroundWindow(), NULL);
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
  atomic::store(&stop_on_ctrl_break, false);
  if (ctrl_break_thread != NULL) {
    if (WaitForSingleObject(ctrl_break_thread, INFINITE) != WAIT_OBJECT_0)
      fatal_error("Waiting for Ctrl-Break thread failed", GetLastError());
    CloseHandle(ctrl_break_thread);
    ctrl_break_thread = NULL;
  }
}

void factor_vm::primitive_enable_ctrl_break() {
  atomic::store(&stop_on_ctrl_break, true);
  if (ctrl_break_thread == NULL) {
    DisableProcessWindowsGhosting();
    ctrl_break_thread = CreateThread(NULL, 0, factor::ctrl_break_thread_proc,
                                     static_cast<LPVOID>(this), 0, NULL);
    if (ctrl_break_thread == NULL)
      fatal_error("Creating Ctrl-Break thread failed", GetLastError());
    SetThreadPriority(ctrl_break_thread, THREAD_PRIORITY_ABOVE_NORMAL);
  }
}

void lock_console() {}

void unlock_console() {}

void close_console() {}

cell get_thread_pc(THREADHANDLE th) {
  DWORD suscount = SuspendThread(th);
  if (suscount == (DWORD)-1)
    return 0;

  CONTEXT context;
  memset((void*)&context, 0, sizeof(CONTEXT));
  context.ContextFlags = CONTEXT_CONTROL;
  BOOL context_ok = GetThreadContext(th, &context);

  suscount = ResumeThread(th);
  if (suscount == (DWORD)-1)
    fatal_error("ResumeThread() failed", GetLastError());

  return context_ok ? context.EIP : 0;
}

void factor_vm::sampler_thread_loop() {
  LARGE_INTEGER counter, new_counter, units_per_second;
  DWORD ok;

  ok = QueryPerformanceFrequency(&units_per_second);
  FACTOR_ASSERT(ok);

  ok = QueryPerformanceCounter(&counter);
  FACTOR_ASSERT(ok);

  // Scale elapsed time only: scaling the absolute QPC value can overflow
  // after sufficient system uptime. Carry fractional samples between polls.
  double pending_samples = 0;
  while (atomic::load(&sampling_profiler_p)) {
    SwitchToThread();
    ok = QueryPerformanceCounter(&new_counter);
    FACTOR_ASSERT(ok);
    pending_samples += (double)(new_counter.QuadPart - counter.QuadPart) /
                       units_per_second.QuadPart * samples_per_second;
    counter = new_counter;
    cell sample_count = (cell)pending_samples;
    pending_samples -= sample_count;
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
  sampler_thread = CreateThread(NULL, 0, &sampler_thread_entry,
                                static_cast<LPVOID>(this), 0, NULL);
  if (sampler_thread == NULL)
    fatal_error("Creating sampler thread failed", GetLastError());
}

void factor_vm::end_sampling_profiler_timer() {
  atomic::store(&sampling_profiler_p, false);
  // The sampler must finish its SuspendThread/GetThreadContext/ResumeThread
  // sequence. Forcibly terminating it can leave the VM thread suspended.
  if (WaitForSingleObject(sampler_thread, INFINITE) != WAIT_OBJECT_0)
    fatal_error("Waiting for sampler thread failed", GetLastError());
  CloseHandle(sampler_thread);
  sampler_thread = NULL;
}

void abort() { ::abort(); }

}
