{pkgs}: let
  src = ../..;
in
  pkgs.buildNpmPackage {
    name = "website";
    version = "0.0.0";
    inherit src;
    packageJSON = ../../package.json;
    npmDeps = pkgs.importNpmLock {
      npmRoot = src;
    };
    npmConfigHook = pkgs.importNpmLock.npmConfigHook;
    installPhase = "cp -r dist/ $out";
    nativeBuildInputs = [
      pkgs.typst
    ];
    TYPST_PACKAGE_PATH = "${pkgs.resumeTypstPlugins}";
    ASTRO_TELEMETRY_DISABLED = 1;
  }
