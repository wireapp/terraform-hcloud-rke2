let
  sources = import ./sources.nix;
  pkgs = import sources.nixpkgs {
    config = { };
    overlays = [ (import ./overlay.nix) ];
  };
  profileEnv = pkgs.writeTextFile {
    name = "profile-env";
    destination = "/.profile";
    # This gets sourced by direnv. Set NIX_PATH, so `nix-shell` uses the same nixpkgs as here.
    text = ''
      export NIX_PATH=nixpkgs=${toString pkgs.path}
    '';
  };
in
{
  inherit pkgs;

  env = pkgs.buildEnv {
    name = "dev-env";
    paths = [
      profileEnv
      (pkgs.terraform.withPlugins (p: [
        p.hcloud
        p.local
        p.null
        p.random
        p.tls
      ]))
    ];
  };
}
