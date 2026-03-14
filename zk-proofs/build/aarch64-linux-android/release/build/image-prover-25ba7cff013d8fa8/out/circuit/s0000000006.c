#include "w2c2_base.h"

#include "circuit.h"

U32 circuit_f105(circuitInstance* i) {
  U32 l0 = 0;
  U32 si0, si1, si2, si3;
  si0 = 108952U;
  si0 = i32_load(i->m0, (U64)si0);
  l0 = si0;
  si0 = l0;
  si1 = 256U;
  si0 = si0 >= si1;
  if (si0) {
    si0 = 0U;
    goto L0;
  } else {
    si0 = 108956U;
    si1 = l0;
    si0 += si1;
    si0 = i32_load8_u(i->m0, (U64)si0);
    si1 = 108952U;
    si2 = l0;
    si3 = 1U;
    si2 += si3;
    i32_store(i->m0, (U64)si1, si2);
    goto L0;
  }
  L1:;
  si0 = 0U;
  L0:;
  return si0;
}

