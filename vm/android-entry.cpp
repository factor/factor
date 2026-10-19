#include "master.hpp"
#include <string>

static void factor_android_environment(const char* data_path) {
  std::string cache = std::string(data_path) + "/cache";
  if (mkdir(cache.c_str(), 0700) == -1 && errno != EEXIST)
    factor::fatal_error("Cannot create Android cache directory", errno);
  if (setenv("HOME", data_path, 1) == -1 ||
      setenv("TMPDIR", cache.c_str(), 1) == -1 ||
      setenv("XDG_CACHE_HOME", cache.c_str(), 1) == -1)
    factor::fatal_error("Cannot set Android runtime environment", errno);
}

extern "C" __attribute__((visibility("default")))
void factor_android_start_run(const char* data_path, const char* run) {
  if (!data_path || !*data_path)
    factor::fatal_error("Android data path is empty", 0);

  std::string image = std::string("-i=") + data_path + "/factor.image";
  std::string resource = std::string("-resource-path=") + data_path + "/factor";
  std::string run_option = run && *run ? std::string("-run=") + run : std::string();
  char program[] = "factor";
  char* argv[] = {program, image.data(), resource.data(),
                  run_option.empty() ? nullptr : run_option.data(), nullptr};
  int argc = run_option.empty() ? 3 : 4;

  factor_android_environment(data_path);
  factor::jit_set_writable();
  factor::init_mvm();
  factor::set_android_embedded_runtime();
  factor::start_standalone_factor(argc, argv);
}

extern "C" __attribute__((visibility("default")))
void factor_android_set_executable_path(const char* path) {
  factor::set_android_executable_path(path);
}

extern "C" __attribute__((visibility("default")))
void factor_android_start(const char* data_path) {
  factor_android_start_run(data_path, nullptr);
}
