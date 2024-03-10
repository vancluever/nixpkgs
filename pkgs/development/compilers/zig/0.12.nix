{ lib
, stdenv
, fetchzip
, fetchFromGitHub
, cmake
, llvmPackages
, libxml2
, zlib
, coreutils
, callPackage
}@args:

import ./generic.nix args {
  version = "0.12.0";

  src = fetchzip {
    url = "https://ziglang.org/builds/zig-0.12.0-dev.3192+e2cbbd0c2.tar.xz";
    hash = "sha256-6Lo9ABkXr8r6ROSBaRfDysE8la11xgjnlTIQkR4OTXA=";
  };

  outputs = [ "out" "doc" ];

  cmakeFlags = [
    # file RPATH_CHANGE could not write new RPATH
    "-DCMAKE_SKIP_BUILD_RPATH=ON"

    # always link against static build of LLVM
    "-DZIG_STATIC_LLVM=ON"

    # ensure determinism in the compiler build
    "-DZIG_TARGET_MCPU=baseline"
  ];

  postBuild = ''
    stage3/bin/zig run ../tools/docgen.zig -- ../doc/langref.html.in langref.html --zig $PWD/stage3/bin/zig --skip-code-tests
  '';

  postInstall = ''
    install -Dm444 -t $doc/share/doc/zig-$version/html langref.html
  '';
}
