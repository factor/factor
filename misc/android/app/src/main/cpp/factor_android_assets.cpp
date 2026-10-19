#include "factor_android_assets.h"

#include <algorithm>
#include <array>
#include <cerrno>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <fcntl.h>
#include <memory>
#include <sys/stat.h>
#include <unistd.h>

namespace factor_android {
namespace {

using asset_handle = std::unique_ptr<AAsset, decltype(&AAsset_close)>;

// POSIX ustar header fields, in bytes.
constexpr size_t tar_block_size = 512;
constexpr size_t tar_name_size = 100;
constexpr size_t tar_size_offset = 124;
constexpr size_t tar_size_length = 12;
constexpr size_t tar_type_offset = 156;
constexpr size_t tar_prefix_offset = 345;
constexpr size_t tar_prefix_size = 155;

bool read_exact(AAsset* input, char* data, size_t size) {
  while (size) {
    const int count = AAsset_read(input, data, size);
    if (count <= 0) return false;
    data += count;
    size -= static_cast<size_t>(count);
  }
  return true;
}

bool write_all(int output, const char* data, size_t size) {
  while (size) {
    const ssize_t count = write(output, data, size);
    if (count < 0 && errno == EINTR) continue;
    if (count <= 0) return false;
    data += count;
    size -= static_cast<size_t>(count);
  }
  return true;
}

bool copy_file(AAsset* input, const std::string& path, uint64_t size) {
  const int output = open(path.c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0600);
  if (output < 0) return false;
  std::array<char, 64 * 1024> buffer;
  bool copied = true;
  while (size && copied) {
    const size_t count = static_cast<size_t>(std::min<uint64_t>(size, buffer.size()));
    copied = read_exact(input, buffer.data(), count) &&
             write_all(output, buffer.data(), count);
    size -= count;
  }
  if (close(output) != 0) copied = false;
  if (!copied) unlink(path.c_str());
  return copied;
}

bool make_directory(const std::string& path) {
  if (mkdir(path.c_str(), 0700) == 0) return true;
  if (errno != EEXIST) return false;
  struct stat info;
  return stat(path.c_str(), &info) == 0 && S_ISDIR(info.st_mode);
}

bool make_parent_directories(const std::string& path) {
  for (size_t slash = 1; (slash = path.find('/', slash)) != std::string::npos; ++slash) {
    if (!make_directory(path.substr(0, slash))) return false;
  }
  return true;
}

bool skip_bytes(AAsset* input, uint64_t size) {
  const off64_t remaining = AAsset_getRemainingLength64(input);
  if (remaining < 0 || size > static_cast<uint64_t>(remaining)) return false;
  return !size || AAsset_seek64(input, static_cast<off64_t>(size), SEEK_CUR) >= 0;
}

uint64_t tar_octal(const char* value, size_t size) {
  std::array<char, 32> text{};
  memcpy(text.data(), value, std::min(size, text.size() - 1));
  return strtoull(text.data(), nullptr, 8);
}

bool valid_asset_path(const std::string& path) {
  return !path.empty() && path.front() != '/' && path != ".." &&
         path.find("../") == std::string::npos &&
         path.find("/..") == std::string::npos;
}

}  // namespace

bool copy_asset(AAssetManager* manager, const std::string& asset,
                const std::string& destination) {
  asset_handle input(AAssetManager_open(manager, asset.c_str(), AASSET_MODE_STREAMING),
                     AAsset_close);
  if (!input) return false;
  const off64_t size = AAsset_getLength64(input.get());
  return size >= 0 && copy_file(input.get(), destination, static_cast<uint64_t>(size));
}

bool extract_resources(AAssetManager* manager, const std::string& destination) {
  asset_handle archive(AAssetManager_open(manager, "factor-resources.tar",
                                         AASSET_MODE_STREAMING), AAsset_close);
  if (!archive) return false;
  std::array<char, tar_block_size> header{};
  for (;;) {
    if (!read_exact(archive.get(), header.data(), header.size())) return false;
    if (header[0] == '\0') return true;
    std::string name(header.data(), strnlen(header.data(), tar_name_size));
    const size_t prefix_length =
        strnlen(header.data() + tar_prefix_offset, tar_prefix_size);
    if (prefix_length)
      name = std::string(header.data() + tar_prefix_offset, prefix_length) + "/" + name;
    const uint64_t size = tar_octal(header.data() + tar_size_offset, tar_size_length);
    const std::string path = destination + "/" + name;
    if (!valid_asset_path(name)) return false;
    if (header[tar_type_offset] == '5') {
      if (!make_parent_directories(path) || !make_directory(path)) return false;
      if (!skip_bytes(archive.get(), size)) return false;
    } else if (header[tar_type_offset] == '0' || header[tar_type_offset] == '\0') {
      if (!make_parent_directories(path) || !copy_file(archive.get(), path, size))
        return false;
    } else {
      if (!skip_bytes(archive.get(), size)) return false;
    }
    const uint64_t padding =
        (tar_block_size - size % tar_block_size) % tar_block_size;
    if (!skip_bytes(archive.get(), padding)) return false;
  }
}

}  // namespace factor_android
