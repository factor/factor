#include "../master.hpp"

static void check(bool condition, const char* message) {
  if (!condition) {
    std::cerr << message << std::endl;
    ::exit(1);
  }
}

int main() {
  // The compressed-image loader passes a narrow DLL name through this API.
  void* library = factor::native_dlopen("kernel32.dll");
  check(library != NULL, "native_dlopen failed to load a narrow DLL name");
  check(factor::native_dlsym(library, "GetCurrentProcessId") != NULL,
        "native_dlsym failed to resolve an export");
  factor::native_dlclose(library);
  std::cout << "Windows service tests passed" << std::endl;
}
