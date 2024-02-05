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
    url = "https://ziglang.org/builds/zig-0.12.0-dev.2587+a1b607acb.tar.xz";
    hash = "sha256-ubXz1WiqPzLNWMQJ0mq9Qe8LSJc4oSwUEHY6h2coZCM=";
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
