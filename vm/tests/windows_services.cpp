#include "../master.hpp"

static void check(bool condition, const char* message) {
  if (!condition) {
    std::cerr << message << std::endl;
    ::exit(1);
  }
}

int main(int argc, char** argv) {
  if (argc > 1 && strcmp(argv[1], "fatal-before-init") == 0) {
    // Another library may own TLS slot zero before Factor initializes TLS.
    DWORD key = TlsAlloc();
    check(key != TLS_OUT_OF_INDEXES, "TlsAlloc failed");
    check(TlsSetValue(key, (void*)1) != 0, "TlsSetValue failed");
    factor::fatal_error("Before VM initialization", 0);
    return 2;
  }
  if (argc > 1 && strcmp(argv[1], "fatal-after-init") == 0) {
    factor::init_mvm();
    factor::fatal_error("Before VM registration", 0);
    return 2;
  }
  // The compressed-image loader passes a narrow DLL name through this API.
  void* library = factor::native_dlopen("kernel32.dll");
  check(library != NULL, "native_dlopen failed to load a narrow DLL name");
  check(factor::native_dlsym(library, "GetCurrentProcessId") != NULL,
        "native_dlsym failed to resolve an export");
  factor::native_dlclose(library);
  std::cout << "Windows service tests passed" << std::endl;
}
