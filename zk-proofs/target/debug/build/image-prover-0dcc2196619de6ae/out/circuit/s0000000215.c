#include "w2c2_base.h"

#include "circuit.h"

void circuit_f69(circuitInstance* i, U32 l0) {
  U32 si0, si1, si2, si3;
  U64 sj1, sj2;
  si0 = l0;
  si1 = l0;
  sj1 = i64_load(i->m0, (U64)si1 + 32U);
  sj2 = W2C2_LL(4611686018427387903U);
  sj1 &= sj2;
  i64_store(i->m0, (U64)si0 + 32U, sj1);
  si0 = l0;
  si1 = 8U;
  si0 += si1;
  si1 = 608U;
  si0 = circuit_f10(i, si0, si1);
  if (si0) {
    si0 = l0;
    si1 = 8U;
    si0 += si1;
    si1 = 608U;
    si2 = l0;
    si3 = 8U;
    si2 += si3;
    si0 = circuit_f12(i, si0, si1, si2);
  }
  L1:;
  L0:;
}

