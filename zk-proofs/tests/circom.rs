mopro_ffi::uniffi_setup!();

#[cfg(target_os = "macos")]
uniffi::build_foreign_language_testcases!("tests/bindings/circom/test_circuit.swift",);

uniffi::build_foreign_language_testcases!("tests/bindings/circom/test_circuit.kts",);
