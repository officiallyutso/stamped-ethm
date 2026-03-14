#include "w2c2_base.h"

#include "circuit.h"

void circuit_f102(circuitInstance* i, U32 l0) {
  U32 l1 = 0;
  U32 si0, si1, si2;
  si0 = 6160U;
  si1 = l0;
  si2 = 2U;
  si1 <<= (si2 & 31);
  si0 += si1;
  si0 = i32_load(i->m0, (U64)si0);
  si1 = 40U;
  si0 *= si1;
  si1 = 11856U;
  si0 += si1;
  l1 = si0;
  si0 = 1984U;
  si1 = l1;
  circuit_f37(i, si0, si1);
  si0 = 1984U;
  circuit_f43(i, si0);
  L0:;
}

