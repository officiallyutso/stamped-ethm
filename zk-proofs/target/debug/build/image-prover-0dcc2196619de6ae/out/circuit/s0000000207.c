#include "w2c2_base.h"

#include "circuit.h"

U64 circuit_f64(circuitInstance* i, U64 l0, U64 l1) {
  U32 si0;
  U64 sj0, sj1;
  sj0 = l1;
  sj1 = W2C2_LL(64U);
  si0 = sj0 >= sj1;
  if (si0) {
    sj0 = W2C2_LL(0U);
    goto L0;
  }
  L1:;
  sj0 = l0;
  sj1 = l1;
  sj0 <<= (sj1 & 63);
  L0:;
  return sj0;
}

