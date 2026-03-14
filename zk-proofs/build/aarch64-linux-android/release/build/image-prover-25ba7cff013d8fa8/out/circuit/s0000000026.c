#include "w2c2_base.h"

#include "circuit.h"

void circuit_f91(circuitInstance* i, U32 l0, U32 l1) {
  U32 si0, si1, si2;
  si0 = 1992U;
  si1 = l0;
  si2 = 4U;
  si1 *= si2;
  si0 += si1;
  si1 = l1;
  i32_store(i->m0, (U64)si0, si1);
  L0:;
}

