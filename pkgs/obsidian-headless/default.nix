{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nodejs_22,
  pkg-config,
  python3,
  sqlite,
}:
buildNpmPackage rec {
  pname = "obsidian-headless";
  version = "0.0.12";

  src = fetchFromGitHub {
    owner = "obsidianmd";
    repo = "obsidian-headless";
    rev = version;
    hash = "sha256-5GXO9FVATs8qlO6aQpOOtPYgPAb30lDxjM4VlfEAPCk=";
  };

  npmDepsHash = "sha256-uXNgBQ02JeG741W4F5I7TXwsd6MBPFa6w6BFO1fmM+4=";

  nodejs = nodejs_22;

  nativeBuildInputs = [
    pkg-config
    python3
  ];

  buildInputs = [sqlite];

  # Upstream commits pnpm-lock.yaml, but buildNpmPackage requires package-lock.json.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  meta = {
    description = "Headless client for Obsidian services";
    homepage = "https://github.com/obsidianmd/obsidian-headless";
    license = lib.licenses.unfree;
    mainProgram = "ob";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
