{
  description = "flake-compat";
  outputs = _: {
    lib = import ./.;
  };
}
