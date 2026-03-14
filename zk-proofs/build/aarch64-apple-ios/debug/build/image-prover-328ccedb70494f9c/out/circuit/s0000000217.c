#include "w2c2_base.h"

#include "circuit.h"

U32 circuit_f92(circuitInstance* i, U32 l0) {
  U32 l1 = 0;
  U32 l2 = 0;
  U32 l3 = 0;
  U32 si0, si1;
  si0 = 0U;
  si0 = i32_load(i->m0, (U64)si0);
  l1 = si0;
  si0 = l1;
  si1 = l0;
  si0 += si1;
  l2 = si0;
  si0 = 0U;
  si1 = l2;
  i32_store(i->m0, (U64)si0, si1);
  si0 = (*i->m0).pages;
  si1 = 16U;
  si0 <<= (si1 & 31);
  l3 = si0;
  si0 = l2;
  si1 = l3;
  si0 = si0 > si1;
  if (si0) {
    si0 = l2;
    si1 = l3;
    si0 -= si1;
    si1 = 65535U;
    si0 += si1;
    si1 = 16U;
    si0 >>= (si1 & 31);
    si0 = wasmMemoryGrow(i->m0, si0);
    si1 = -1U;
    si0 = si0 == si1;
    if (si0) {
      si0 = 5U;
      circuit_runtime__exceptionHandler(i, si0);
    }
    L2:;
  }
  L1:;
  si0 = l1;
  L0:;
  return si0;
}

