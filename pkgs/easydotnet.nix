{
  lib,
  pkgs,
}:

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
        done < <(find "$out/share/nuget/packages/easydotnet/3.4.18/tools/dncdbg" -name dncdbg.dbg -print0)
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
  version = "3.4.18";
  executables = [ "dotnet-easydotnet" ];

  nugetSha256 = "sha256-4XYodebDy5ijRNP9h4bK0K37yxLh6997KijRH3tWwlA=";

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
