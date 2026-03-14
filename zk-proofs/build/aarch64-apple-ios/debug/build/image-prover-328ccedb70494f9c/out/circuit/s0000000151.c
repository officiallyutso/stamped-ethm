#include "w2c2_base.h"

#include "circuit.h"

U32 circuit_f29(circuitInstance* i, U32 l0) {
  U32 si0, si1;
  si0 = l0;
  si1 = 1568U;
  circuit_f28(i, si0, si1);
  si0 = 1568U;
  si0 = i32_load(i->m0, (U64)si0);
  si1 = 1U;
  si0 &= si1;
  L0:;
  return si0;
}

