namespace factor {

// Safe IO functions that does not throw Factor errors.
int raw_fclose(FILE* stream);
size_t raw_fread(void* ptr, size_t size, size_t nitems, FILE* stream);

// Platform specific primitives

VM_C_API int err_no();
VM_C_API void set_err_no(int err);

}
