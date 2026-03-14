#include "w2c2_base.h"

#include "circuit.h"

void circuit_f67(circuitInstance* i, U32 l0, U32 l1, U32 l2) {
  U32 l3 = 0;
  U64 l4 = 0;
  U32 l5 = 0;
  U64 l6 = 0;
  U32 l7 = 0;
  U32 si0, si1, si2, si3, si4;
  U64 sj0, sj1, sj2, sj3;
  si0 = 0U;
  si1 = l2;
  si2 = 6U;
  si1 >>= (si2 & 31);
  si0 -= si1;
  l3 = si0;
  si0 = l3;
  si1 = 1U;
  si0 -= si1;
  l5 = si0;
  si0 = l2;
  sj0 = (U64)(si0);
  sj1 = W2C2_LL(63U);
  sj0 &= sj1;
  l4 = sj0;
  sj0 = W2C2_LL(64U);
  sj1 = l4;
  sj0 -= sj1;
  l6 = sj0;
  si0 = 0U;
  l7 = si0;
  {
    L2:;
    {
      si0 = l7;
      si1 = 4U;
      si0 = si0 == si1;
      if (si0) {
        goto L1;
      }
      si0 = l0;
      si1 = l7;
      si2 = 8U;
      si1 *= si2;
      si0 += si1;
      si1 = l1;
      si2 = l3;
      si3 = l7;
      si2 += si3;
      sj1 = circuit_f66(i, si1, si2);
      sj2 = l4;
      sj1 = circuit_f64(i, sj1, sj2);
      si2 = l1;
      si3 = l5;
      si4 = l7;
      si3 += si4;
      sj2 = circuit_f66(i, si2, si3);
      sj3 = l6;
      sj2 = circuit_f65(i, sj2, sj3);
      sj1 |= sj2;
      i64_store(i->m0, (U64)si0, sj1);
      si0 = l7;
      si1 = 1U;
      si0 += si1;
      l7 = si0;
      goto L2;
    }
  }
  L1:;
  L0:;
}

