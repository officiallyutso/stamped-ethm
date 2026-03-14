#include "w2c2_base.h"

#include "circuit.h"

void circuit_f103(circuitInstance* i, U32 l0) {
  U32 si0, si1;
  U64 sj1;
  si0 = 1992U;
  si1 = l0;
  i32_store(i->m0, (U64)si0, si1);
  si0 = 1992U;
  si1 = 0U;
  i32_store(i->m0, (U64)si0 + 4U, si1);
  si0 = 1992U;
  sj1 = W2C2_LL(0U);
  i64_store(i->m0, (U64)si0 + 8U, sj1);
  si0 = 1992U;
  sj1 = W2C2_LL(0U);
  i64_store(i->m0, (U64)si0 + 16U, sj1);
  si0 = 1992U;
  sj1 = W2C2_LL(0U);
  i64_store(i->m0, (U64)si0 + 24U, sj1);
  L0:;
}

