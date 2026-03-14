#include "w2c2_base.h"

#include "circuit.h"

void circuit_f34(circuitInstance* i, U32 l0, U32 l1, U32 l2, U32 l3) {
  U32 l4 = 0;
  U32 l5 = 0;
  U32 si0, si1, si2;
  si0 = l0;
  si1 = 1696U;
  circuit_f4(i, si0, si1);
  si0 = l3;
  circuit_f31(i, si0);
  si0 = l2;
  l4 = si0;
  {
    L2:;
    {
      si0 = l4;
      si1 = 1U;
      si0 -= si1;
      l4 = si0;
      si0 = l1;
      si1 = l4;
      si0 += si1;
      si0 = i32_load8_u(i->m0, (U64)si0);
      l5 = si0;
      si0 = l3;
      si1 = l3;
      circuit_f25(i, si0, si1);
      si0 = l5;
      si1 = 128U;
      si0 = si0 >= si1;
      if (si0) {
        si0 = l5;
        si1 = 128U;
        si0 -= si1;
        l5 = si0;
        si0 = 1696U;
        si1 = l3;
        si2 = l3;
        circuit_f24(i, si0, si1, si2);
      }
      L3:;
      si0 = l3;
      si1 = l3;
      circuit_f25(i, si0, si1);
      si0 = l5;
      si1 = 64U;
      si0 = si0 >= si1;
      if (si0) {
        si0 = l5;
        si1 = 64U;
        si0 -= si1;
        l5 = si0;
        si0 = 1696U;
        si1 = l3;
        si2 = l3;
        circuit_f24(i, si0, si1, si2);
      }
      L4:;
      si0 = l3;
      si1 = l3;
      circuit_f25(i, si0, si1);
      si0 = l5;
      si1 = 32U;
      si0 = si0 >= si1;
      if (si0) {
        si0 = l5;
        si1 = 32U;
        si0 -= si1;
        l5 = si0;
        si0 = 1696U;
        si1 = l3;
        si2 = l3;
        circuit_f24(i, si0, si1, si2);
      }
      L5:;
      si0 = l3;
      si1 = l3;
      circuit_f25(i, si0, si1);
      si0 = l5;
      si1 = 16U;
      si0 = si0 >= si1;
      if (si0) {
        si0 = l5;
        si1 = 16U;
        si0 -= si1;
        l5 = si0;
        si0 = 1696U;
        si1 = l3;
        si2 = l3;
        circuit_f24(i, si0, si1, si2);
      }
      L6:;
      si0 = l3;
      si1 = l3;
      circuit_f25(i, si0, si1);
      si0 = l5;
      si1 = 8U;
      si0 = si0 >= si1;
      if (si0) {
        si0 = l5;
        si1 = 8U;
        si0 -= si1;
        l5 = si0;
        si0 = 1696U;
        si1 = l3;
        si2 = l3;
        circuit_f24(i, si0, si1, si2);
      }
      L7:;
      si0 = l3;
      si1 = l3;
      circuit_f25(i, si0, si1);
      si0 = l5;
      si1 = 4U;
      si0 = si0 >= si1;
      if (si0) {
        si0 = l5;
        si1 = 4U;
        si0 -= si1;
        l5 = si0;
        si0 = 1696U;
        si1 = l3;
        si2 = l3;
        circuit_f24(i, si0, si1, si2);
      }
      L8:;
      si0 = l3;
      si1 = l3;
      circuit_f25(i, si0, si1);
      si0 = l5;
      si1 = 2U;
      si0 = si0 >= si1;
      if (si0) {
        si0 = l5;
        si1 = 2U;
        si0 -= si1;
        l5 = si0;
        si0 = 1696U;
        si1 = l3;
        si2 = l3;
        circuit_f24(i, si0, si1, si2);
      }
      L9:;
      si0 = l3;
      si1 = l3;
      circuit_f25(i, si0, si1);
      si0 = l5;
      si1 = 1U;
      si0 = si0 >= si1;
      if (si0) {
        si0 = l5;
        si1 = 1U;
        si0 -= si1;
        l5 = si0;
        si0 = 1696U;
        si1 = l3;
        si2 = l3;
        circuit_f24(i, si0, si1, si2);
      }
      L10:;
      si0 = l4;
      si0 = !(si0);
      if (si0) {
        goto L1;
      }
      goto L2;
    }
  }
  L1:;
  L0:;
}

