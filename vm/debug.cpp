#include "master.hpp"

using namespace std;

namespace factor {

bool factor_print_p = true;

ostream& operator<<(ostream& out, const string* str) {
  for (cell i = 0; i < string_capacity(str); i++)
    out << (char)str->data()[i];
  return out;
}

void factor_vm::print_word(ostream& out, word* word, cell nesting) {
  if (TAG(word->vocabulary) == STRING_TYPE)
    out << untag<string>(word->vocabulary) << ":";

  if (TAG(word->name) == STRING_TYPE)
    out << untag<string>(word->name);
  else {
    out << "#<not a string: ";
    print_nested_obj(out, word->name, nesting);
    out << ">";
  }
}

void factor_vm::print_factor_string(ostream& out, string* str) {
  out << '"' << str << '"';
}

void factor_vm::print_array(ostream& out, array* array, cell nesting) {
  cell length = array_capacity(array);
  cell i;
  bool trimmed;

  if (length > 10 && !full_output) {
    trimmed = true;
    length = 10;
  } else
    trimmed = false;

  for (i = 0; i < length; i++) {
    out << " ";
    print_nested_obj(out, array_nth(array, i), nesting);
  }

  if (trimmed)
    out << "...";
}

void factor_vm::print_alien(ostream& out, alien* alien, cell nesting) {
  if (to_boolean(alien->expired))
    out << "#<expired alien>";
  else if (to_boolean(alien->base)) {
    out << "#<displaced alien " << alien->displacement << "+";
    print_nested_obj(out, alien->base, nesting);
    out << ">";
  } else {
    out << "#<alien " << (void*)alien->address << ">";
  }
}

void factor_vm::print_byte_array(ostream& out, byte_array* array, cell nesting) {
  (void)nesting;
  cell length = array->capacity;
  cell i;
  bool trimmed;
  unsigned char* bytes = array->data<unsigned char>();

  if (length > 16 && !full_output) {
    trimmed = true;
    length = 16;
  } else
    trimmed = false;

  for (i = 0; i < length; i++) {
    out << " " << static_cast<unsigned>(bytes[i]);
  }

  if (trimmed)
    out << "...";
}

void factor_vm::print_tuple(ostream& out, tuple* tuple, cell nesting) {
  tuple_layout* layout = untag<tuple_layout>(tuple->layout);
  cell length = to_cell(layout->size);

  out << " ";
  print_nested_obj(out, layout->klass, nesting);

  bool trimmed;
  if (length > 10 && !full_output) {
    trimmed = true;
    length = 10;
  } else
    trimmed = false;

  for (cell i = 0; i < length; i++) {
    out << " ";
    print_nested_obj(out, tuple->data()[i], nesting);
  }

  if (trimmed)
    out << "...";
}

void factor_vm::print_nested_obj(ostream& out, cell obj, fixnum nesting) {
  if (nesting <= 0 && !full_output) {
    out << " ... ";
    return;
  }

  quotation* quot;

  switch (TAG(obj)) {
    case FIXNUM_TYPE:
      out << untag_fixnum(obj);
      break;
    case FLOAT_TYPE:
      out << untag_float(obj);
      break;
    case WORD_TYPE:
      print_word(out, untag<word>(obj), nesting - 1);
      break;
    case STRING_TYPE:
      print_factor_string(out, untag<string>(obj));
      break;
    case F_TYPE:
      out << "f";
      break;
    case TUPLE_TYPE:
      out << "T{";
      print_tuple(out, untag<tuple>(obj), nesting - 1);
      out << " }";
      break;
    case WRAPPER_TYPE:
      out << "W{ ";
      print_nested_obj(out, untag<wrapper>(obj)->object, nesting - 1);
      out << " }";
      break;
    case BYTE_ARRAY_TYPE:
      out << "B{";
      print_byte_array(out, untag<byte_array>(obj), nesting - 1);
      out << " }";
      break;
    case ARRAY_TYPE:
      out << "{";
      print_array(out, untag<array>(obj), nesting - 1);
      out << " }";
      break;
    case QUOTATION_TYPE:
      out << "[";
      quot = untag<quotation>(obj);
      print_array(out, untag<array>(quot->array), nesting - 1);
      out << " ]";
      break;
    case ALIEN_TYPE:
      print_alien(out, untag<alien>(obj), nesting - 1);
      break;
    default:
      out << "#<" << type_name(TAG(obj)) << " @ ";
      out << (void*)obj << ">";
      break;
  }
  out << flush;
}

void factor_vm::print_obj(ostream& out, cell obj) {
  print_nested_obj(out, obj, 10);
}

void factor_vm::print_objects(ostream& out, cell* start, cell* end) {
  for (; start <= end; start++) {
    print_obj(out, *start);
    cout << endl;
  }
}

void factor_vm::print_datastack(ostream& out) {
  out << "==== DATA STACK:" << endl;
  if (ctx)
    print_objects(out,
                  (cell*)ctx->datastack_seg->start,
                  (cell*)ctx->datastack);
  else
    out << "*** Context not initialized" << endl;
}

void factor_vm::print_retainstack(ostream& out) {
  out << "==== RETAIN STACK:" << endl;
  if (ctx)
    print_objects(out,
                  (cell*)ctx->retainstack_seg->start,
                  (cell*)ctx->retainstack);
  else
    out << "*** Context not initialized" << endl;
}

struct stack_frame_printer {
  factor_vm* parent;
  ostream& out;

  explicit stack_frame_printer(factor_vm* parent, ostream& out)
      : parent(parent), out(out) {}
  void operator()(cell frame_top, cell size, code_block* owner, cell addr) {
    out << endl;
    out << "frame: " << (void*)frame_top << " size " << size << endl;
    out << "executing: ";
    parent->print_obj(out, owner->owner);
    out << endl;
    out << "scan: ";
    parent->print_obj(out, owner->scan(parent, addr));
    out << endl;
    out << "word/quot addr: ";
    out << hex << owner->owner << dec;
    out << endl;
    out << "word/quot xt: ";
    out << hex << owner->entry_point() << dec;
    out << endl;
    out << "return address: ";
    out << hex << addr << dec;
    out << endl;
  }
};

void factor_vm::print_callstack(ostream& out) {
  out << "==== CALL STACK:" << endl;
  if (ctx) {
    stack_frame_printer printer(this, out);
    iterate_callstack(ctx, printer);
  } else
    out << "*** Context not initialized" << endl;
}

void factor_vm::print_callstack_object(ostream& out, callstack* obj) {
  stack_frame_printer printer(this, out);
  iterate_callstack_object(obj, printer);
}

struct padded_address {
  cell value;

  explicit padded_address(cell value) : value(value) {}
};

ostream& operator<<(ostream& out, const padded_address& value) {
  char prev = out.fill('0');
  out.width(sizeof(cell) * 2);
  out << hex << value.value << dec;
  out.fill(prev);
  return out;
}

void factor_vm::dump_cell(ostream& out, cell x) {
  out << padded_address(x) << ": ";
  x = *(cell*)x;
  out << padded_address(x) << " tag " << TAG(x) << endl;
}

void factor_vm::dump_memory(ostream& out, cell from, cell to) {
  from = UNTAG(from);

  for (; from <= to; from += sizeof(cell))
    dump_cell(out, from);
}

void dump_memory_range(ostream& out, const char* name, cell name_w,
                       cell start, cell end) {
  out << setw(static_cast<int>(name_w)) << left << name << ": ";

  out << "[" << (void*)start << " -> " << (void*)end << "] ";
  out << setw(10) << right << (end - start) << " bytes" << endl;
}

template <typename Generation>
void dump_generation(ostream& out, const char* name, Generation* gen) {
  dump_memory_range(out, name, 10, gen->start, gen->end);
}

void factor_vm::dump_memory_layout(ostream& out) {
  dump_generation(out, "Nursery", data->nursery);
  dump_generation(out, "Aging", data->aging);
  dump_generation(out, "Tenured", data->tenured);
  dump_memory_range(out, "Cards", 10, cell_from_ptr(data->cards), cell_from_ptr(data->cards_end));

  out << endl << "Contexts:" << endl << endl;
  FACTOR_FOR_EACH(active_contexts) {
    context* the_ctx = *iter;
    segment* ds = the_ctx->datastack_seg;
    segment* rs = the_ctx->retainstack_seg;
    segment* cs = the_ctx->callstack_seg;
    if (the_ctx == ctx) {
      out << "  Active:" << endl;
    }
    dump_memory_range(out, "  Datastack", 14, ds->start, ds->end);
    dump_memory_range(out, "  Retainstack", 14, rs->start, rs->end);
    dump_memory_range(out, "  Callstack", 14, cs->start, cs->end);
    out << endl;
  }
}

void factor_vm::dump_objects(ostream& out, cell type) {
  primitive_full_gc();
  auto object_dumper = [&](object* obj) {
    if (type == TYPE_COUNT || obj->type() == type) {
      out << padded_address(cell_from_ptr(obj)) << " ";
      print_nested_obj(out, tag_dynamic(obj), 2);
      out << endl;
    }
  };
  each_object(object_dumper);
}

void factor_vm::find_data_references(ostream& out, cell look_for) {
  primitive_full_gc();
  auto find_data_ref_func = [&](object* obj, cell* slot) {
    if (look_for == *slot) {
      out << padded_address(cell_from_ptr(obj)) << " ";
      print_nested_obj(out, tag_dynamic(obj), 2);
      out << endl;
    }
  };
  each_object_each_slot(find_data_ref_func);
}

void factor_vm::dump_edges(ostream& out) {
  primitive_full_gc();
  auto dump_edges_func = [&](object* obj, cell* scan) {
    if (TAG(*scan) > F_TYPE) {
      out << (void*)tag_dynamic(obj);
      out << " ==> ";
      out << (void*)*scan << endl;
    }
  };
  each_object_each_slot(dump_edges_func);
}

struct code_block_printer {
  factor_vm* parent;
  ostream& out;
  cell reloc_size, parameter_size;

  explicit code_block_printer(factor_vm* parent, ostream& out)
      : parent(parent), out(out), reloc_size(0), parameter_size(0) {}

  void operator()(code_block* scan, cell size) {
    const char* status;
    if (scan->free_p())
      status = "free";
    else {
      reloc_size += object_size(scan->relocation);
      parameter_size += object_size(scan->parameters);

      if (parent->code->allocator->state.marked_p(cell_from_ptr(scan)))
        status = "marked";
      else
        status = "allocated";

      out << hex << cell_from_ptr(scan) << dec << " ";
      out << hex << size << dec << " ";
      out << status << " ";
      out << "stack frame " << scan->stack_frame_size();
      out << endl;
    }
  }
};

// Dump all code blocks for debugging
void factor_vm::dump_code_heap(ostream& out) {
  code_block_printer printer(this, out);
  code->allocator->iterate(printer, no_fixup());
  out << printer.reloc_size << " bytes used by relocation tables" << endl;
  out << printer.parameter_size << " bytes used by parameter tables" << endl;
}

void factor_vm::factorbug_usage(bool advanced_p) {
  cout << "Basic commands:" << endl;
#ifdef WINDOWS
  cout << "  q ^Z             -- quit Factor" << endl;
#else
  cout << "  q ^D             -- quit Factor" << endl;
#endif
  cout << "  c                -- continue executing Factor - NOT SAFE"
       << endl;
  cout << "  t                -- throw exception in Factor - NOT SAFE"
       << endl;
  cout << "  .s .r .c         -- print data, retain, call stacks"
       << endl;
  if (advanced_p) {
    cout << "  help             -- reprint this message" << endl;
    cout << "Advanced commands:" << endl;
    cout << "  e                -- dump environment" << endl;
    cout << "  d <addr> <count> -- dump memory" << endl;
    cout << "  u <addr>         -- dump object at tagged <addr>"
         << endl;
    cout << "  . <addr>         -- print object at tagged <addr>"
         << endl;
    cout << "  g                -- dump memory layout" << endl;
    cout << "  ds dr            -- dump data, retain stacks" << endl;
    cout << "  trim             -- toggle output trimming" << endl;
    cout << "  data             -- data heap dump" << endl;
    cout << "  words            -- words dump" << endl;
    cout << "  tuples           -- tuples dump" << endl;
    cout << "  edges            -- print all object-to-object references"
         << endl;
    cout << "  refs <addr>      -- find data heap references to object"
         << endl;
    cout << "  push <addr>      -- push object on data stack - NOT SAFE"
         << endl;
    cout << "  gc               -- trigger full GC - NOT SAFE"
         << endl;
    cout << "  compact-gc       -- trigger compacting GC - NOT SAFE"
         << endl;
    cout << "  code             -- code heap dump" << endl;
    cout << "  abort            -- call abort()" << endl;
    cout << "  breakpoint       -- trigger system breakpoint" << endl;
  } else {
    cout << "  help             -- full help, including advanced commands"
         << endl;
  }
  cout << endl;
}

static void exit_fep(factor_vm* vm) {
  unlock_console();
  handle_ctrl_c();
  vm->fep_p = false;
}

void factor_vm::factorbug() {
  if (fep_disabled) {
    cout << "Low level debugger disabled" << endl;
    exit(1);
  }

  if (sampling_profiler_p)
    end_sampling_profiler();

  fep_p = true;

  cout << "Starting low level debugger..." << endl;

  // Even though we've stopped the VM, the stdin_loop thread (see os-*.cpp)
  // that pumps the console is still running concurrently. We lock a mutex so
  // the thread will take a break and give us exclusive access to stdin.
  lock_console();
  ignore_ctrl_c();

  if (!fep_help_was_shown) {
    factorbug_usage(false);
    fep_help_was_shown = true;
  }
  bool seen_command = false;

  for (;;) {
    std::string cmd;

    cout << "> " << flush;

    cin >> setw(1024) >> cmd >> setw(0);
    if (!cin.good()) {
      if (!seen_command) {
        // If we exit with an EOF immediately, then
        // dump stacks. This is useful for builder and
        // other cases where Factor is run with stdin
        // redirected to /dev/nullptr
        fep_disabled = true;

        print_datastack(cout);
        print_retainstack(cout);
        print_callstack(cout);
      }

      exit(1);
    }

    seen_command = true;

    if (cmd == "q")
      exit(1);
    if (cmd == "d") {
      cell addr = read_cell_hex();
      if (cin.peek() == ' ')
        cin.ignore();

      if (!cin.good())
        break;
      cell count = read_cell_hex();
      dump_memory(cout, addr, addr + count);
    } else if (cmd == "u") {
      cell addr = read_cell_hex();
      cell count = object_size(addr);
      dump_memory(cout, addr, addr + count);
    } else if (cmd == ".") {
      cell addr = read_cell_hex();
      print_obj(cout, addr);
      cout << endl;
    } else if (cmd == "trim")
      full_output = !full_output;
    else if (cmd == "ds")
      dump_memory(cout, ctx->datastack_seg->start, ctx->datastack);
    else if (cmd == "dr")
      dump_memory(cout, ctx->retainstack_seg->start, ctx->retainstack);
    else if (cmd == ".s")
      print_datastack(cout);
    else if (cmd == ".r")
      print_retainstack(cout);
    else if (cmd == ".c")
      print_callstack(cout);
    else if (cmd == "e") {
      for (cell i = 0; i < special_object_count; i++)
        dump_cell(cout, cell_from_ptr(&special_objects[i]));
    } else if (cmd == "g")
      dump_memory_layout(cout);
    else if (cmd == "c") {
      exit_fep(this);
      return;
    } else if (cmd == "t") {
      exit_fep(this);
      general_error(ERROR_INTERRUPT, false_object, false_object);
      FACTOR_ASSERT(false);
    } else if (cmd == "data")
      dump_objects(cout, TYPE_COUNT);
    else if (cmd == "edges")
      dump_edges(cout);
    else if (cmd == "refs") {
      cell addr = read_cell_hex();
      cout << "Data heap references:" << endl;
      find_data_references(cout, addr);
      cout << endl;
    } else if (cmd == "words")
      dump_objects(cout, WORD_TYPE);
    else if (cmd == "tuples")
      dump_objects(cout, TUPLE_TYPE);
    else if (cmd == "push") {
      cell addr = read_cell_hex();
      ctx->push(addr);
    } else if (cmd == "code")
      dump_code_heap(cout);
    else if (cmd == "gc")
      primitive_full_gc();
    else if (cmd == "compact-gc")
      primitive_compact_gc();
    else if (cmd == "help")
      factorbug_usage(true);
    else if (cmd == "abort")
      abort();
    else if (cmd == "breakpoint")
      breakpoint();
    else
      cout << "unknown command" << endl;
  }
}

void factor_vm::primitive_die() {
  critical_error("The die word was called by the library.", 0);
}

}
