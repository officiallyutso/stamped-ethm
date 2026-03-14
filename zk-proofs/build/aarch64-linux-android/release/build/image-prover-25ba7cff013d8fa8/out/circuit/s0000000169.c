#include "w2c2_base.h"

#include "circuit.h"

void circuit_f40(circuitInstance* i, U32 l0, U64 l1) {
  U32 si0, si1;
  U64 sj0, sj1;
  sj0 = l1;
  sj1 = W2C2_LL(0U);
  si0 = (U64)((I64)sj0 > (I64)sj1);
  if (si0) {
    si0 = l0;
    sj1 = l1;
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
  } else {
    sj0 = W2C2_LL(0U);
    sj1 = l1;
    sj0 -= sj1;
    l1 = sj0;
    si0 = l0;
    sj1 = l1;
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
    si0 = l0;
    si1 = l0;
    circuit_f22(i, si0, si1);
  }
  L1:;
  L0:;
}

