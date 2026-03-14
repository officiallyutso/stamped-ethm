#include "w2c2_base.h"

#include "circuit.h"

void circuit_f7(circuitInstance* i, U32 l0) {
  U32 si0;
  U64 sj1;
  si0 = l0;
  sj1 = W2C2_LL(1U);
  i64_store(i->m0, (U64)si0, sj1);
  si0 = l0;
  sj1 = W2C2_LL(0U);
  i64_store(i->m0, (U64)si0 + 8U, sj1);
  si0 = l0;
  sj1 = W2C2_LL(0U);
  i64_store(i->m0, (U64)si0 + 16U, sj1);
  si0 = l0;
  sj1 = W2C2_LL(0U);
  i64_store(i->m0, (U64)si0 + 24U, sj1);
  L0:;
}

