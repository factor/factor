#include "../master.hpp"

static bool mock_transfer = false;
static bool mock_error = false;
static bool fail_transfer = false;
static size_t transfer_count = 0;
static const char payload[] = "abcdefgh";
static char mock_written[8];

static size_t test_fread(void* ptr, size_t size, size_t count, FILE* file) {
  if (!mock_transfer)
    return fread(ptr, size, count, file);
  if (transfer_count++ == 1) {
    mock_error = true;
    errno = EINTR;
    return 0;
  }
  size_t done = transfer_count == 1 ? 3 : count;
  memcpy(ptr, payload + (transfer_count == 1 ? 0 : 3), done * size);
  return done;
}

static size_t test_fwrite(const void* ptr, size_t size, size_t count, FILE* file) {
  if (!mock_transfer)
    return fwrite(ptr, size, count, file);
  if (fail_transfer || transfer_count++ == 1) {
    mock_error = true;
    errno = fail_transfer ? EIO : EINTR;
    return 0;
  }
  size_t done = transfer_count == 1 ? 3 : count;
  memcpy(mock_written + (transfer_count == 1 ? 0 : 3), ptr, done * size);
  return done;
}

static int test_ferror(FILE* file) {
  return mock_transfer ? mock_error : ferror(file);
}

static void test_clearerr(FILE* file) {
  if (mock_transfer)
    mock_error = false;
  else
    clearerr(file);
}

// Compile the production wrappers with deterministic partial stdio transfers.
// Link this test without vm/io.obj to avoid duplicate definitions.
#define fread test_fread
#define fwrite test_fwrite
#define ferror test_ferror
#define clearerr test_clearerr
#include "../io.cpp"
#undef fread
#undef fwrite
#undef ferror
#undef clearerr

static void require(bool condition, const char* message) {
  if (!condition) {
    fprintf(stderr, "%s (errno %d)\n", message, errno);
    exit(1);
  }
}

int main() {
  using namespace factor;
  static_assert(sizeof(file_offset) == 8, "Windows file offsets must be 64-bit");
  // These operations do not initialize or use Factor heaps. Keep the VM alive
  // until process exit, since its destructor expects initialized special objects.
  factor_vm* vm = new factor_vm(GetCurrentThread());
  FILE* file = tmpfile();
  require(file != NULL, "Cannot create temporary file");

  mock_transfer = true;
  char received[32] = {};
  require(raw_fread(received, 1, 8, file) == 8, "Short read did not retry");
  require(memcmp(received, payload, 8) == 0, "Read retry used wrong address");
  require(!mock_error, "Interrupted read did not clear stream error");
  transfer_count = 0;
  // Padding keeps the old incorrect pointer arithmetic inside the allocation.
  char outgoing[32] = "abcdefgh";
  require(vm->safe_fwrite(outgoing, 1, 8, file) == 8, "Short write did not retry");
  require(memcmp(mock_written, payload, 8) == 0, "Write retry used wrong address");
  require(!mock_error, "Interrupted write did not clear stream error");
  fail_transfer = true;
  require(raw_fwrite(outgoing, 1, 8, file) == 0 && errno == EIO,
          "Raw write did not report error without a Factor exception");
  mock_transfer = false;

  const file_offset large_offset = (file_offset(1) << 32) + 123;
  vm->safe_fseek(file, large_offset, SEEK_SET);
  require(vm->safe_ftell(file) == large_offset, "Large file offset was truncated");
  vm->safe_fseek(file, -23, SEEK_CUR);
  require(vm->safe_ftell(file) == large_offset - 23, "Relative seek failed");
  // Seeking alone does not extend the file or allocate several gigabytes.
  vm->safe_fseek(file, 0, SEEK_SET);

  embedded_image_footer footer = {image_magic, 0};
  require(!vm->read_embedded_image_footer(file, &footer),
          "Empty file was accepted as an embedded image");
  vm->safe_fseek(file, 0, SEEK_SET);
  require(fwrite(&footer.magic, sizeof(footer.magic), 1, file) == 1,
          "Cannot write short footer");
  require(!vm->read_embedded_image_footer(file, &footer),
          "Short file was accepted as an embedded image");

  vm->safe_fseek(file, 0, SEEK_SET);
  footer.magic = image_magic;
  footer.image_offset = 123;
  require(fwrite(&footer, sizeof(footer), 1, file) == 1,
          "Cannot write footer");
  embedded_image_footer actual = {};
  require(vm->read_embedded_image_footer(file, &actual), "Valid footer rejected");
  require(actual.image_offset == 123, "Footer offset changed");
  require(fclose(file) == 0, "Cannot close temporary file");
  puts("Windows VM I/O tests passed");
  return 0;
}
