#include "w2c2_base.h"

#include "circuit.h"

U32 circuit_f46(circuitInstance* i, U32 l0) {
  U32 si0, si1;
  si0 = l0;
  si0 = i32_load8_u(i->m0, (U64)si0 + 7U);
  si1 = 128U;
  si0 &= si1;
  if (si0) {
    si0 = l0;
    circuit_f42(i, si0);
    si0 = l0;
    si0 = i32_load(i->m0, (U64)si0 + 8U);
    goto L0;
  } else {
    si0 = l0;
    si0 = i32_load(i->m0, (U64)si0);
    goto L0;
  }
  L1:;
  si0 = 0U;
  L0:;
  return si0;
}

