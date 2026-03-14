#include "w2c2_base.h"

#include "circuit.h"

void circuit_f93(circuitInstance* i, U32 l0) {
  U32 l1 = 0;
  U32 l2 = 0;
  U32 si0, si1;
  si0 = 6128U;
  si1 = 7U;
  i32_store(i->m0, (U64)si0, si1);
  si0 = 6132U;
  l1 = si0;
  {
    L2:;
    {
      si0 = l1;
      si1 = 6160U;
      si0 = si0 == si1;
      if (si0) {
        goto L1;
      }
      si0 = l1;
      si1 = 0U;
      i32_store(i->m0, (U64)si0, si1);
      si0 = l1;
      si1 = 4U;
      si0 += si1;
      l1 = si0;
      goto L2;
    }
  }
  L1:;
  si0 = 99576U;
  si1 = 99580U;
  i32_store(i->m0, (U64)si0, si1);
  si0 = 11896U;
  si0 = circuit_f402(i, si0);
  L0:;
}

