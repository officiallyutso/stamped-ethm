#include "w2c2_base.h"

#include "circuit.h"

U32 circuit_f36(circuitInstance* i, U32 l0) {
  U32 si0, si1, si2, si3;
  si0 = l0;
  si0 = circuit_f6(i, si0);
  if (si0) {
    si0 = 1U;
    goto L0;
  }
  L1:;
  si0 = l0;
  si1 = 800U;
  si2 = 32U;
  si3 = 1888U;
  circuit_f34(i, si0, si1, si2, si3);
  si0 = 1888U;
  si1 = 736U;
  si0 = circuit_f8(i, si0, si1);
  L0:;
  return si0;
}

