#include "w2c2_base.h"

#include "circuit.h"

void circuit_f96(circuitInstance* i, U32 l0, U32 l1, U32 l2) {
  U32 l3 = 0;
  U32 l4 = 0;
  U32 l5 = 0;
  U32 l6 = 0;
  U32 l7 = 0;
  U32 l8 = 0;
  U32 si0, si1;
  U64 sj0, sj1;
  si0 = 6128U;
  si0 = i32_load(i->m0, (U64)si0);
  l3 = si0;
  si0 = l3;
  si0 = !(si0);
  if (si0) {
    si0 = 2U;
    circuit_runtime__exceptionHandler(i, si0);
  } else {
    si0 = l0;
    sj0 = (U64)(si0);
    sj1 = W2C2_LL(32U);
    sj0 <<= (sj1 & 63);
    si1 = l1;
    sj1 = (U64)(si1);
    sj0 |= sj1;
    si0 = circuit_f94(i, sj0);
    l4 = si0;
    si0 = !(si0);
    if (si0) {
      si0 = 1U;
      circuit_runtime__exceptionHandler(i, si0);
    } else {
      si0 = l2;
      si1 = l4;
      si1 = i32_load(i->m0, (U64)si1 + 12U);
      si0 = si0 >= si1;
      if (si0) {
        si0 = 6U;
        circuit_runtime__exceptionHandler(i, si0);
      } else {
        si0 = l4;
        si0 = i32_load(i->m0, (U64)si0 + 8U);
        si1 = l2;
        si0 += si1;
        l5 = si0;
        si1 = 1U;
        si0 -= si1;
        si0 = circuit_f95(i, si0);
        if (si0) {
          si0 = 3U;
          circuit_runtime__exceptionHandler(i, si0);
        } else {
          si0 = l5;
          si1 = 40U;
          si0 *= si1;
          si1 = 11856U;
          si0 += si1;
          l6 = si0;
          si0 = l6;
          si1 = 1984U;
          si1 = circuit_f47(i, si1);
          l7 = si1;
          si1 = l7;
          i32_store(i->m0, (U64)si0, si1);
          si0 = l6;
          si1 = 0U;
          i32_store(i->m0, (U64)si0 + 4U, si1);
          si0 = l6;
          si1 = 8U;
          si0 += si1;
          circuit_f5(i, si0);
          si0 = l6;
          si1 = 1984U;
          si0 = circuit_f50(i, si0, si1);
          if (si0) {
            si0 = l6;
            si1 = l7;
            i32_store(i->m0, (U64)si0, si1);
            si0 = l6;
            si1 = 0U;
            i32_store(i->m0, (U64)si0 + 4U, si1);
            si0 = l6;
            si1 = 8U;
            si0 += si1;
            circuit_f5(i, si0);
          } else {
            si0 = l6;
            si1 = 1984U;
            circuit_f37(i, si0, si1);
          }
          L5:;
          si0 = l3;
          si1 = -1U;
          si0 += si1;
          l3 = si0;
          si0 = 6128U;
          si1 = l3;
          i32_store(i->m0, (U64)si0, si1);
          si0 = l3;
          si0 = !(si0);
          if (si0) {
            si0 = 99580U;
            si0 = circuit_f403(i, si0);
            l8 = si0;
            if (si0) {
              si0 = l8;
              circuit_runtime__exceptionHandler(i, si0);
            }
            L7:;
          }
          L6:;
        }
        L4:;
      }
      L3:;
    }
    L2:;
  }
  L1:;
  L0:;
}

