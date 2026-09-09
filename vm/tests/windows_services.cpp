#include "../master.hpp"

static void check(bool condition, const char* message) {
  if (!condition) {
    std::cerr << message << std::endl;
    ::exit(1);
  }
}

int wmain(int argc, wchar_t** argv) {
  if (argc > 1 && wcscmp(argv[1], L"segment-overflow") == 0) {
    factor::cell page = factor::getpagesize();
    factor::segment segment(std::numeric_limits<factor::cell>::max() - page + 1,
                            false);
    return 2;
  }
  if (argc > 1 && wcscmp(argv[1], L"guard-overflow") == 0) {
    factor::segment segment(factor::getpagesize(), false,
                            std::numeric_limits<factor::cell>::max());
    return 2;
  }
  if (argc > 2 && wcscmp(argv[1], L"image-path") == 0) {
    factor::factor_vm* vm = new factor::factor_vm(NULL);
    const wchar_t* path = vm->default_image_path();
    check(wcscmp(path, argv[2]) == 0, "Default image path changed its directory");
    free((void*)path);
    return 0;
  }
  if (argc > 1 && wcscmp(argv[1], L"fatal-before-init") == 0) {
    // Another library may own TLS slot zero before Factor initializes TLS.
    DWORD key = TlsAlloc();
    check(key != TLS_OUT_OF_INDEXES, "TlsAlloc failed");
    check(TlsSetValue(key, (void*)1) != 0, "TlsSetValue failed");
    factor::fatal_error("Before VM initialization", 0);
    return 2;
  }
  if (argc > 1 && wcscmp(argv[1], L"fatal-after-init") == 0) {
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
  factor::segment segment(factor::getpagesize(), false);
  MEMORY_BASIC_INFORMATION info;
  check(VirtualQuery((void*)segment.start, &info, sizeof(info)) == sizeof(info) &&
        info.Protect == PAGE_READWRITE, "Segment data is not writable");
  check(VirtualQuery((void*)(segment.start - 1), &info, sizeof(info)) == sizeof(info) &&
        info.Protect == PAGE_NOACCESS, "Segment low guard is not protected");
  check(VirtualQuery((void*)segment.end, &info, sizeof(info)) == sizeof(info) &&
        info.Protect == PAGE_NOACCESS, "Segment high guard is not protected");
  std::cout << "Windows service tests passed" << std::endl;
}
