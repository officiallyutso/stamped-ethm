#include "w2c2_base.h"

#include "circuit.h"

void circuit_f73(circuitInstance* i, U32 l0, U32 l1, U32 l2) {
  U32 si0, si1, si2;
  si0 = l2;
  si0 = circuit_f44(i, si0);
  if (si0) {
    si0 = 48U;
    si1 = l2;
    circuit_f45(i, si0, si1);
    si0 = 8U;
    si1 = 48U;
    si2 = 88U;
    circuit_f56(i, si0, si1, si2);
    si0 = 8U;
    si0 = i32_load(i->m0, (U64)si0);
    if (si0) {
      si0 = l0;
      si1 = l1;
      si2 = 48U;
      si2 = circuit_f47(i, si2);
      circuit_f70(i, si0, si1, si2);
    } else {
      si0 = l0;
      circuit_f5(i, si0);
    }
    L2:;
  } else {
    si0 = 8U;
    si1 = l2;
    si2 = 88U;
    circuit_f56(i, si0, si1, si2);
    si0 = 8U;
    si0 = i32_load(i->m0, (U64)si0);
    if (si0) {
      si0 = l0;
      si1 = l1;
      si2 = l2;
      si2 = circuit_f47(i, si2);
      circuit_f71(i, si0, si1, si2);
    } else {
      si0 = l0;
      circuit_f5(i, si0);
    }
    L3:;
  }
  L1:;
  L0:;
}

