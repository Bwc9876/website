{
  packages = pkgs:
    with pkgs; [
      nodejs_24
      (typst.withPackages (p: [p.basic-resume]))
      typstyle
      tinymist
    ];
}
