#include "w2c2_base.h"

#include "circuit.h"

void circuit_f45(circuitInstance* i, U32 l0, U32 l1) {
  U64 l2 = 0;
  U64 l3 = 0;
  U32 si0, si1, si2;
  U64 sj0, sj1, sj2;
  si0 = l1;
  si0 = i32_load8_u(i->m0, (U64)si0 + 7U);
  si1 = 128U;
  si0 &= si1;
  if (si0) {
    si0 = l1;
    si0 = i32_load8_u(i->m0, (U64)si0 + 7U);
    si1 = 64U;
    si0 &= si1;
    if (si0) {
      si0 = l0;
      si1 = -1073741824U;
      i32_store(i->m0, (U64)si0 + 4U, si1);
    } else {
      si0 = l0;
      si1 = -2147483648U;
      i32_store(i->m0, (U64)si0 + 4U, si1);
    }
    L2:;
    si0 = l1;
    si1 = 8U;
    si0 += si1;
    si1 = l0;
    si2 = 8U;
    si1 += si2;
    circuit_f22(i, si0, si1);
  } else {
    sj0 = W2C2_LL(0U);
    si1 = l1;
    sj1 = i64_load32_s(i->m0, (U64)si1);
    sj0 -= sj1;
    l2 = sj0;
    sj0 = l2;
    sj1 = W2C2_LL(31U);
    sj0 = (U64)((I64)sj0 >> (sj1 & 63));
    l3 = sj0;
    sj0 = l3;
    si0 = !(sj0);
    sj1 = l3;
    sj2 = W2C2_LL(1U);
    sj1 += sj2;
    si1 = !(sj1);
    si0 |= si1;
    if (si0) {
      si0 = l0;
      sj1 = l2;
      i64_store32(i->m0, (U64)si0, sj1);
      si0 = l0;
      si1 = 0U;
      i32_store(i->m0, (U64)si0 + 4U, si1);
    } else {
      si0 = l0;
      si1 = -2147483648U;
      i32_store(i->m0, (U64)si0 + 4U, si1);
      si0 = l0;
      si1 = 8U;
      si0 += si1;
      sj1 = l2;
      circuit_f40(i, si0, sj1);
    }
    L3:;
  }
  L1:;
  L0:;
}

