#include "../windows_file_copy.hpp"
#undef NDEBUG
#include <cassert>
#include <vector>

static DWORD await_copy(factor_file_copy* copy, HANDLE port, ULONG_PTR expected) {
  assert(copy);
  DWORD bytes;
  ULONG_PTR key;
  OVERLAPPED* overlapped;
  assert(GetQueuedCompletionStatus(port, &bytes, &key, &overlapped, 5000));
  assert(key == expected && bytes == 0 && overlapped == NULL);
  return finish_file_copy(copy);
}

int main() {
  HANDLE port = CreateIoCompletionPort(INVALID_HANDLE_VALUE, NULL, 0, 1);
  assert(port);
  wchar_t directory[MAX_PATH], source[MAX_PATH], destination[MAX_PATH];
  assert(GetTempPathW(MAX_PATH, directory));
  assert(GetTempFileNameW(directory, L"fio", 0, source));
  assert(GetTempFileNameW(directory, L"fio", 0, destination));
  HANDLE file = CreateFileW(source, GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);
  assert(file != INVALID_HANDLE_VALUE);
  std::vector<char> data(1024 * 1024, 0x5a);
  DWORD written;
  assert(WriteFile(file, data.data(), static_cast<DWORD>(data.size()),
                   &written, NULL));
  assert(written == data.size() && CloseHandle(file));

  // The worker must own path strings independently of the caller.
  std::wstring temporary_source(source), temporary_destination(destination);
  factor_file_copy* copy =
      begin_file_copy(temporary_source.c_str(), temporary_destination.c_str(),
                      port, 1);
  temporary_source.assign(L"no longer the source");
  temporary_destination.assign(L"no longer the destination");
  assert(await_copy(copy, port, 1) == ERROR_SUCCESS);
  file = CreateFileW(destination, GENERIC_READ, 0, NULL, OPEN_EXISTING, 0, NULL);
  assert(file != INVALID_HANDLE_VALUE);
  std::vector<char> actual(data.size());
  DWORD read;
  assert(ReadFile(file, actual.data(), static_cast<DWORD>(actual.size()),
                  &read, NULL));
  assert(read == data.size() && actual == data && CloseHandle(file));

  assert(SetFileAttributesW(destination, FILE_ATTRIBUTE_READONLY));
  assert(await_copy(begin_file_copy(source, destination, port, 2), port, 2)
         == ERROR_ACCESS_DENIED);
  assert(SetFileAttributesW(destination, FILE_ATTRIBUTE_NORMAL));
  assert(DeleteFileW(source));
  assert(await_copy(begin_file_copy(source, destination, port, 3), port, 3)
         == ERROR_FILE_NOT_FOUND);
  assert(DeleteFileW(destination) && CloseHandle(port));
}
