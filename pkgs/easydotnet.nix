{
  lib,
  pkgs,
}:

pkgs.dotnetCorePackages.buildDotnetGlobalTool {
  pname = "easydotnet";
  nugetName = "EasyDotnet";
  version = "3.1.3";
  executables = [ "dotnet-easydotnet" ];

  # Fill this in from the first Nix build; it pins the NuGet payload.
  nugetSha256 = "sha256-MasiP8L7t/wvUX2azAqG9DxLezr2nNl2DA0ZUKbnPD8=";

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
