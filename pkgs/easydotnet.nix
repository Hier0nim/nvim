{
  lib,
  pkgs,
}:
let
  version = "3.4.24";
in
(pkgs.dotnetCorePackages.buildDotnetGlobalTool.override {
  fetchNupkg = args:
    (pkgs.dotnetCorePackages.fetchNupkg args).overrideAttrs (old: {
      # patch-nupkgs mistakes dncdbg debug sidecars for patchable executables.
      preFixup = ''
        debugSidecars="$NIX_BUILD_TOP/dncdbg-debug-sidecars"
        mkdir -p "$debugSidecars"
        while IFS= read -r -d "" debugSidecar; do
          relative="''${debugSidecar#"$out/"}"
          mkdir -p "$debugSidecars/$(dirname "$relative")"
          mv "$debugSidecar" "$debugSidecars/$relative"
        done < <(find "$out/share/nuget/packages/easydotnet/${version}/tools/dncdbg" -name dncdbg.dbg -print0)
        ${old.preFixup}
        while IFS= read -r -d "" debugSidecar; do
          relative="''${debugSidecar#"$debugSidecars/"}"
          mv "$debugSidecar" "$out/$relative"
        done < <(find "$debugSidecars" -type f -print0)
      '';
    });
}) {
  pname = "easydotnet";
  nugetName = "EasyDotnet";
  inherit version;
  executables = [ "dotnet-easydotnet" ];

  nugetSha256 = "0wcb687app4lhb94y6kxbxbk6jn8az5n85dk051nhvlpkbjhnpzl";

  postFixup = ''
    ln -sf dotnet-easydotnet "$out/bin/easydotnet"
  '';

  meta = with lib; {
    description = "Neovim helper tool for .NET development";
    homepage = "https://github.com/GustavEikaas/easy-dotnet.nvim";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
