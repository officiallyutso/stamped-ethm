#include "w2c2_base.h"

#include "circuit.h"

U32 circuit_f39(circuitInstance* i, U32 l0) {
  U32 si0, si1;
  si0 = l0;
  si0 = i32_load8_u(i->m0, (U64)si0 + 7U);
  si1 = 128U;
  si0 &= si1;
  if (si0) {
    si0 = l0;
    si1 = 8U;
    si0 += si1;
    si0 = circuit_f6(i, si0);
    si0 = !(si0);
    goto L0;
  }
  L1:;
  si0 = l0;
  si0 = i32_load(i->m0, (U64)si0);
  si1 = 0U;
  si0 = si0 != si1;
  L0:;
  return si0;
}

