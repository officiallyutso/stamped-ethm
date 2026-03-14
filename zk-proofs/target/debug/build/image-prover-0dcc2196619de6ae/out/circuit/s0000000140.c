#include "w2c2_base.h"

#include "circuit.h"

void circuit_f17(circuitInstance* i, U32 l0, U64 l1) {
  U64 l2 = 0;
  U32 l3 = 0;
  U32 si0, si1;
  U64 sj0, sj1;
  si0 = l0;
  l3 = si0;
  si0 = l3;
  sj0 = i64_load32_u(i->m0, (U64)si0);
  sj1 = l1;
  sj0 += sj1;
  l2 = sj0;
  si0 = l3;
  sj1 = l2;
  i64_store32(i->m0, (U64)si0, sj1);
  sj0 = l2;
  sj1 = W2C2_LL(32U);
  sj0 >>= (sj1 & 63);
  l2 = sj0;
  {
    L2:;
    {
      sj0 = l2;
      si0 = !(sj0);
      if (si0) {
        goto L1;
      }
      si0 = l3;
      si1 = 4U;
      si0 += si1;
      l3 = si0;
      si0 = l3;
      sj0 = i64_load32_u(i->m0, (U64)si0);
      sj1 = l2;
      sj0 += sj1;
      l2 = sj0;
      si0 = l3;
      sj1 = l2;
      i64_store32(i->m0, (U64)si0, sj1);
      sj0 = l2;
      sj1 = W2C2_LL(32U);
      sj0 >>= (sj1 & 63);
      l2 = sj0;
      goto L2;
    }
  }
  L1:;
  L0:;
}

