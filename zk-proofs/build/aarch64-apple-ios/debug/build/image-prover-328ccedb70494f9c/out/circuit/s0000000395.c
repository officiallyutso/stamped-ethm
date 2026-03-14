#include "w2c2_base.h"

#include "circuit.h"

U32 circuit_f90(circuitInstance* i, U32 l0) {
  U32 si0, si1, si2;
  si0 = 1992U;
  si1 = l0;
  si2 = 4U;
  si1 *= si2;
  si0 += si1;
  si0 = i32_load(i->m0, (U64)si0);
  L0:;
  return si0;
}

