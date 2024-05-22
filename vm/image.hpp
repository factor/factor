namespace factor {

static const cell image_magic = 0x0f0e0d0c;
static const cell image_version = 4;

const size_t STRERROR_BUFFER_SIZE = 1024;

struct embedded_image_footer {
  cell magic;
  cell image_offset;
};

struct image_header {
  cell magic;
  cell version;
  // base address of data heap when image was saved
  cell data_relocation_base;
  // <>0 : size of data heap, ==0 : version4_escape
  union { cell data_size; cell version4_escape; };
  // base address of code heap when image was saved
  cell code_relocation_base;
  // size of code heap
  cell code_size;
  union { cell reserved_1; cell escaped_data_size; }; // undefined if data_size <>0, stores size of data heap otherwise
  union { cell reserved_2; cell compressed_data_size; }; // undefined if data_size <>0, compressed data heap size if smaller than data heap size
  union { cell reserved_3; cell compressed_code_size; }; // undefined if data_size <>0, compressed code heap size if smaller than code heap size
  cell reserved_4; // undefined if data_size <>0, 0 otherwise
  // Initial user environment
  cell special_objects[special_object_count];
};

struct vm_parameters {
  bool embedded_image;
  const vm_char* image_path;
  const vm_char* executable_path;
  cell datastack_size, retainstack_size, callstack_size;
  cell young_size, aging_size, tenured_size;
  cell code_size;
  bool fep;
  bool console;
  bool signals;
  cell max_pic_size;
  cell callback_size;

  vm_parameters();
  ~vm_parameters();
  void init_from_args(int argc, vm_char** argv);
};

}
