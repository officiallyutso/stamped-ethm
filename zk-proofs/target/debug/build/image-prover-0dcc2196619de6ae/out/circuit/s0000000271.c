#include "w2c2_base.h"

#include "circuit.h"

U64 circuit_f66(circuitInstance* i, U32 l0, U32 l1) {
  U32 si0, si1, si2;
  U64 sj0;
  si0 = l1;
  si1 = 4U;
  si0 = si0 < si1;
  if (si0) {
    si0 = l0;
    si1 = l1;
    si2 = 8U;
    si1 *= si2;
    si0 += si1;
    sj0 = i64_load(i->m0, (U64)si0);
    goto L0;
  }
  L1:;
  sj0 = W2C2_LL(0U);
  L0:;
  return sj0;
}

