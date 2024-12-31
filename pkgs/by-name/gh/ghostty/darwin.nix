{
  pname,
  version,
  outputs,
  meta,
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
  makeWrapper,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit pname version outputs;

  src = fetchurl {
    url = "https://release.files.ghostty.org/${finalAttrs.version}/Ghostty.dmg";
    sha256 = "0qs64x4gn0lgqcvbyc118sfq268b7jinqwn4rmdj2b8ps75nh3s0";
  };

  nativeBuildInputs = [
    _7zz
    makeWrapper
  ];

  sourceRoot = ".";
  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mv Ghostty.app $out/Applications/
    makeWrapper $out/Applications/Ghostty.app/Contents/MacOS/ghostty $out/bin/ghostty

    runHook postInstall
  '';

  postFixup =
    let
      resources = "$out/Applications/Ghostty.app/Contents/Resources";
    in
    ''
      mkdir -p $man/share
      ln -s ${resources}/man $man/share/man

      mkdir -p $terminfo/share
      ln -s ${resources}/terminfo $terminfo/share/terminfo

      mkdir -p $shell_integration
      for folder in "${resources}/ghostty/shell-integration"/*; do
        ln -s $folder $shell_integration/$(basename "$folder")
      done

      mkdir -p $vim
      for folder in "${resources}/vim/vimfiles"/*; do
        ln -s $folder $vim/$(basename "$folder")
      done
    '';

  meta = meta // {
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
