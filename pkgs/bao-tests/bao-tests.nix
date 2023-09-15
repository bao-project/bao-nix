{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
    pname = "bao-tests";
    version = "1.0.0";

    src = fetchFromGitHub {
        owner = "bao-project";
        repo = "bao-tests";
        rev = "1a80c04a08e761fb9f88b4fa29ccce814fdd2d91"; # branch: master
        sha256 = "sha256-gX/d2dIHqRNvV9PriG9ZnDoezxXVgpx6nlE3odPwLAg=";
    };

    dontBuild = true;
    
    installPhase = ''
        mkdir -p $out
        cp -r $src/* $out
    '';

}


