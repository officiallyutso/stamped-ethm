#include "w2c2_base.h"

#include "circuit.h"

void circuit_f41(circuitInstance* i, U32 l0) {
  U32 si0, si1, si2;
  U64 sj1;
  si0 = l0;
  si0 = i32_load8_u(i->m0, (U64)si0 + 7U);
  si1 = 64U;
  si0 &= si1;
  if (si0) {
    goto L0;
  } else {
    si0 = l0;
    si0 = i32_load8_u(i->m0, (U64)si0 + 7U);
    si1 = 128U;
    si0 &= si1;
    if (si0) {
      si0 = l0;
      si1 = -1073741824U;
      i32_store(i->m0, (U64)si0 + 4U, si1);
      si0 = l0;
      si1 = 8U;
      si0 += si1;
      si1 = l0;
      si2 = 8U;
      si1 += si2;
      circuit_f27(i, si0, si1);
    } else {
      si0 = l0;
      si1 = 8U;
      si0 += si1;
      si1 = l0;
      sj1 = i64_load32_s(i->m0, (U64)si1);
      circuit_f40(i, si0, sj1);
      si0 = l0;
      si1 = 8U;
      si0 += si1;
      si1 = l0;
      si2 = 8U;
      si1 += si2;
      circuit_f27(i, si0, si1);
      si0 = l0;
      si1 = 1073741824U;
      i32_store(i->m0, (U64)si0 + 4U, si1);
    }
    L2:;
  }
  L1:;
  L0:;
}

