{
  lib,
  pkgs,
}:

pkgs.dotnetCorePackages.buildDotnetGlobalTool {
  pname = "easydotnet";
  nugetName = "EasyDotnet";
  version = "2.7.5";
  executables = [ "dotnet-easydotnet" ];

  # Fill this in from the first Nix build; it pins the NuGet payload.
  nugetSha256 = "sha256-JXfpBf42E7IylJ/SRAJEu5smC57S0GWOQ+1tXOy+ujo=";

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
