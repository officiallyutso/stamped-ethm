#include "w2c2_base.h"

#include "circuit.h"

void circuit_f35(circuitInstance* i, U32 l0, U32 l1) {
  U32 l2 = 0;
  U32 l3 = 0;
  U32 l4 = 0;
  U32 si0, si1, si2, si3;
  si0 = l0;
  si0 = circuit_f6(i, si0);
  if (si0) {
    si0 = l1;
    circuit_f5(i, si0);
    goto L0;
  }
  L1:;
  si0 = 28U;
  l2 = si0;
  si0 = 928U;
  si1 = 1728U;
  circuit_f4(i, si0, si1);
  si0 = l0;
  si1 = 896U;
  si2 = 32U;
  si3 = 1760U;
  circuit_f34(i, si0, si1, si2, si3);
  si0 = l0;
  si1 = 960U;
  si2 = 32U;
  si3 = 1792U;
  circuit_f34(i, si0, si1, si2, si3);
  {
    L3:;
    {
      si0 = 1760U;
      si1 = 736U;
      si0 = circuit_f8(i, si0, si1);
      if (si0) {
        goto L2;
      }
      si0 = 1760U;
      si1 = 1824U;
      circuit_f25(i, si0, si1);
      si0 = 1U;
      l3 = si0;
      {
        L5:;
        {
          si0 = 1824U;
          si1 = 736U;
          si0 = circuit_f8(i, si0, si1);
          if (si0) {
            goto L4;
          }
          si0 = 1824U;
          si1 = 1824U;
          circuit_f25(i, si0, si1);
          si0 = l3;
          si1 = 1U;
          si0 += si1;
          l3 = si0;
          goto L5;
        }
      }
      L4:;
      si0 = 1728U;
      si1 = 1856U;
      circuit_f4(i, si0, si1);
      si0 = l2;
      si1 = l3;
      si0 -= si1;
      si1 = 1U;
      si0 -= si1;
      l4 = si0;
      {
        L7:;
        {
          si0 = l4;
          si0 = !(si0);
          if (si0) {
            goto L6;
          }
          si0 = 1856U;
          si1 = 1856U;
          circuit_f25(i, si0, si1);
          si0 = l4;
          si1 = 1U;
          si0 -= si1;
          l4 = si0;
          goto L7;
        }
      }
      L6:;
      si0 = l3;
      l2 = si0;
      si0 = 1856U;
      si1 = 1728U;
      circuit_f25(i, si0, si1);
      si0 = 1760U;
      si1 = 1728U;
      si2 = 1760U;
      circuit_f24(i, si0, si1, si2);
      si0 = 1792U;
      si1 = 1856U;
      si2 = 1792U;
      circuit_f24(i, si0, si1, si2);
      goto L3;
    }
  }
  L2:;
  si0 = 1792U;
  si0 = circuit_f29(i, si0);
  if (si0) {
    si0 = 1792U;
    si1 = l1;
    circuit_f22(i, si0, si1);
  } else {
    si0 = 1792U;
    si1 = l1;
    circuit_f4(i, si0, si1);
  }
  L8:;
  L0:;
}

