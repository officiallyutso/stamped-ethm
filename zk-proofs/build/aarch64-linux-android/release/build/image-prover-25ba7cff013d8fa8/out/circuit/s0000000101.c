#include "w2c2_base.h"

#include "circuit.h"

void circuit_f74(circuitInstance* i, U32 l0, U32 l1, U32 l2) {
  U32 si0, si1, si2;
  U64 sj1, sj2;
  si0 = l2;
  si1 = l0;
  sj1 = i64_load(i->m0, (U64)si1);
  si2 = l1;
  sj2 = i64_load(i->m0, (U64)si2);
  sj1 &= sj2;
  i64_store(i->m0, (U64)si0, sj1);
  si0 = l2;
  si1 = l0;
  sj1 = i64_load(i->m0, (U64)si1 + 8U);
  si2 = l1;
  sj2 = i64_load(i->m0, (U64)si2 + 8U);
  sj1 &= sj2;
  i64_store(i->m0, (U64)si0 + 8U, sj1);
  si0 = l2;
  si1 = l0;
  sj1 = i64_load(i->m0, (U64)si1 + 16U);
  si2 = l1;
  sj2 = i64_load(i->m0, (U64)si2 + 16U);
  sj1 &= sj2;
  i64_store(i->m0, (U64)si0 + 16U, sj1);
  si0 = l2;
  si1 = l0;
  sj1 = i64_load(i->m0, (U64)si1 + 24U);
  si2 = l1;
  sj2 = i64_load(i->m0, (U64)si2 + 24U);
  sj1 &= sj2;
  i64_store(i->m0, (U64)si0 + 24U, sj1);
  L0:;
}

