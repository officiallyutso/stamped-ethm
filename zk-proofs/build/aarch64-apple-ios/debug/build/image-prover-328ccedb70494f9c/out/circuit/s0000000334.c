#include "w2c2_base.h"

#include "circuit.h"

U32 circuit_f97(circuitInstance* i, U32 l0, U32 l1) {
  U32 si0, si1;
  U64 sj0, sj1;
  si0 = l0;
  sj0 = (U64)(si0);
  sj1 = W2C2_LL(32U);
  sj0 <<= (sj1 & 63);
  si1 = l1;
  sj1 = (U64)(si1);
  sj0 |= sj1;
  si0 = circuit_f94(i, sj0);
  si0 = i32_load(i->m0, (U64)si0 + 12U);
  L0:;
  return si0;
}

