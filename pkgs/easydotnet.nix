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
    # Keep the selected SDK host and DOTNET_ROOT together; otherwise use the packaged pair.
    substituteInPlace "$out/bin/dotnet-easydotnet" \
      --replace-fail $'dotnetFromEnv\nexport DOTNET_ROOT=' '
        selectedRoot=""
        selectedDotnet=""
        sdkRootFor() {
            local host="$1" requested="''${2:-}" line sdkDir
            while IFS= read -r line; do
                if [[ "$line" =~ ^[^\[]+\ \[(.+)/sdk\]$ ]]; then
                    sdkDir="''${BASH_REMATCH[1]}/sdk"
                    if [[ -d "$sdkDir" && ( -z "$requested" || "$sdkDir" -ef "$requested/sdk" ) ]]; then
                        selectedRoot="''${sdkDir%/sdk}"
                        selectedDotnet="$host"
                        return 0
                    fi
                fi
            done < <("$host" --list-sdks 2>/dev/null)
            return 1
        }
        pathDotnet=$(command -v dotnet || true)
        if [[ -n "''${DOTNET_ROOT:-}" && -d "$DOTNET_ROOT/sdk" ]]; then
            if [[ -x "$DOTNET_ROOT/dotnet" ]]; then
                sdkRootFor "$DOTNET_ROOT/dotnet" "$DOTNET_ROOT" || true
            fi
            if [[ -z "$selectedRoot" && -n "$pathDotnet" ]]; then
                sdkRootFor "$pathDotnet" "$DOTNET_ROOT" || true
            fi
        fi
        if [[ -z "$selectedRoot" && -n "$pathDotnet" ]]; then
            sdkRootFor "$pathDotnet" || true
        fi
        if [[ -n "$selectedRoot" ]]; then
            export DOTNET_ROOT="$selectedRoot"
            PATH="$(dirname "$selectedDotnet"):$PATH"
        else
            export DOTNET_ROOT="${pkgs.dotnet-sdk}/share/dotnet"
            PATH="${pkgs.dotnet-sdk}/bin:$PATH"
        fi
        export PATH
        export DOTNET_ROOT='
    ln -sf dotnet-easydotnet "$out/bin/easydotnet"
  '';

  meta = with lib; {
    description = "Neovim helper tool for .NET development";
    homepage = "https://github.com/GustavEikaas/easy-dotnet.nvim";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
