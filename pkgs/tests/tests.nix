{ stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
    pname = "tests";
    version = "1.0.0";

    src = ../../../src;

    dontBuild = true;
    
    installPhase = ''
        mkdir -p $out
        cp -r $src/* $out
    '';

}

