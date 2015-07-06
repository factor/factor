#include "master.hpp"

/* A tool to debug write barriers. Call check_data_heap() to ensure that all
cards that should be marked are actually marked. */

namespace factor {

enum generation {
  nursery_generation,
  aging_generation,
  tenured_generation
};

inline generation generation_of(factor_vm* parent, object* obj) {
  if (parent->data->nursery->contains_p(obj))
    return nursery_generation;
  else if (parent->data->aging->contains_p(obj))
    return aging_generation;
  else if (parent->data->tenured->contains_p(obj))
    return tenured_generation;
  else {
    critical_error("Bad object", (cell)obj);
    return (generation)-1;
  }
}

struct slot_checker {
  factor_vm* parent;
  object* obj;
  generation gen;

  slot_checker(factor_vm* parent, object* obj, generation gen)
      : parent(parent), obj(obj), gen(gen) {}

  void check_write_barrier(cell* slot_ptr, generation target, char mask) {
    cell object_card_pointer = parent->cards_offset + ((cell)obj >> card_bits);
    cell slot_card_pointer =
        parent->cards_offset + ((cell)slot_ptr >> card_bits);
    char slot_card_value = *(char*)slot_card_pointer;
    if ((slot_card_value & mask) != mask) {
      std::cout << "card not marked" << std::endl;
      std::cout << "source generation: " << gen << std::endl;
      std::cout << "target generation: " << target << std::endl;
      std::cout << "object: 0x" << std::hex << (cell)
          obj << std::dec << std::endl;
      std::cout << "object type: " << obj->type() << std::endl;
      std::cout << "slot pointer: 0x" << std::hex << (cell)
          slot_ptr << std::dec << std::endl;
      std::cout << "slot value: 0x" << std::hex << *slot_ptr << std::dec
                << std::endl;
      std::cout << "card of object: 0x" << std::hex << object_card_pointer
                << std::dec << std::endl;
      std::cout << "card of slot: 0x" << std::hex << slot_card_pointer
                << std::dec << std::endl;
      std::cout << std::endl;
      parent->factorbug();
    }
  }

  void operator()(cell* slot_ptr) {
    if (immediate_p(*slot_ptr))
      return;

    generation target = generation_of(parent, untag<object>(*slot_ptr));
    if (gen == aging_generation && target == nursery_generation) {
      check_write_barrier(slot_ptr, target, card_points_to_nursery);
    } else if (gen == tenured_generation) {
      if (target == nursery_generation) {
        check_write_barrier(slot_ptr, target, card_points_to_nursery);
      } else if (target == aging_generation) {
        check_write_barrier(slot_ptr, target, card_points_to_aging);
      }
    }
  }
};

void factor_vm::check_data_heap() {
  auto checker = [&](object* obj){
    generation obj_gen = generation_of(this, obj);
    slot_checker s_checker(this, obj, obj_gen);
    obj->each_slot(s_checker);
  };
  each_object(checker);
}

}
