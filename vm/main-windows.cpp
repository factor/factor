#include "master.hpp"

VM_C_API int wmain(int argc, wchar_t** argv) {
  HANDLE proc = GetCurrentProcess();
  HANDLE thread = GetCurrentThread();
  BOOL res = DuplicateHandle(proc, thread, proc,
                             &factor::boot_thread, GENERIC_ALL, FALSE, 0);
  if (!res) {
    factor::fatal_error("DuplicateHandle() failed", GetLastError());
  }
  factor::init_mvm();
  factor::start_standalone_factor(argc, argv);
  return 0;
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
                   LPSTR lpCmdLine, int nCmdShow) {
  (void)hInstance;
  (void)hPrevInstance;
  (void)lpCmdLine;
  (void)nCmdShow;
  int argc;
  wchar_t** argv = CommandLineToArgvW(GetCommandLineW(), &argc);
  if (argv == NULL)
    factor::fatal_error("CommandLineToArgvW() failed", GetLastError());
  int result = wmain(argc, argv);
  LocalFree(argv);
  return result;
}
