pragma circom 2.1.6;

include "circomlib/circuits/poseidon.circom";
include "circomlib/circuits/bitify.circom";

template ImageProof() {

    // ===== PUBLIC INPUTS =====
    signal input outputHash;
    signal input pipelineHash;
    signal input nullifier;

    // ===== PRIVATE INPUTS =====
    signal input imageHash;
    signal input embedKey;
    signal input payload64;
    signal input metadataHash;

    // ---- Enforce payload is 64-bit ----
    component payloadBits = Num2Bits(64);
    payloadBits.in <== payload64;

    // ---- embedCommit = Poseidon(embedKey, payload64) ----
    component embedPoseidon = Poseidon(2);
    embedPoseidon.inputs[0] <== embedKey;
    embedPoseidon.inputs[1] <== payload64;
    signal embedCommit <== embedPoseidon.out;

    // ---- outputHash recomputation ----
    component pipelinePoseidon = Poseidon(5);
    pipelinePoseidon.inputs[0] <== pipelineHash;
    pipelinePoseidon.inputs[1] <== imageHash;
    pipelinePoseidon.inputs[2] <== embedCommit;
    pipelinePoseidon.inputs[3] <== metadataHash;
    pipelinePoseidon.inputs[4] <== nullifier;

    // ---- Constraint ----
    outputHash === pipelinePoseidon.out;
}

component main = ImageProof();
