#include "w2c2_base.h"

#include "circuit.h"

U32 circuit_f47(circuitInstance* i, U32 l0) {
  U32 si0, si1;
  si0 = l0;
  si0 = circuit_f44(i, si0);
  if (si0) {
    si0 = 8U;
    si1 = l0;
    circuit_f45(i, si0, si1);
    si0 = 0U;
    si1 = 8U;
    si1 = circuit_f46(i, si1);
    si0 -= si1;
    goto L0;
  } else {
    si0 = l0;
    si0 = circuit_f46(i, si0);
    goto L0;
  }
  L1:;
  si0 = 0U;
  L0:;
  return si0;
}

