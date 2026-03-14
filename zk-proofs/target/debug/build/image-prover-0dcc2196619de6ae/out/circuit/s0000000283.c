#include "w2c2_base.h"

#include "circuit.h"

void circuit_f32(circuitInstance* i, U32 l0, U32 l1, U32 l2) {
  U32 l3 = 0;
  U32 l4 = 0;
  U32 l5 = 0;
  U32 l6 = 0;
  U32 si0, si1, si2;
  si0 = l2;
  circuit_f5(i, si0);
  si0 = 32U;
  l5 = si0;
  si0 = l0;
  l3 = si0;
  {
    L2:;
    {
      si0 = l5;
      si1 = l1;
      si0 = si0 > si1;
      if (si0) {
        goto L1;
      }
      si0 = l5;
      si1 = 32U;
      si0 = si0 == si1;
      if (si0) {
        si0 = 1600U;
        circuit_f31(i, si0);
      } else {
        si0 = 1600U;
        si1 = 672U;
        si2 = 1600U;
        circuit_f24(i, si0, si1, si2);
      }
      L3:;
      si0 = l3;
      si1 = 1600U;
      si2 = 1632U;
      circuit_f24(i, si0, si1, si2);
      si0 = l2;
      si1 = 1632U;
      si2 = l2;
      circuit_f20(i, si0, si1, si2);
      si0 = l3;
      si1 = 32U;
      si0 += si1;
      l3 = si0;
      si0 = l5;
      si1 = 32U;
      si0 += si1;
      l5 = si0;
      goto L2;
    }
  }
  L1:;
  si0 = l1;
  si1 = 32U;
  si0 = REM_U(si0, si1);
  l4 = si0;
  si0 = l4;
  si0 = !(si0);
  if (si0) {
    goto L0;
  }
  L4:;
  si0 = 1632U;
  circuit_f5(i, si0);
  si0 = 0U;
  l6 = si0;
  {
    L6:;
    {
      si0 = l6;
      si1 = l4;
      si0 = si0 == si1;
      if (si0) {
        goto L5;
      }
      si0 = l6;
      si1 = l3;
      si1 = i32_load8_u(i->m0, (U64)si1);
      i32_store8(i->m0, (U64)si0 + 1632U, si1);
      si0 = l3;
      si1 = 1U;
      si0 += si1;
      l3 = si0;
      si0 = l6;
      si1 = 1U;
      si0 += si1;
      l6 = si0;
      goto L6;
    }
  }
  L5:;
  si0 = l5;
  si1 = 32U;
  si0 = si0 == si1;
  if (si0) {
    si0 = 1600U;
    circuit_f31(i, si0);
  } else {
    si0 = 1600U;
    si1 = 672U;
    si2 = 1600U;
    circuit_f24(i, si0, si1, si2);
  }
  L7:;
  si0 = 1632U;
  si1 = 1600U;
  si2 = 1632U;
  circuit_f24(i, si0, si1, si2);
  si0 = l2;
  si1 = 1632U;
  si2 = l2;
  circuit_f20(i, si0, si1, si2);
  L0:;
}

