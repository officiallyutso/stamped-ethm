#include "w2c2_base.h"

#include "circuit.h"

void circuit_f33(circuitInstance* i, U32 l0, U32 l1, U32 l2, U32 l3) {
  U32 si0, si1, si2;
  si0 = l1;
  si1 = l2;
  si2 = 1664U;
  circuit_f32(i, si0, si1, si2);
  si0 = 1664U;
  si1 = 1664U;
  circuit_f27(i, si0, si1);
  si0 = l0;
  si1 = 1664U;
  si2 = l3;
  circuit_f24(i, si0, si1, si2);
  L0:;
}

