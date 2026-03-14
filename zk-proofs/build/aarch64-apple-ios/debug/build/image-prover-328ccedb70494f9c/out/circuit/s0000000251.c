#include "w2c2_base.h"

#include "circuit.h"

void circuit_f106(circuitInstance* i, U32 l0, U32 l1) {
  U32 l2 = 0;
  U32 l3 = 0;
  U32 l4 = 0;
  U32 l5 = 0;
  U32 si0, si1, si2;
  si0 = 109212U;
  si1 = l0;
  si2 = 240U;
  si1 *= si2;
  si0 += si1;
  l2 = si0;
  si0 = 108956U;
  l3 = si0;
  {
    L2:;
    {
      si0 = 109196U;
      si1 = l2;
      si0 = si0 == si1;
      if (si0) {
        goto L1;
      }
      si0 = l2;
      si0 = i32_load8_u(i->m0, (U64)si0);
      l4 = si0;
      si0 = l4;
      si0 = !(si0);
      if (si0) {
        goto L1;
      }
      si0 = l3;
      si1 = l4;
      i32_store8(i->m0, (U64)si0, si1);
      si0 = l2;
      si1 = 1U;
      si0 += si1;
      l2 = si0;
      si0 = l3;
      si1 = 1U;
      si0 += si1;
      l3 = si0;
      goto L2;
    }
  }
  L1:;
  si0 = l3;
  si1 = 32U;
  i32_store8(i->m0, (U64)si0, si1);
  si0 = l3;
  si1 = 1U;
  si0 += si1;
  l3 = si0;
  si0 = l3;
  si1 = 108U;
  i32_store8(i->m0, (U64)si0, si1);
  si0 = l3;
  si1 = 1U;
  si0 += si1;
  l3 = si0;
  si0 = l3;
  si1 = 105U;
  i32_store8(i->m0, (U64)si0, si1);
  si0 = l3;
  si1 = 1U;
  si0 += si1;
  l3 = si0;
  si0 = l3;
  si1 = 110U;
  i32_store8(i->m0, (U64)si0, si1);
  si0 = l3;
  si1 = 1U;
  si0 += si1;
  l3 = si0;
  si0 = l3;
  si1 = 101U;
  i32_store8(i->m0, (U64)si0, si1);
  si0 = l3;
  si1 = 1U;
  si0 += si1;
  l3 = si0;
  si0 = l3;
  si1 = 58U;
  i32_store8(i->m0, (U64)si0, si1);
  si0 = l3;
  si1 = 1U;
  si0 += si1;
  l3 = si0;
  si0 = l3;
  si1 = 32U;
  i32_store8(i->m0, (U64)si0, si1);
  si0 = l3;
  si1 = 1U;
  si0 += si1;
  l3 = si0;
  si0 = 1U;
  l5 = si0;
  {
    L4:;
    {
      si0 = l5;
      si1 = 10U;
      si0 *= si1;
      si1 = l1;
      si0 = si0 > si1;
      if (si0) {
        goto L3;
      }
      si0 = l5;
      si1 = 10U;
      si0 *= si1;
      l5 = si0;
      goto L4;
    }
  }
  L3:;
  {
    L6:;
    {
      si0 = l5;
      si0 = !(si0);
      if (si0) {
        goto L5;
      }
      si0 = l3;
      si1 = l1;
      si2 = l5;
      si1 = DIV_U(si1, si2);
      si2 = 48U;
      si1 += si2;
      i32_store8(i->m0, (U64)si0, si1);
      si0 = l3;
      si1 = 1U;
      si0 += si1;
      l3 = si0;
      si0 = l1;
      si1 = l5;
      si0 = REM_U(si0, si1);
      l1 = si0;
      si0 = l5;
      si1 = 10U;
      si0 = DIV_U(si0, si1);
      l5 = si0;
      goto L6;
    }
  }
  L5:;
  {
    L8:;
    {
      si0 = l3;
      si1 = 109212U;
      si0 = si0 == si1;
      if (si0) {
        goto L7;
      }
      si0 = l3;
      si1 = 0U;
      i32_store8(i->m0, (U64)si0, si1);
      si0 = l3;
      si1 = 1U;
      si0 += si1;
      l3 = si0;
      goto L8;
    }
  }
  L7:;
  si0 = 108952U;
  si1 = 0U;
  i32_store(i->m0, (U64)si0, si1);
  L0:;
}

