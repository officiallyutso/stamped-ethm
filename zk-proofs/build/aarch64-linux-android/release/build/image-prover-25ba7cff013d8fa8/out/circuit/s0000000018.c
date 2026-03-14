#include "w2c2_base.h"

#include "circuit.h"

void circuit_f37(circuitInstance* i, U32 l0, U32 l1) {
  U32 si0, si1;
  U64 sj1;
  si0 = l0;
  si1 = l1;
  sj1 = i64_load(i->m0, (U64)si1);
  i64_store(i->m0, (U64)si0, sj1);
  si0 = l0;
  si1 = l1;
  sj1 = i64_load(i->m0, (U64)si1 + 8U);
  i64_store(i->m0, (U64)si0 + 8U, sj1);
  si0 = l0;
  si1 = l1;
  sj1 = i64_load(i->m0, (U64)si1 + 16U);
  i64_store(i->m0, (U64)si0 + 16U, sj1);
  si0 = l0;
  si1 = l1;
  sj1 = i64_load(i->m0, (U64)si1 + 24U);
  i64_store(i->m0, (U64)si0 + 24U, sj1);
  si0 = l0;
  si1 = l1;
  sj1 = i64_load(i->m0, (U64)si1 + 32U);
  i64_store(i->m0, (U64)si0 + 32U, sj1);
  L0:;
}

