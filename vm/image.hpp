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
  // size of heap
  cell data_size;
  // base address of code heap when image was saved
  cell code_relocation_base;
  // size of code heap
  cell code_size;

  cell reserved_1;
  cell reserved_2;
  cell reserved_3;
  cell reserved_4;

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
