{
  lib,
  pkgs,
}:

pkgs.dotnetCorePackages.buildDotnetGlobalTool {
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
