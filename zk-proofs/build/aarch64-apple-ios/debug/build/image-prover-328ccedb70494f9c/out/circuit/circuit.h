#ifndef circuit_H
#define circuit_H

#ifdef __cplusplus
extern "C" {
#endif

#include "w2c2_base.h"

typedef struct circuitInstance {
  wasmModuleInstance common;
  wasmMemory* m0;
  wasmTable t0;
} circuitInstance;

  void circuit_runtime__exceptionHandler(void*, U32);

  void circuit_runtime__printErrorMessage(void*);

  void circuit_runtime__writeBufferMessage(void*);

  void circuit_runtime__showSharedRWMemory(void*);

void circuit_f4(circuitInstance*, U32, U32);

void circuit_f5(circuitInstance*, U32);

U32 circuit_f6(circuitInstance*, U32);

void circuit_f7(circuitInstance*, U32);

U32 circuit_f8(circuitInstance*, U32, U32);

U32 circuit_f9(circuitInstance*, U32, U32);

U32 circuit_f10(circuitInstance*, U32, U32);

U32 circuit_f11(circuitInstance*, U32, U32, U32);

U32 circuit_f12(circuitInstance*, U32, U32, U32);

void circuit_f13(circuitInstance*, U32, U32, U32);

void circuit_f14(circuitInstance*, U32, U32);

void circuit_f15(circuitInstance*, U32, U32);

void circuit_f16(circuitInstance*, U32, U64, U32);

void circuit_f17(circuitInstance*, U32, U64);

void circuit_f18(circuitInstance*, U32, U32, U32, U32);

void circuit_f19(circuitInstance*, U32, U32, U32);

void circuit_f20(circuitInstance*, U32, U32, U32);

void circuit_f21(circuitInstance*, U32, U32, U32);

void circuit_f22(circuitInstance*, U32, U32);

void circuit_f23(circuitInstance*, U32, U32);

void circuit_f24(circuitInstance*, U32, U32, U32);

void circuit_f25(circuitInstance*, U32, U32);

void circuit_f26(circuitInstance*, U32, U32);

void circuit_f27(circuitInstance*, U32, U32);

void circuit_f28(circuitInstance*, U32, U32);

U32 circuit_f29(circuitInstance*, U32);

void circuit_f30(circuitInstance*, U32, U32);

void circuit_f31(circuitInstance*, U32);

void circuit_f32(circuitInstance*, U32, U32, U32);

void circuit_f33(circuitInstance*, U32, U32, U32, U32);

void circuit_f34(circuitInstance*, U32, U32, U32, U32);

void circuit_f35(circuitInstance*, U32, U32);

U32 circuit_f36(circuitInstance*, U32);

void circuit_f37(circuitInstance*, U32, U32);

void circuit_f38(circuitInstance*, U32, U32, U32);

U32 circuit_f39(circuitInstance*, U32);

void circuit_f40(circuitInstance*, U32, U64);

void circuit_f41(circuitInstance*, U32);

void circuit_f42(circuitInstance*, U32);

void circuit_f43(circuitInstance*, U32);

U32 circuit_f44(circuitInstance*, U32);

void circuit_f45(circuitInstance*, U32, U32);

U32 circuit_f46(circuitInstance*, U32);

U32 circuit_f47(circuitInstance*, U32);

void circuit_f48(circuitInstance*, U32, U32, U32);

void circuit_f49(circuitInstance*, U32, U32, U32);

U32 circuit_f50(circuitInstance*, U32, U32);

U32 circuit_f51(circuitInstance*, U32, U32);

void circuit_f52(circuitInstance*, U32, U32, U32);

void circuit_f53(circuitInstance*, U32, U32, U32);

void circuit_f54(circuitInstance*, U32, U32, U32);

void circuit_f55(circuitInstance*, U32, U32, U32);

void circuit_f56(circuitInstance*, U32, U32, U32);

void circuit_f57(circuitInstance*, U32, U32, U32);

void circuit_f58(circuitInstance*, U32, U32, U32);

void circuit_f59(circuitInstance*, U32, U32, U32);

void circuit_f60(circuitInstance*, U32, U32, U32);

void circuit_f61(circuitInstance*, U32, U32);

void circuit_f62(circuitInstance*, U32, U32, U32);

void circuit_f63(circuitInstance*, U32, U32, U32);

U64 circuit_f64(circuitInstance*, U64, U64);

U64 circuit_f65(circuitInstance*, U64, U64);

U64 circuit_f66(circuitInstance*, U32, U32);

void circuit_f67(circuitInstance*, U32, U32, U32);

void circuit_f68(circuitInstance*, U32, U32, U32);

void circuit_f69(circuitInstance*, U32);

void circuit_f70(circuitInstance*, U32, U32, U32);

void circuit_f71(circuitInstance*, U32, U32, U32);

void circuit_f72(circuitInstance*, U32, U32, U32);

void circuit_f73(circuitInstance*, U32, U32, U32);

void circuit_f74(circuitInstance*, U32, U32, U32);

void circuit_f75(circuitInstance*, U32, U32, U32);

void circuit_f76(circuitInstance*, U32, U32, U32);

void circuit_f77(circuitInstance*, U32, U32, U32);

void circuit_f78(circuitInstance*, U32, U32, U32);

void circuit_f79(circuitInstance*, U32, U32, U32);

void circuit_f80(circuitInstance*, U32, U32);

void circuit_f81(circuitInstance*, U32, U32);

void circuit_f82(circuitInstance*, U32, U32, U32);

void circuit_f83(circuitInstance*, U32, U32, U32);

void circuit_f84(circuitInstance*, U32, U32);

U32 circuit_f85(circuitInstance*, U32, U32);

U32 circuit_f86(circuitInstance*);

U32 circuit_f87(circuitInstance*);

U32 circuit_f88(circuitInstance*);

U32 circuit_f89(circuitInstance*);

U32 circuit_f90(circuitInstance*, U32);

void circuit_f91(circuitInstance*, U32, U32);

U32 circuit_f92(circuitInstance*, U32);

void circuit_f93(circuitInstance*, U32);

U32 circuit_f94(circuitInstance*, U64);

U32 circuit_f95(circuitInstance*, U32);

void circuit_f96(circuitInstance*, U32, U32, U32);

U32 circuit_f97(circuitInstance*, U32, U32);

void circuit_f98(circuitInstance*);

U32 circuit_f99(circuitInstance*);

U32 circuit_f100(circuitInstance*);

U32 circuit_f101(circuitInstance*);

void circuit_f102(circuitInstance*, U32);

void circuit_f103(circuitInstance*, U32);

void circuit_f104(circuitInstance*, U32);

U32 circuit_f105(circuitInstance*);

void circuit_f106(circuitInstance*, U32, U32);

void circuit_f107(circuitInstance*, U32);

U32 circuit_f108(circuitInstance*, U32, U32);

U32 circuit_f109(circuitInstance*, U32, U32);

U32 circuit_f110(circuitInstance*, U32, U32);

U32 circuit_f111(circuitInstance*, U32, U32);

U32 circuit_f112(circuitInstance*, U32);

U32 circuit_f113(circuitInstance*, U32);

U32 circuit_f114(circuitInstance*, U32);

U32 circuit_f115(circuitInstance*, U32);

U32 circuit_f116(circuitInstance*, U32);

U32 circuit_f117(circuitInstance*, U32);

U32 circuit_f118(circuitInstance*, U32);

U32 circuit_f119(circuitInstance*, U32);

U32 circuit_f120(circuitInstance*, U32);

U32 circuit_f121(circuitInstance*, U32);

U32 circuit_f122(circuitInstance*, U32);

U32 circuit_f123(circuitInstance*, U32);

U32 circuit_f124(circuitInstance*, U32);

U32 circuit_f125(circuitInstance*, U32);

U32 circuit_f126(circuitInstance*, U32);

U32 circuit_f127(circuitInstance*, U32);

U32 circuit_f128(circuitInstance*, U32);

U32 circuit_f129(circuitInstance*, U32);

U32 circuit_f130(circuitInstance*, U32);

U32 circuit_f131(circuitInstance*, U32);

U32 circuit_f132(circuitInstance*, U32);

U32 circuit_f133(circuitInstance*, U32);

U32 circuit_f134(circuitInstance*, U32);

U32 circuit_f135(circuitInstance*, U32);

U32 circuit_f136(circuitInstance*, U32);

U32 circuit_f137(circuitInstance*, U32);

U32 circuit_f138(circuitInstance*, U32);

U32 circuit_f139(circuitInstance*, U32);

U32 circuit_f140(circuitInstance*, U32);

U32 circuit_f141(circuitInstance*, U32);

U32 circuit_f142(circuitInstance*, U32);

U32 circuit_f143(circuitInstance*, U32);

U32 circuit_f144(circuitInstance*, U32);

U32 circuit_f145(circuitInstance*, U32);

U32 circuit_f146(circuitInstance*, U32);

U32 circuit_f147(circuitInstance*, U32);

U32 circuit_f148(circuitInstance*, U32);

U32 circuit_f149(circuitInstance*, U32);

U32 circuit_f150(circuitInstance*, U32);

U32 circuit_f151(circuitInstance*, U32);

U32 circuit_f152(circuitInstance*, U32);

U32 circuit_f153(circuitInstance*, U32);

U32 circuit_f154(circuitInstance*, U32);

U32 circuit_f155(circuitInstance*, U32);

U32 circuit_f156(circuitInstance*, U32);

U32 circuit_f157(circuitInstance*, U32);

U32 circuit_f158(circuitInstance*, U32);

U32 circuit_f159(circuitInstance*, U32);

U32 circuit_f160(circuitInstance*, U32);

U32 circuit_f161(circuitInstance*, U32);

U32 circuit_f162(circuitInstance*, U32);

U32 circuit_f163(circuitInstance*, U32);

U32 circuit_f164(circuitInstance*, U32);

U32 circuit_f165(circuitInstance*, U32);

U32 circuit_f166(circuitInstance*, U32);

U32 circuit_f167(circuitInstance*, U32);

U32 circuit_f168(circuitInstance*, U32);

U32 circuit_f169(circuitInstance*, U32);

U32 circuit_f170(circuitInstance*, U32);

U32 circuit_f171(circuitInstance*, U32);

U32 circuit_f172(circuitInstance*, U32);

U32 circuit_f173(circuitInstance*, U32);

U32 circuit_f174(circuitInstance*, U32);

U32 circuit_f175(circuitInstance*, U32);

U32 circuit_f176(circuitInstance*, U32);

U32 circuit_f177(circuitInstance*, U32);

U32 circuit_f178(circuitInstance*, U32);

U32 circuit_f179(circuitInstance*, U32);

U32 circuit_f180(circuitInstance*, U32);

U32 circuit_f181(circuitInstance*, U32);

U32 circuit_f182(circuitInstance*, U32);

U32 circuit_f183(circuitInstance*, U32);

U32 circuit_f184(circuitInstance*, U32);

U32 circuit_f185(circuitInstance*, U32);

U32 circuit_f186(circuitInstance*, U32);

U32 circuit_f187(circuitInstance*, U32);

U32 circuit_f188(circuitInstance*, U32);

U32 circuit_f189(circuitInstance*, U32);

U32 circuit_f190(circuitInstance*, U32);

U32 circuit_f191(circuitInstance*, U32);

U32 circuit_f192(circuitInstance*, U32);

U32 circuit_f193(circuitInstance*, U32);

U32 circuit_f194(circuitInstance*, U32);

U32 circuit_f195(circuitInstance*, U32);

U32 circuit_f196(circuitInstance*, U32);

U32 circuit_f197(circuitInstance*, U32);

U32 circuit_f198(circuitInstance*, U32);

U32 circuit_f199(circuitInstance*, U32);

U32 circuit_f200(circuitInstance*, U32);

U32 circuit_f201(circuitInstance*, U32);

U32 circuit_f202(circuitInstance*, U32);

U32 circuit_f203(circuitInstance*, U32);

U32 circuit_f204(circuitInstance*, U32);

U32 circuit_f205(circuitInstance*, U32);

U32 circuit_f206(circuitInstance*, U32);

U32 circuit_f207(circuitInstance*, U32);

U32 circuit_f208(circuitInstance*, U32);

U32 circuit_f209(circuitInstance*, U32);

U32 circuit_f210(circuitInstance*, U32);

U32 circuit_f211(circuitInstance*, U32);

U32 circuit_f212(circuitInstance*, U32);

U32 circuit_f213(circuitInstance*, U32);

U32 circuit_f214(circuitInstance*, U32);

U32 circuit_f215(circuitInstance*, U32);

U32 circuit_f216(circuitInstance*, U32);

U32 circuit_f217(circuitInstance*, U32);

U32 circuit_f218(circuitInstance*, U32);

U32 circuit_f219(circuitInstance*, U32);

U32 circuit_f220(circuitInstance*, U32);

U32 circuit_f221(circuitInstance*, U32);

U32 circuit_f222(circuitInstance*, U32);

U32 circuit_f223(circuitInstance*, U32);

U32 circuit_f224(circuitInstance*, U32);

U32 circuit_f225(circuitInstance*, U32);

U32 circuit_f226(circuitInstance*, U32);

U32 circuit_f227(circuitInstance*, U32);

U32 circuit_f228(circuitInstance*, U32);

U32 circuit_f229(circuitInstance*, U32);

U32 circuit_f230(circuitInstance*, U32);

U32 circuit_f231(circuitInstance*, U32);

U32 circuit_f232(circuitInstance*, U32);

U32 circuit_f233(circuitInstance*, U32);

U32 circuit_f234(circuitInstance*, U32);

U32 circuit_f235(circuitInstance*, U32);

U32 circuit_f236(circuitInstance*, U32);

U32 circuit_f237(circuitInstance*, U32);

U32 circuit_f238(circuitInstance*, U32);

U32 circuit_f239(circuitInstance*, U32);

U32 circuit_f240(circuitInstance*, U32);

U32 circuit_f241(circuitInstance*, U32);

U32 circuit_f242(circuitInstance*, U32);

U32 circuit_f243(circuitInstance*, U32);

U32 circuit_f244(circuitInstance*, U32);

U32 circuit_f245(circuitInstance*, U32);

U32 circuit_f246(circuitInstance*, U32);

U32 circuit_f247(circuitInstance*, U32);

U32 circuit_f248(circuitInstance*, U32);

U32 circuit_f249(circuitInstance*, U32);

U32 circuit_f250(circuitInstance*, U32);

U32 circuit_f251(circuitInstance*, U32);

U32 circuit_f252(circuitInstance*, U32);

U32 circuit_f253(circuitInstance*, U32);

U32 circuit_f254(circuitInstance*, U32);

U32 circuit_f255(circuitInstance*, U32);

U32 circuit_f256(circuitInstance*, U32);

U32 circuit_f257(circuitInstance*, U32);

U32 circuit_f258(circuitInstance*, U32);

U32 circuit_f259(circuitInstance*, U32);

U32 circuit_f260(circuitInstance*, U32);

U32 circuit_f261(circuitInstance*, U32);

U32 circuit_f262(circuitInstance*, U32);

U32 circuit_f263(circuitInstance*, U32);

U32 circuit_f264(circuitInstance*, U32);

U32 circuit_f265(circuitInstance*, U32);

U32 circuit_f266(circuitInstance*, U32);

U32 circuit_f267(circuitInstance*, U32);

U32 circuit_f268(circuitInstance*, U32);

U32 circuit_f269(circuitInstance*, U32);

U32 circuit_f270(circuitInstance*, U32);

U32 circuit_f271(circuitInstance*, U32);

U32 circuit_f272(circuitInstance*, U32);

U32 circuit_f273(circuitInstance*, U32);

U32 circuit_f274(circuitInstance*, U32);

U32 circuit_f275(circuitInstance*, U32);

U32 circuit_f276(circuitInstance*, U32);

U32 circuit_f277(circuitInstance*, U32);

U32 circuit_f278(circuitInstance*, U32);

U32 circuit_f279(circuitInstance*, U32);

U32 circuit_f280(circuitInstance*, U32);

U32 circuit_f281(circuitInstance*, U32);

U32 circuit_f282(circuitInstance*, U32);

U32 circuit_f283(circuitInstance*, U32);

U32 circuit_f284(circuitInstance*, U32);

U32 circuit_f285(circuitInstance*, U32);

U32 circuit_f286(circuitInstance*, U32);

U32 circuit_f287(circuitInstance*, U32);

U32 circuit_f288(circuitInstance*, U32);

U32 circuit_f289(circuitInstance*, U32);

U32 circuit_f290(circuitInstance*, U32);

U32 circuit_f291(circuitInstance*, U32);

U32 circuit_f292(circuitInstance*, U32);

U32 circuit_f293(circuitInstance*, U32);

U32 circuit_f294(circuitInstance*, U32);

U32 circuit_f295(circuitInstance*, U32);

U32 circuit_f296(circuitInstance*, U32);

U32 circuit_f297(circuitInstance*, U32);

U32 circuit_f298(circuitInstance*, U32);

U32 circuit_f299(circuitInstance*, U32);

U32 circuit_f300(circuitInstance*, U32);

U32 circuit_f301(circuitInstance*, U32);

U32 circuit_f302(circuitInstance*, U32);

U32 circuit_f303(circuitInstance*, U32);

U32 circuit_f304(circuitInstance*, U32);

U32 circuit_f305(circuitInstance*, U32);

U32 circuit_f306(circuitInstance*, U32);

U32 circuit_f307(circuitInstance*, U32);

U32 circuit_f308(circuitInstance*, U32);

U32 circuit_f309(circuitInstance*, U32);

U32 circuit_f310(circuitInstance*, U32);

U32 circuit_f311(circuitInstance*, U32);

U32 circuit_f312(circuitInstance*, U32);

U32 circuit_f313(circuitInstance*, U32);

U32 circuit_f314(circuitInstance*, U32);

U32 circuit_f315(circuitInstance*, U32);

U32 circuit_f316(circuitInstance*, U32);

U32 circuit_f317(circuitInstance*, U32);

U32 circuit_f318(circuitInstance*, U32);

U32 circuit_f319(circuitInstance*, U32);

U32 circuit_f320(circuitInstance*, U32);

U32 circuit_f321(circuitInstance*, U32);

U32 circuit_f322(circuitInstance*, U32);

U32 circuit_f323(circuitInstance*, U32);

U32 circuit_f324(circuitInstance*, U32);

U32 circuit_f325(circuitInstance*, U32);

U32 circuit_f326(circuitInstance*, U32);

U32 circuit_f327(circuitInstance*, U32);

U32 circuit_f328(circuitInstance*, U32);

U32 circuit_f329(circuitInstance*, U32);

U32 circuit_f330(circuitInstance*, U32);

U32 circuit_f331(circuitInstance*, U32);

U32 circuit_f332(circuitInstance*, U32);

U32 circuit_f333(circuitInstance*, U32);

U32 circuit_f334(circuitInstance*, U32);

U32 circuit_f335(circuitInstance*, U32);

U32 circuit_f336(circuitInstance*, U32);

U32 circuit_f337(circuitInstance*, U32);

U32 circuit_f338(circuitInstance*, U32);

U32 circuit_f339(circuitInstance*, U32);

U32 circuit_f340(circuitInstance*, U32);

U32 circuit_f341(circuitInstance*, U32);

U32 circuit_f342(circuitInstance*, U32);

U32 circuit_f343(circuitInstance*, U32);

U32 circuit_f344(circuitInstance*, U32);

U32 circuit_f345(circuitInstance*, U32);

U32 circuit_f346(circuitInstance*, U32);

U32 circuit_f347(circuitInstance*, U32);

U32 circuit_f348(circuitInstance*, U32);

U32 circuit_f349(circuitInstance*, U32);

U32 circuit_f350(circuitInstance*, U32);

U32 circuit_f351(circuitInstance*, U32);

U32 circuit_f352(circuitInstance*, U32);

U32 circuit_f353(circuitInstance*, U32);

U32 circuit_f354(circuitInstance*, U32);

U32 circuit_f355(circuitInstance*, U32);

U32 circuit_f356(circuitInstance*, U32);

U32 circuit_f357(circuitInstance*, U32);

U32 circuit_f358(circuitInstance*, U32);

U32 circuit_f359(circuitInstance*, U32);

U32 circuit_f360(circuitInstance*, U32);

U32 circuit_f361(circuitInstance*, U32);

U32 circuit_f362(circuitInstance*, U32);

U32 circuit_f363(circuitInstance*, U32);

U32 circuit_f364(circuitInstance*, U32);

U32 circuit_f365(circuitInstance*, U32);

U32 circuit_f366(circuitInstance*, U32);

U32 circuit_f367(circuitInstance*, U32);

U32 circuit_f368(circuitInstance*, U32);

U32 circuit_f369(circuitInstance*, U32);

U32 circuit_f370(circuitInstance*, U32);

U32 circuit_f371(circuitInstance*, U32);

U32 circuit_f372(circuitInstance*, U32);

U32 circuit_f373(circuitInstance*, U32);

U32 circuit_f374(circuitInstance*, U32);

U32 circuit_f375(circuitInstance*, U32);

U32 circuit_f376(circuitInstance*, U32);

U32 circuit_f377(circuitInstance*, U32);

U32 circuit_f378(circuitInstance*, U32);

U32 circuit_f379(circuitInstance*, U32);

U32 circuit_f380(circuitInstance*, U32);

U32 circuit_f381(circuitInstance*, U32);

U32 circuit_f382(circuitInstance*, U32);

U32 circuit_f383(circuitInstance*, U32);

U32 circuit_f384(circuitInstance*, U32);

U32 circuit_f385(circuitInstance*, U32);

U32 circuit_f386(circuitInstance*, U32);

U32 circuit_f387(circuitInstance*, U32);

U32 circuit_f388(circuitInstance*, U32);

U32 circuit_f389(circuitInstance*, U32);

U32 circuit_f390(circuitInstance*, U32);

U32 circuit_f391(circuitInstance*, U32);

U32 circuit_f392(circuitInstance*, U32);

U32 circuit_f393(circuitInstance*, U32);

U32 circuit_f394(circuitInstance*, U32);

U32 circuit_f395(circuitInstance*, U32);

U32 circuit_f396(circuitInstance*, U32);

U32 circuit_f397(circuitInstance*, U32);

U32 circuit_f398(circuitInstance*, U32);

U32 circuit_f399(circuitInstance*, U32);

U32 circuit_f400(circuitInstance*, U32);

U32 circuit_f401(circuitInstance*, U32);

U32 circuit_f402(circuitInstance*, U32);

U32 circuit_f403(circuitInstance*, U32);

wasmMemory* circuit_memory(circuitInstance* i);

U32 circuit_getVersion(circuitInstance* i);

U32 circuit_getMinorVersion(circuitInstance* i);

U32 circuit_getPatchVersion(circuitInstance* i);

U32 circuit_getSharedRWMemoryStart(circuitInstance* i);

U32 circuit_readSharedRWMemory(circuitInstance* i, U32 l0);

void circuit_writeSharedRWMemory(circuitInstance* i, U32 l0, U32 l1);

void circuit_init(circuitInstance* i, U32 l0);

void circuit_setInputSignal(circuitInstance* i, U32 l0, U32 l1, U32 l2);

U32 circuit_getInputSignalSize(circuitInstance* i, U32 l0, U32 l1);

void circuit_getRawPrime(circuitInstance* i);

U32 circuit_getFieldNumLen32(circuitInstance* i);

U32 circuit_getWitnessSize(circuitInstance* i);

U32 circuit_getInputSize(circuitInstance* i);

void circuit_getWitness(circuitInstance* i, U32 l0);

U32 circuit_getMessageChar(circuitInstance* i);

void circuitInstantiate(circuitInstance* instance, void* resolve(const char* module, const char* name));

void circuitFreeInstance(circuitInstance* instance);

#ifdef __cplusplus
}
#endif

#endif /* circuit_H */

