#include "w2c2_base.h"

#include "circuit.h"

U32 circuit_f6(circuitInstance* i, U32 l0) {
  U32 si0;
  U64 sj0;
  si0 = l0;
  sj0 = i64_load(i->m0, (U64)si0 + 24U);
  si0 = !(sj0);
  if (si0) {
    si0 = l0;
    sj0 = i64_load(i->m0, (U64)si0 + 16U);
    si0 = !(sj0);
    if (si0) {
      si0 = l0;
      sj0 = i64_load(i->m0, (U64)si0 + 8U);
      si0 = !(sj0);
      if (si0) {
        si0 = l0;
        sj0 = i64_load(i->m0, (U64)si0);
        si0 = !(sj0);
        goto L0;
      } else {
        si0 = 0U;
        goto L0;
      }
      L3:;
    } else {
      si0 = 0U;
      goto L0;
    }
    L2:;
  } else {
    si0 = 0U;
    goto L0;
  }
  L1:;
  si0 = 0U;
  goto L0;
  L0:;
  return si0;
}

