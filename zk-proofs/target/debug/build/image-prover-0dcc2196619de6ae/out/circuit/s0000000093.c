#include "w2c2_base.h"

#include "circuit.h"

void circuit_f18(circuitInstance* i, U32 l0, U32 l1, U32 l2, U32 l3) {
  U32 l4 = 0;
  U32 l5 = 0;
  U32 l6 = 0;
  U32 l7 = 0;
  U64 l8 = 0;
  U64 l9 = 0;
  U32 l10 = 0;
  U32 si0, si1, si2;
  U64 sj0, sj1;
  si0 = l2;
  if (si0) {
    si0 = l2;
    l5 = si0;
  } else {
    si0 = 192U;
    l5 = si0;
  }
  L1:;
  si0 = l3;
  if (si0) {
    si0 = l3;
    l4 = si0;
  } else {
    si0 = 224U;
    l4 = si0;
  }
  L2:;
  si0 = l0;
  si1 = l4;
  circuit_f4(i, si0, si1);
  si0 = l1;
  si1 = 160U;
  circuit_f4(i, si0, si1);
  si0 = l5;
  circuit_f5(i, si0);
  si0 = 256U;
  circuit_f5(i, si0);
  si0 = 31U;
  l6 = si0;
  si0 = 31U;
  l7 = si0;
  {
    L4:;
    {
      si0 = 160U;
      si1 = l7;
      si0 += si1;
      si0 = i32_load8_u(i->m0, (U64)si0);
      si1 = l7;
      si2 = 3U;
      si1 = si1 == si2;
      si0 |= si1;
      if (si0) {
        goto L3;
      }
      si0 = l7;
      si1 = 1U;
      si0 -= si1;
      l7 = si0;
      goto L4;
    }
  }
  L3:;
  si0 = 160U;
  si1 = l7;
  si0 += si1;
  si1 = 3U;
  si0 -= si1;
  sj0 = i64_load32_u(i->m0, (U64)si0);
  sj1 = W2C2_LL(1U);
  sj0 += sj1;
  l8 = sj0;
  sj0 = l8;
  sj1 = W2C2_LL(1U);
  si0 = sj0 == sj1;
  if (si0) {
    sj0 = W2C2_LL(0U);
    sj1 = W2C2_LL(0U);
    sj0 = DIV_U(sj0, sj1);
  }
  L5:;
  {
    L7:;
    {
      {
        L9:;
        {
          si0 = l4;
          si1 = l6;
          si0 += si1;
          si0 = i32_load8_u(i->m0, (U64)si0);
          si1 = l6;
          si2 = 7U;
          si1 = si1 == si2;
          si0 |= si1;
          if (si0) {
            goto L8;
          }
          si0 = l6;
          si1 = 1U;
          si0 -= si1;
          l6 = si0;
          goto L9;
        }
      }
      L8:;
      si0 = l4;
      si1 = l6;
      si0 += si1;
      si1 = 7U;
      si0 -= si1;
      sj0 = i64_load(i->m0, (U64)si0);
      l9 = sj0;
      sj0 = l9;
      sj1 = l8;
      sj0 = DIV_U(sj0, sj1);
      l9 = sj0;
      si0 = l6;
      si1 = l7;
      si0 -= si1;
      si1 = 4U;
      si0 -= si1;
      l10 = si0;
      {
        L11:;
        {
          sj0 = l9;
          sj1 = W2C2_LL(-4294967296U);
          sj0 &= sj1;
          si0 = !(sj0);
          si1 = l10;
          si2 = 0U;
          si1 = (U32)((I32)si1 >= (I32)si2);
          si0 &= si1;
          if (si0) {
            goto L10;
          }
          sj0 = l9;
          sj1 = W2C2_LL(8U);
          sj0 >>= (sj1 & 63);
          l9 = sj0;
          si0 = l10;
          si1 = 1U;
          si0 += si1;
          l10 = si0;
          goto L11;
        }
      }
      L10:;
      sj0 = l9;
      si0 = !(sj0);
      if (si0) {
        si0 = l4;
        si1 = 160U;
        si0 = circuit_f10(i, si0, si1);
        si0 = !(si0);
        if (si0) {
          goto L6;
        }
        sj0 = W2C2_LL(1U);
        l9 = sj0;
        si0 = 0U;
        l10 = si0;
      }
      L12:;
      si0 = 160U;
      sj1 = l9;
      si2 = 288U;
      circuit_f16(i, si0, sj1, si2);
      si0 = l4;
      si1 = 288U;
      si2 = l10;
      si1 -= si2;
      si2 = l4;
      si0 = circuit_f12(i, si0, si1, si2);
      si0 = l5;
      si1 = l10;
      si0 += si1;
      sj1 = l9;
      circuit_f17(i, si0, sj1);
      goto L7;
    }
  }
  L6:;
  L0:;
}

