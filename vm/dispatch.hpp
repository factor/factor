namespace factor {

struct dispatch_statistics {
  cell megamorphic_cache_hits;
  cell megamorphic_cache_misses;

  cell cold_call_to_ic_transitions;
  cell ic_to_pic_transitions;
  cell pic_to_mega_transitions;

  cell pic_tag_count;
  cell pic_tuple_count;
};

}
