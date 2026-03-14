#include "w2c2_base.h"

#include "circuit.h"

void circuit_f38(circuitInstance* i, U32 l0, U32 l1, U32 l2) {
  U32 l3 = 0;
  U32 l4 = 0;
  U32 l5 = 0;
  U32 si0, si1, si2;
  U64 sj1;
  si0 = l1;
  l3 = si0;
  si0 = l0;
  l4 = si0;
  si0 = l3;
  si1 = l2;
  si2 = 40U;
  si1 *= si2;
  si0 += si1;
  l5 = si0;
  {
    L2:;
    {
      si0 = l3;
      si1 = l5;
      si0 = si0 == si1;
      if (si0) {
        goto L1;
      }
      si0 = l4;
      si1 = l3;
      sj1 = i64_load(i->m0, (U64)si1);
      i64_store(i->m0, (U64)si0, sj1);
      si0 = l4;
      si1 = 8U;
      si0 += si1;
      l4 = si0;
      si0 = l3;
      si1 = 8U;
      si0 += si1;
      l3 = si0;
      goto L2;
    }
  }
  L1:;
  L0:;
}

