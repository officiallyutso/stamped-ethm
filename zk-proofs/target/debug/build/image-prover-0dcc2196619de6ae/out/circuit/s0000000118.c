#include "w2c2_base.h"

#include "circuit.h"

void circuit_f84(circuitInstance* i, U32 l0, U32 l1) {
  U32 si0;
  U64 sj1;
  si0 = l1;
  si0 = circuit_f39(i, si0);
  if (si0) {
    si0 = l0;
    sj1 = W2C2_LL(0U);
    i64_store(i->m0, (U64)si0, sj1);
  } else {
    si0 = l0;
    sj1 = W2C2_LL(1U);
    i64_store(i->m0, (U64)si0, sj1);
  }
  L1:;
  L0:;
}

