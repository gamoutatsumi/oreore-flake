# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  aicommit2 = {
    pname = "aicommit2";
    version = "v2.1.5";
    src = fetchFromGitHub {
      owner = "tak-bro";
      repo = "aicommit2";
      rev = "v2.1.5";
      fetchSubmodules = false;
      sha256 = "sha256-/bl0Qo4y3rDdGXIKTdjC5wtbeW1NUaIMkw5uzSQ+8Dk=";
    };
  };
}
