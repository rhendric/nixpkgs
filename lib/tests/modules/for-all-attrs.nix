{ config, lib, ... }:
let
  inherit (lib.types) attrsOf bool int lazyAttrsOf listOf str submodule;
  testSubmodule = submodule {
    options = {
      x = lib.mkOption { type = listOf int; };
      y = lib.mkOption { type = int; };
      z = lib.mkOption { type = str; };
    };
  };
  testDefs = lib.mkMerge [
    {
      a.x = lib.mkBefore [ 0 ];
      b.y = lib.mkForce 3;
      b.z = "4";
    }
    (lib.modules.mkForAllAttrs {
      x = [ 1 ];
      y = 2;
    })
    (lib.modules.mkForAllAttrs (name: {
      z = lib.mkDefault name;
    }))
  ];
  expected = {
    a = {
      x = [ 0 1 ];
      y = 2;
      z = "a";
    };
    b = {
      x = [ 1 ];
      y = 3;
      z = "4";
    };
  };
in
{
  options = {
    test = lib.mkOption { type = attrsOf testSubmodule; };
    testLazy = lib.mkOption { type = lazyAttrsOf testSubmodule; };
    result = lib.mkOption { type = bool; };
  };

  config = {
    test = testDefs;
    testLazy = testDefs;
    result = lib.trace (builtins.toJSON config.test) (config.test == expected && config.testLazy == expected);
  };
}
