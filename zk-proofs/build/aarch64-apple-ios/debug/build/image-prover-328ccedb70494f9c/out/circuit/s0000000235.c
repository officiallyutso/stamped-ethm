#include "w2c2_base.h"

#include "circuit.h"

U32 circuit_f8(circuitInstance* i, U32 l0, U32 l1) {
  U32 si0, si1;
  U64 sj0, sj1;
  si0 = l0;
  sj0 = i64_load(i->m0, (U64)si0 + 24U);
  si1 = l1;
  sj1 = i64_load(i->m0, (U64)si1 + 24U);
  si0 = sj0 == sj1;
  if (si0) {
    si0 = l0;
    sj0 = i64_load(i->m0, (U64)si0 + 16U);
    si1 = l1;
    sj1 = i64_load(i->m0, (U64)si1 + 16U);
    si0 = sj0 == sj1;
    if (si0) {
      si0 = l0;
      sj0 = i64_load(i->m0, (U64)si0 + 8U);
      si1 = l1;
      sj1 = i64_load(i->m0, (U64)si1 + 8U);
      si0 = sj0 == sj1;
      if (si0) {
        si0 = l0;
        sj0 = i64_load(i->m0, (U64)si0);
        si1 = l1;
        sj1 = i64_load(i->m0, (U64)si1);
        si0 = sj0 == sj1;
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

