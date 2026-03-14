pragma circom 2.0.0;

template ImageProof() {
    // PRIVATE inputs
    signal input hash;
    signal input timestamp;
    signal input nonce;
    signal input cameraId;

    // Intermediate signals (MUST be declared)
    signal temp1;
    signal temp2;

    // Output
    signal output proof;

    // Quadratic constraints only
    temp1 <== hash * timestamp;
    temp2 <== temp1 * cameraId;
    proof <== temp2 * nonce;
}

component main = ImageProof();
