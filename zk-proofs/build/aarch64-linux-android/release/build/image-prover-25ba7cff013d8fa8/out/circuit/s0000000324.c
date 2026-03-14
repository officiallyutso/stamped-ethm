#include "w2c2_base.h"

#include "circuit.h"

U32 circuit_f228(circuitInstance* i, U32 l0) {
  U32 l1 = 0;
  U32 l2 = 0;
  U32 si0, si1, si2;
  si0 = 99576U;
  si0 = i32_load(i->m0, (U64)si0);
  l1 = si0;
  si0 = l1;
  si1 = 58U;
  i32_store(i->m0, (U64)si0, si1);
  si0 = l1;
  si1 = l0;
  i32_store(i->m0, (U64)si0 + 4U, si1);
  si0 = l1;
  si1 = 3U;
  i32_store(i->m0, (U64)si0 + 8U, si1);
  si0 = 99576U;
  si1 = l1;
  si2 = 12U;
  si1 += si2;
  i32_store(i->m0, (U64)si0, si1);
  si0 = l1;
  L0:;
  return si0;
}

