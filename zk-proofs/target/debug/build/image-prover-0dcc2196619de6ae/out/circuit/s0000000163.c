#include "w2c2_base.h"

#include "circuit.h"

U32 circuit_f85(circuitInstance* i, U32 l0, U32 l1) {
  U32 si0, si1, si2;
  si0 = 105080U;
  si1 = l0;
  si0 += si1;
  si0 = i32_load(i->m0, (U64)si0);
  si1 = l1;
  si2 = 4U;
  si1 *= si2;
  si0 += si1;
  si0 = i32_load(i->m0, (U64)si0);
  L0:;
  return si0;
}

