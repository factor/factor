namespace factor
{

size_t safe_fread(void *ptr, size_t size, size_t nitems, FILE *stream);
size_t safe_fwrite(void *ptr, size_t size, size_t nitems, FILE *stream);
int safe_fclose(FILE *stream);

/* Platform specific primitives */

VM_C_API int err_no();
VM_C_API void clear_err_no();

}
