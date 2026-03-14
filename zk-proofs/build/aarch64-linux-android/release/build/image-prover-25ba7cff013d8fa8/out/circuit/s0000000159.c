#include "w2c2_base.h"

#include "circuit.h"

void circuit_f20(circuitInstance* i, U32 l0, U32 l1, U32 l2) {
  U32 si0, si1, si2;
  si0 = l0;
  si1 = l1;
  si2 = l2;
  si0 = circuit_f11(i, si0, si1, si2);
  if (si0) {
    si0 = l2;
    si1 = 608U;
    si2 = l2;
    si0 = circuit_f12(i, si0, si1, si2);
  } else {
    si0 = l2;
    si1 = 608U;
    si0 = circuit_f10(i, si0, si1);
    if (si0) {
      si0 = l2;
      si1 = 608U;
      si2 = l2;
      si0 = circuit_f12(i, si0, si1, si2);
    }
    L2:;
  }
  L1:;
  L0:;
}

