#include "w2c2_base.h"

#include "circuit.h"

void circuit_f19(circuitInstance* i, U32 l0, U32 l1, U32 l2) {
  U32 l3 = 0;
  U32 l4 = 0;
  U32 l5 = 0;
  U32 l6 = 0;
  U32 l7 = 0;
  U32 l8 = 0;
  U32 l9 = 0;
  U32 l10 = 0;
  U32 l11 = 0;
  U32 l12 = 0;
  U32 l13 = 0;
  U32 si0, si1, si2, si3;
  si0 = 320U;
  l3 = si0;
  si0 = 320U;
  circuit_f5(i, si0);
  si0 = 0U;
  l11 = si0;
  si0 = 352U;
  l5 = si0;
  si0 = l1;
  si1 = 352U;
  circuit_f4(i, si0, si1);
  si0 = 384U;
  l4 = si0;
  si0 = 384U;
  circuit_f7(i, si0);
  si0 = 0U;
  l12 = si0;
  si0 = 416U;
  l8 = si0;
  si0 = l0;
  si1 = 416U;
  circuit_f4(i, si0, si1);
  si0 = 448U;
  l6 = si0;
  si0 = 480U;
  l7 = si0;
  si0 = 576U;
  l10 = si0;
  {
    L2:;
    {
      si0 = l8;
      si0 = circuit_f6(i, si0);
      if (si0) {
        goto L1;
      }
      si0 = l5;
      si1 = l8;
      si2 = l6;
      si3 = l7;
      circuit_f18(i, si0, si1, si2, si3);
      si0 = l6;
      si1 = l4;
      si2 = 512U;
      circuit_f13(i, si0, si1, si2);
      si0 = l11;
      if (si0) {
        si0 = l12;
        if (si0) {
          si0 = 512U;
          si1 = l3;
          si0 = circuit_f10(i, si0, si1);
          if (si0) {
            si0 = 512U;
            si1 = l3;
            si2 = l10;
            si0 = circuit_f12(i, si0, si1, si2);
            si0 = 0U;
            l13 = si0;
          } else {
            si0 = l3;
            si1 = 512U;
            si2 = l10;
            si0 = circuit_f12(i, si0, si1, si2);
            si0 = 1U;
            l13 = si0;
          }
          L5:;
        } else {
          si0 = 512U;
          si1 = l3;
          si2 = l10;
          si0 = circuit_f11(i, si0, si1, si2);
          si0 = 1U;
          l13 = si0;
        }
        L4:;
      } else {
        si0 = l12;
        if (si0) {
          si0 = 512U;
          si1 = l3;
          si2 = l10;
          si0 = circuit_f11(i, si0, si1, si2);
          si0 = 0U;
          l13 = si0;
        } else {
          si0 = l3;
          si1 = 512U;
          si0 = circuit_f10(i, si0, si1);
          if (si0) {
            si0 = l3;
            si1 = 512U;
            si2 = l10;
            si0 = circuit_f12(i, si0, si1, si2);
            si0 = 0U;
            l13 = si0;
          } else {
            si0 = 512U;
            si1 = l3;
            si2 = l10;
            si0 = circuit_f12(i, si0, si1, si2);
            si0 = 1U;
            l13 = si0;
          }
          L7:;
        }
        L6:;
      }
      L3:;
      si0 = l3;
      l9 = si0;
      si0 = l4;
      l3 = si0;
      si0 = l10;
      l4 = si0;
      si0 = l9;
      l10 = si0;
      si0 = l12;
      l11 = si0;
      si0 = l13;
      l12 = si0;
      si0 = l5;
      l9 = si0;
      si0 = l8;
      l5 = si0;
      si0 = l7;
      l8 = si0;
      si0 = l9;
      l7 = si0;
      goto L2;
    }
  }
  L1:;
  si0 = l11;
  if (si0) {
    si0 = l1;
    si1 = l3;
    si2 = l2;
    si0 = circuit_f12(i, si0, si1, si2);
  } else {
    si0 = l3;
    si1 = l2;
    circuit_f4(i, si0, si1);
  }
  L8:;
  L0:;
}

