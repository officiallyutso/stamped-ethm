#include "w2c2_base.h"

#include "circuit.h"

void circuit_f107(circuitInstance* i, U32 l0) {
  U32 l1 = 0;
  U32 l2 = 0;
  U32 l3 = 0;
  U32 si0, si1;
  si0 = l0;
  l1 = si0;
  si0 = 108956U;
  l2 = si0;
  {
    L2:;
    {
      si0 = 109196U;
      si1 = l1;
      si0 = si0 == si1;
      if (si0) {
        goto L1;
      }
      si0 = l1;
      si0 = i32_load8_u(i->m0, (U64)si0);
      l3 = si0;
      si0 = l3;
      si0 = !(si0);
      if (si0) {
        goto L1;
      }
      si0 = l2;
      si1 = l3;
      i32_store8(i->m0, (U64)si0, si1);
      si0 = l1;
      si1 = 1U;
      si0 += si1;
      l1 = si0;
      si0 = l2;
      si1 = 1U;
      si0 += si1;
      l2 = si0;
      goto L2;
    }
  }
  L1:;
  {
    L4:;
    {
      si0 = l2;
      si1 = 109212U;
      si0 = si0 == si1;
      if (si0) {
        goto L3;
      }
      si0 = l2;
      si1 = 0U;
      i32_store8(i->m0, (U64)si0, si1);
      si0 = l2;
      si1 = 1U;
      si0 += si1;
      l2 = si0;
      goto L4;
    }
  }
  L3:;
  si0 = 108952U;
  si1 = 0U;
  i32_store(i->m0, (U64)si0, si1);
  L0:;
}

