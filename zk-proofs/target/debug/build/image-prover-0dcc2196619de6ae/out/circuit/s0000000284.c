#include "w2c2_base.h"

#include "circuit.h"

U32 circuit_f94(circuitInstance* i, U64 l0) {
  U32 l1 = 0;
  U32 l2 = 0;
  U32 l3 = 0;
  U32 si0, si1, si2;
  U64 sj0, sj1;
  sj0 = l0;
  si0 = (U32)(sj0);
  si1 = 255U;
  si0 &= si1;
  l1 = si0;
  si0 = l1;
  l2 = si0;
  {
    L2:;
    {
      si0 = 2032U;
      si1 = l2;
      si2 = 16U;
      si1 *= si2;
      si0 += si1;
      l3 = si0;
      si0 = l3;
      sj0 = i64_load(i->m0, (U64)si0);
      sj1 = l0;
      si0 = sj0 == sj1;
      if (si0) {
        si0 = l3;
        goto L0;
      }
      L3:;
      si0 = l3;
      sj0 = i64_load(i->m0, (U64)si0);
      si0 = !(sj0);
      if (si0) {
        si0 = 0U;
        goto L0;
      }
      L4:;
      si0 = l2;
      si1 = 1U;
      si0 += si1;
      si1 = 255U;
      si0 &= si1;
      l2 = si0;
      si0 = l2;
      si1 = l1;
      si0 = si0 == si1;
      if (si0) {
        si0 = 0U;
        goto L0;
      }
      L5:;
      goto L2;
    }
  }
  L1:;
  si0 = 0U;
  L0:;
  return si0;
}

