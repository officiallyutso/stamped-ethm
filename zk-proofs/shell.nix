{ pkgs ? import <nixpkgs> {
  config.allowUnfree = true;
}}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    cmake
    gnumake
    gcc
    pkg-config
    openssl
    nodejs
    steam-run
  ];

  shellHook = ''
    export ANDROID_HOME=$HOME/Android/Sdk
    export ANDROID_NDK_HOME=$HOME/Android/Sdk/ndk/28.2.13676358
    export CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang
  '';

  # Host compilers (for non-Android builds)
  CC = "gcc";
  CXX = "g++";
}
