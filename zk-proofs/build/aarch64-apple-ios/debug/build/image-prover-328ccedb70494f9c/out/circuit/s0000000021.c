#include "w2c2_base.h"

#include "circuit.h"

void circuit_f42(circuitInstance* i, U32 l0) {
  U32 si0, si1, si2;
  si0 = l0;
  si0 = i32_load8_u(i->m0, (U64)si0 + 7U);
  si1 = 64U;
  si0 &= si1;
  if (si0) {
    si0 = l0;
    si0 = i32_load8_u(i->m0, (U64)si0 + 7U);
    si1 = 128U;
    si0 &= si1;
    if (si0) {
      si0 = l0;
      si1 = -2147483648U;
      i32_store(i->m0, (U64)si0 + 4U, si1);
      si0 = l0;
      si1 = 8U;
      si0 += si1;
      si1 = l0;
      si2 = 8U;
      si1 += si2;
      circuit_f28(i, si0, si1);
    }
    L2:;
  }
  L1:;
  L0:;
}

