# This file was generated by nvfetcher, please do not modify it manually.
{
  fetchFromGitHub,
}:
{
  aicommit2 = {
    pname = "aicommit2";
    version = "v2.1.11";
    src = fetchFromGitHub {
      owner = "tak-bro";
      repo = "aicommit2";
      rev = "v2.1.11";
      fetchSubmodules = false;
      sha256 = "sha256-Q7VTcCtq4ix5evrLSUocNmzGX5brBfkRTn/0Jh8Tq9Y=";
    };
  };
  tinty = {
    pname = "tinty";
    version = "v0.23.0";
    src = fetchFromGitHub {
      owner = "tinted-theming";
      repo = "tinty";
      rev = "v0.23.0";
      fetchSubmodules = false;
      sha256 = "sha256-5KrXvE+RLkypqKg01Os09XGxrqv0fCMkeSD//E5WrZc=";
    };
  };
}
