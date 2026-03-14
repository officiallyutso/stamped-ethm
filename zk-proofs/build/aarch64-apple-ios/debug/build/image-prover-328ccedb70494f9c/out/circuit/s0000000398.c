#include "w2c2_base.h"

#include "circuit.h"

U32 circuit_f50(circuitInstance* i, U32 l0, U32 l1) {
  U32 si0, si1, si2;
  U64 sj1;
  si0 = l0;
  si0 = i32_load8_u(i->m0, (U64)si0 + 7U);
  si1 = 128U;
  si0 &= si1;
  if (si0) {
    si0 = l1;
    si0 = i32_load8_u(i->m0, (U64)si0 + 7U);
    si1 = 128U;
    si0 &= si1;
    if (si0) {
    } else {
      si0 = l1;
      si1 = 8U;
      si0 += si1;
      si1 = l1;
      sj1 = i64_load32_s(i->m0, (U64)si1);
      circuit_f40(i, si0, sj1);
      si0 = l1;
      si1 = -2147483648U;
      i32_store(i->m0, (U64)si0 + 4U, si1);
    }
    L2:;
    si0 = l0;
    si0 = i32_load8_u(i->m0, (U64)si0 + 7U);
    si1 = 64U;
    si0 &= si1;
    if (si0) {
      si0 = l1;
      si0 = i32_load8_u(i->m0, (U64)si0 + 7U);
      si1 = 64U;
      si0 &= si1;
      if (si0) {
        si0 = l0;
        si1 = 8U;
        si0 += si1;
        si1 = l1;
        si2 = 8U;
        si1 += si2;
        si0 = circuit_f8(i, si0, si1);
        if (si0) {
          si0 = 1U;
          goto L0;
        } else {
          si0 = 0U;
          goto L0;
        }
        L5:;
      } else {
        si0 = l0;
        circuit_f42(i, si0);
        si0 = l0;
        si1 = 8U;
        si0 += si1;
        si1 = l1;
        si2 = 8U;
        si1 += si2;
        si0 = circuit_f8(i, si0, si1);
        if (si0) {
          si0 = 1U;
          goto L0;
        } else {
          si0 = 0U;
          goto L0;
        }
        L6:;
      }
      L4:;
    } else {
      si0 = l1;
      si0 = i32_load8_u(i->m0, (U64)si0 + 7U);
      si1 = 64U;
      si0 &= si1;
      if (si0) {
        si0 = l1;
        circuit_f42(i, si0);
        si0 = l0;
        si1 = 8U;
        si0 += si1;
        si1 = l1;
        si2 = 8U;
        si1 += si2;
        si0 = circuit_f8(i, si0, si1);
        if (si0) {
          si0 = 1U;
          goto L0;
        } else {
          si0 = 0U;
          goto L0;
        }
        L8:;
      } else {
        si0 = l0;
        si1 = 8U;
        si0 += si1;
        si1 = l1;
        si2 = 8U;
        si1 += si2;
        si0 = circuit_f8(i, si0, si1);
        if (si0) {
          si0 = 1U;
          goto L0;
        } else {
          si0 = 0U;
          goto L0;
        }
        L9:;
      }
      L7:;
    }
    L3:;
  } else {
    si0 = l1;
    si0 = i32_load8_u(i->m0, (U64)si0 + 7U);
    si1 = 128U;
    si0 &= si1;
    if (si0) {
      si0 = l0;
      si0 = i32_load8_u(i->m0, (U64)si0 + 7U);
      si1 = 128U;
      si0 &= si1;
      if (si0) {
      } else {
        si0 = l0;
        si1 = 8U;
        si0 += si1;
        si1 = l0;
        sj1 = i64_load32_s(i->m0, (U64)si1);
        circuit_f40(i, si0, sj1);
        si0 = l0;
        si1 = -2147483648U;
        i32_store(i->m0, (U64)si0 + 4U, si1);
      }
      L11:;
      si0 = l0;
      si0 = i32_load8_u(i->m0, (U64)si0 + 7U);
      si1 = 64U;
      si0 &= si1;
      if (si0) {
        si0 = l1;
        si0 = i32_load8_u(i->m0, (U64)si0 + 7U);
        si1 = 64U;
        si0 &= si1;
        if (si0) {
          si0 = l0;
          si1 = 8U;
          si0 += si1;
          si1 = l1;
          si2 = 8U;
          si1 += si2;
          si0 = circuit_f8(i, si0, si1);
          if (si0) {
            si0 = 1U;
            goto L0;
          } else {
            si0 = 0U;
            goto L0;
          }
          L14:;
        } else {
          si0 = l0;
          circuit_f42(i, si0);
          si0 = l0;
          si1 = 8U;
          si0 += si1;
          si1 = l1;
          si2 = 8U;
          si1 += si2;
          si0 = circuit_f8(i, si0, si1);
          if (si0) {
            si0 = 1U;
            goto L0;
          } else {
            si0 = 0U;
            goto L0;
          }
          L15:;
        }
        L13:;
      } else {
        si0 = l1;
        si0 = i32_load8_u(i->m0, (U64)si0 + 7U);
        si1 = 64U;
        si0 &= si1;
        if (si0) {
          si0 = l1;
          circuit_f42(i, si0);
          si0 = l0;
          si1 = 8U;
          si0 += si1;
          si1 = l1;
          si2 = 8U;
          si1 += si2;
          si0 = circuit_f8(i, si0, si1);
          if (si0) {
            si0 = 1U;
            goto L0;
          } else {
            si0 = 0U;
            goto L0;
          }
          L17:;
        } else {
          si0 = l0;
          si1 = 8U;
          si0 += si1;
          si1 = l1;
          si2 = 8U;
          si1 += si2;
          si0 = circuit_f8(i, si0, si1);
          if (si0) {
            si0 = 1U;
            goto L0;
          } else {
            si0 = 0U;
            goto L0;
          }
          L18:;
        }
        L16:;
      }
      L12:;
    } else {
      si0 = l0;
      si0 = i32_load(i->m0, (U64)si0);
      si1 = l1;
      si1 = i32_load(i->m0, (U64)si1);
      si0 = si0 == si1;
      if (si0) {
        si0 = 1U;
        goto L0;
      } else {
        si0 = 0U;
        goto L0;
      }
      L19:;
    }
    L10:;
  }
  L1:;
  si0 = 0U;
  L0:;
  return si0;
}

