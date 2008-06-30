IN: micros.unix
USING: micros.backend io.backend system alien.c-types kernel unix.time math ;

M: unix (micros)
  "timespec" <c-object> dup f gettimeofday drop
  [ timespec-sec 1000000 * ] [ timespec-nsec ] bi + ;
