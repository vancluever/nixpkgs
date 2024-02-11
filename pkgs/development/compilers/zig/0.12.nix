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
    url = "https://ziglang.org/builds/zig-0.12.0-dev.2701+d18f52197.tar.xz";
    hash = "sha256-h63lG7R4nw3Sg5T4lHco8I39lPQWzwmEYGiRcPLKlAM=";
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
