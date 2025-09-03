namespace factor {

// Safe IO functions that does not throw Factor errors.
int raw_fclose(FILE* stream);
size_t raw_fread(void* ptr, size_t size, size_t nitems, FILE* stream);

// RAII wrapper for FILE* for internal helpers. Does not change external ABI.
struct file_closer {
  void operator()(FILE* f) const noexcept {
    if (f) raw_fclose(f);
  }
};

using unique_file = std::unique_ptr<FILE, file_closer>;

inline unique_file make_unique_file(FILE* f) { return unique_file(f); }

// Platform specific primitives

VM_C_API int err_no();
VM_C_API void set_err_no(int err);

}
