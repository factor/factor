#include "master.hpp"

namespace factor {

HMODULE hFactorDll;

void factor_vm::init_ffi() {
  hFactorDll = GetModuleHandle(NULL);
  if (!hFactorDll)
    fatal_error("GetModuleHandle() failed", 0);
}

void factor_vm::ffi_dlopen(dll* dll) {
  dll->handle = LoadLibraryEx((WCHAR*)alien_offset(dll->path), NULL, 0);
}

void* factor_vm::ffi_dlsym(dll* dll, symbol_char* symbol) {
  return (void*)GetProcAddress(dll ? (HMODULE) dll->handle : hFactorDll,
                               symbol);
}

void* factor_vm::ffi_dlsym_raw(dll* dll, symbol_char* symbol) {
  return ffi_dlsym(dll, symbol);
}

void factor_vm::ffi_dlclose(dll* dll) {
  FreeLibrary((HMODULE) dll->handle);
  dll->handle = NULL;
}

BOOL factor_vm::windows_stat(vm_char* path) {
  BY_HANDLE_FILE_INFORMATION bhfi;
  HANDLE h = CreateFileW(path, GENERIC_READ, FILE_SHARE_READ, NULL,
                         OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, NULL);

  if (h == INVALID_HANDLE_VALUE) {
    // FindFirstFile is the only call that can stat c:\pagefile.sys
    WIN32_FIND_DATA st;
    HANDLE h;

    if (INVALID_HANDLE_VALUE == (h = FindFirstFile(path, &st)))
      return false;
    FindClose(h);
    return true;
  }
  BOOL ret = GetFileInformationByHandle(h, &bhfi);
  CloseHandle(h);
  return ret;
}

void factor_vm::windows_image_path(vm_char* full_path, vm_char* temp_path,
                                   unsigned int length) {
  wcsncpy(temp_path, full_path, length - 1);
  size_t full_path_len = wcslen(full_path);
  if (full_path_len < length - 1)
    wcsncat(temp_path, L".image", length - full_path_len - 1);
  temp_path[length - 1] = 0;
}

/* You must free() this yourself. */
const vm_char* factor_vm::default_image_path() {
  vm_char full_path[MAX_UNICODE_PATH];
  vm_char* ptr;
  vm_char temp_path[MAX_UNICODE_PATH];

  if (!GetModuleFileName(NULL, full_path, MAX_UNICODE_PATH))
    fatal_error("GetModuleFileName() failed", 0);

  if ((ptr = wcsrchr(full_path, '.')))
    *ptr = 0;

  wcsncpy(temp_path, full_path, MAX_UNICODE_PATH - 1);
  size_t full_path_len = wcslen(full_path);
  if (full_path_len < MAX_UNICODE_PATH - 1)
    wcsncat(temp_path, L".image", MAX_UNICODE_PATH - full_path_len - 1);
  temp_path[MAX_UNICODE_PATH - 1] = 0;

  return safe_strdup(temp_path);
}

/* You must free() this yourself. */
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

segment::segment(cell size_, bool executable_p) {
  size = size_;

  char* mem;
  DWORD ignore;

  if ((mem = (char*)VirtualAlloc(
           NULL, getpagesize() * 2 + size, MEM_COMMIT,
           executable_p ? PAGE_EXECUTE_READWRITE : PAGE_READWRITE)) ==
      0)
    out_of_memory();

  if (!VirtualProtect(mem, getpagesize(), PAGE_NOACCESS, &ignore))
    fatal_error("Cannot allocate low guard page", (cell)mem);

  if (!VirtualProtect(mem + size + getpagesize(), getpagesize(), PAGE_NOACCESS,
                      &ignore))
    fatal_error("Cannot allocate high guard page", (cell)mem);

  start = (cell)mem + getpagesize();
  end = start + size;
}

segment::~segment() {
  SYSTEM_INFO si;
  GetSystemInfo(&si);
  if (!VirtualFree((void*)(start - si.dwPageSize), 0, MEM_RELEASE))
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

void code_heap::guard_safepoint() {
  DWORD ignore;
  if (!VirtualProtect(safepoint_page, getpagesize(), PAGE_NOACCESS, &ignore))
    fatal_error("Cannot protect safepoint guard page", (cell)safepoint_page);
}

void code_heap::unguard_safepoint() {
  DWORD ignore;
  if (!VirtualProtect(safepoint_page, getpagesize(), PAGE_READWRITE, &ignore))
    fatal_error("Cannot unprotect safepoint guard page", (cell)safepoint_page);
}

void factor_vm::move_file(const vm_char* path1, const vm_char* path2) {
  if (MoveFileEx((path1), (path2), MOVEFILE_REPLACE_EXISTING) == false)
    general_error(ERROR_IO, tag_fixnum(GetLastError()), false_object);
}

void factor_vm::init_signals() {}

THREADHANDLE start_thread(void* (*start_routine)(void*), void* args) {
  return (void*)CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE) start_routine,
                             args, 0, 0);
}

uint64_t nano_count() {
  static double scale_factor;

  static uint32_t hi = 0;
  static uint32_t lo = 0;

  LARGE_INTEGER count;
  BOOL ret = QueryPerformanceCounter(&count);
  if (ret == 0)
    fatal_error("QueryPerformanceCounter", 0);

  if (scale_factor == 0.0) {
    LARGE_INTEGER frequency;
    BOOL ret = QueryPerformanceFrequency(&frequency);
    if (ret == 0)
      fatal_error("QueryPerformanceFrequency", 0);
    scale_factor = (1000000000.0 / frequency.QuadPart);
  }

#ifdef FACTOR_64
  hi = count.HighPart;
#else
  /* On VirtualBox, QueryPerformanceCounter does not increment
	the high part every time the low part overflows.  Workaround. */
  if (lo > count.LowPart)
    hi++;
#endif
  lo = count.LowPart;

  return (uint64_t)((((uint64_t)hi << 32) | (uint64_t)lo) * scale_factor);
}

void sleep_nanos(uint64_t nsec) { Sleep((DWORD)(nsec / 1000000)); }

typedef enum _EXCEPTION_DISPOSITION {
  ExceptionContinueExecution = 0,
  ExceptionContinueSearch = 1,
  ExceptionNestedException = 2,
  ExceptionCollidedUnwind = 3
} EXCEPTION_DISPOSITION;

LONG factor_vm::exception_handler(PEXCEPTION_RECORD e, void* frame, PCONTEXT c,
                                  void* dispatch) {
  switch (e->ExceptionCode) {
    case EXCEPTION_ACCESS_VIOLATION:
      signal_fault_addr = e->ExceptionInformation[1];
      verify_memory_protection_error(signal_fault_addr);
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
#ifdef FACTOR_64
      signal_fpu_status = fpu_status(MXCSR(c));
#else
      signal_fpu_status = fpu_status(X87SW(c) | MXCSR(c));

      /* This seems to have no effect */
      X87SW(c) = 0;
#endif
      MXCSR(c) &= 0xffffffc0;
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
  if (factor_vm::fatal_erroring_p)
    return ExceptionContinueSearch;

  factor_vm* vm = current_vm_p();
  if (vm)
    return vm->exception_handler(e, frame, c, dispatch);
  else
    return ExceptionContinueSearch;
}

static BOOL WINAPI ctrl_handler(DWORD dwCtrlType) {
  switch (dwCtrlType) {
    case CTRL_C_EVENT: {
      /* The CtrlHandler runs in its own thread without stopping the main
         thread. Since in practice nobody uses the multi-VM stuff yet, we just
         grab the first VM we can get. This will not be a good idea when we
         actually support native threads. */
      FACTOR_ASSERT(thread_vms.size() == 1);
      factor_vm* vm = thread_vms.begin()->second;
      vm->safepoint.enqueue_fep(vm);
      return TRUE;
    }
    default:
      return FALSE;
  }
}

void factor_vm::open_console() { handle_ctrl_c(); }

void factor_vm::ignore_ctrl_c() {
  SetConsoleCtrlHandler(factor::ctrl_handler, FALSE);
}

void factor_vm::handle_ctrl_c() {
  SetConsoleCtrlHandler(factor::ctrl_handler, TRUE);
}

void factor_vm::lock_console() {}

void factor_vm::unlock_console() {}

void factor_vm::close_console() {}

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
    cell samples = 0;
    while (new_counter.QuadPart - counter.QuadPart >
           units_per_second.QuadPart) {
      ++samples;
      counter.QuadPart += units_per_second.QuadPart;
    }

    if (samples > 0) {
      DWORD suscount = SuspendThread(thread);
      FACTOR_ASSERT(suscount == 0);

      CONTEXT context;
      memset((void*)&context, 0, sizeof(CONTEXT));
      context.ContextFlags = CONTEXT_CONTROL;
      BOOL context_ok = GetThreadContext(thread, &context);
      FACTOR_ASSERT(context_ok);

      suscount = ResumeThread(thread);
      FACTOR_ASSERT(suscount == 1);

      safepoint.enqueue_samples(this, samples, context.EIP, false);
    }
  }
}

static DWORD WINAPI sampler_thread_entry(LPVOID parent_vm) {
  static_cast<factor_vm*>(parent_vm)->sampler_thread_loop();
  return 0;
}

void factor_vm::start_sampling_profiler_timer() {
  sampler_thread = CreateThread(NULL, 0, &sampler_thread_entry,
                                static_cast<LPVOID>(this), 0, NULL);
}

void factor_vm::end_sampling_profiler_timer() {
  atomic::store(&sampling_profiler_p, false);
  DWORD wait_result =
      WaitForSingleObject(sampler_thread, 3000 * (DWORD) samples_per_second);
  if (wait_result != WAIT_OBJECT_0)
    TerminateThread(sampler_thread, 0);
  sampler_thread = NULL;
}

void abort() { ::abort(); }

}
