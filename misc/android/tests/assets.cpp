#include "factor_android_assets.h"

#include <algorithm>
#include <array>
#include <cassert>
#include <cerrno>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <limits>
#include <map>
#include <unistd.h>

namespace fs = std::filesystem;
constexpr size_t unlimited = std::numeric_limits<size_t>::max();

struct AAssetManager {
  std::map<std::string, std::string> files;
  size_t read_limit = unlimited;
  size_t read_error_at = unlimited;
  int active = 0;
};

struct AAsset {
  AAssetManager* manager;
  const std::string* bytes;
  size_t position = 0;
};

AAsset* AAssetManager_open(AAssetManager* manager, const char* name, int) {
  auto found = manager->files.find(name);
  if (found == manager->files.end()) return nullptr;
  ++manager->active;
  return new AAsset{manager, &found->second};
}

int AAsset_read(AAsset* asset, void* data, size_t size) {
  if (asset->position >= asset->manager->read_error_at) return -1;
  const size_t count = std::min({size, asset->manager->read_limit,
      asset->bytes->size() - asset->position,
      asset->manager->read_error_at - asset->position});
  memcpy(data, asset->bytes->data() + asset->position, count);
  asset->position += count;
  return static_cast<int>(count);
}

off64_t AAsset_getLength64(AAsset* asset) { return asset->bytes->size(); }
off64_t AAsset_getRemainingLength64(AAsset* asset) {
  return asset->bytes->size() - asset->position;
}
off64_t AAsset_seek64(AAsset* asset, off64_t offset, int origin) {
  assert(origin == SEEK_CUR && offset >= 0);
  asset->position += static_cast<size_t>(offset);
  assert(asset->position <= asset->bytes->size());
  return asset->position;
}
void AAsset_close(AAsset* asset) {
  --asset->manager->active;
  delete asset;
}

// Linker wrappers exercise real file writes while injecting kernel failures.
size_t write_limit = unlimited;
size_t write_error_after = unlimited;
bool interrupt_write = false;
bool fail_close = false;

extern "C" ssize_t __real_write(int, const void*, size_t);
extern "C" int __real_close(int);

extern "C" ssize_t __wrap_write(int fd, const void* data, size_t size) {
  if (interrupt_write) {
    interrupt_write = false;
    errno = EINTR;
    return -1;
  }
  if (!write_error_after) {
    errno = ENOSPC;
    return -1;
  }
  const ssize_t count = __real_write(fd, data,
      std::min({size, write_limit, write_error_after}));
  if (count > 0) write_error_after -= static_cast<size_t>(count);
  return count;
}

extern "C" int __wrap_close(int fd) {
  const int result = __real_close(fd);
  if (!fail_close) return result;
  fail_close = false;
  errno = EIO;
  return -1;
}

std::string entry(const char* name, char type, const std::string& body = "",
                  const char* prefix = "") {
  std::array<char, 512> header{};
  memcpy(header.data(), name, strlen(name));
  snprintf(header.data() + 124, 12, "%011llo",
           static_cast<unsigned long long>(body.size()));
  header[156] = type;
  memcpy(header.data() + 345, prefix, strlen(prefix));
  return std::string(header.data(), header.size()) + body +
         std::string((512 - body.size() % 512) % 512, '\0');
}

std::string contents(const fs::path& path) {
  std::ifstream input(path, std::ios::binary);
  return {std::istreambuf_iterator<char>(input), {}};
}

int main() {
  char temporary[] = "/tmp/factor-android-assets-XXXXXX";
  const char* directory = mkdtemp(temporary);
  assert(directory);
  const fs::path root(directory);
  std::string payload(150000, '\0');  // More than two buffers, with binary data.
  for (size_t i = 0; i < payload.size(); ++i) payload[i] = static_cast<char>(i % 251);
  const std::string end(1024, '\0');
  AAssetManager manager;
  manager.files["image"] = payload;
  manager.files["factor-resources.tar"] =
      entry("basis/", '5') + entry("test.factor", '0', payload, "basis") +
      entry("ignored", '2', "symlink metadata") + entry("empty", '0') + end;

  // Headers, file bodies and writes may all arrive in small pieces.
  manager.read_limit = 7;
  write_limit = 11;
  interrupt_write = true;
  assert(factor_android::copy_asset(&manager, "image", root / "image"));
  assert(contents(root / "image") == payload);
  assert(factor_android::extract_resources(&manager, root / "resources"));
  assert(contents(root / "resources/basis/test.factor") == payload);
  assert(fs::file_size(root / "resources/empty") == 0);
  assert(!fs::exists(root / "resources/ignored"));
  assert(manager.active == 0);
  manager.read_limit = unlimited;
  write_limit = unlimited;

  // No missing asset, failed write, or failed close is reported as success.
  assert(!factor_android::copy_asset(&manager, "missing", root / "missing"));
  write_error_after = 17;
  assert(!factor_android::copy_asset(&manager, "image", root / "write-error"));
  assert(!fs::exists(root / "write-error"));
  write_error_after = 17;
  assert(!factor_android::extract_resources(&manager, root / "write-error-resources"));
  assert(!fs::exists(root / "write-error-resources/basis/test.factor"));
  write_error_after = unlimited;
  fail_close = true;
  assert(!factor_android::copy_asset(&manager, "image", root / "close-error"));
  assert(!fs::exists(root / "close-error"));
  manager.read_error_at = 70000;
  assert(!factor_android::copy_asset(&manager, "image", root / "read-error"));
  assert(!fs::exists(root / "read-error"));
  manager.read_error_at = unlimited;
  assert(manager.active == 0);

  // Truncated headers, payloads, padding and skipped entries must fail.
  for (size_t length : {size_t(100), size_t(512 + 100), size_t(512) + payload.size()}) {
    manager.files["factor-resources.tar"] = entry("file", '0', payload).substr(0, length);
    assert(!factor_android::extract_resources(&manager, root / "truncated"));
    if (length < 512 + payload.size()) assert(!fs::exists(root / "truncated/file"));
  }
  assert(contents(root / "truncated/file") == payload);
  manager.files["factor-resources.tar"] = entry("ignored", '2', payload).substr(0, 600);
  assert(!factor_android::extract_resources(&manager, root / "skipped"));

  // Unsafe paths and files in place of directories cannot escape preparation.
  for (const char* path : {"../escape", "/absolute", "basis/../../escape"}) {
    manager.files["factor-resources.tar"] = entry(path, '0', payload) + end;
    assert(!factor_android::extract_resources(&manager, root / "unsafe"));
  }
  manager.files["factor-resources.tar"] = entry("child", '0', payload) + end;
  assert(!factor_android::extract_resources(&manager, root / "image"));
  manager.files["factor-resources.tar"] = entry("image/", '5') + end;
  assert(!factor_android::extract_resources(&manager, root));
  assert(manager.active == 0);
  fs::remove_all(root);
  std::cout << "Android asset loader checks passed\n";
}
