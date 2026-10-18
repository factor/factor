{
  pkgs,
  name ? "factor-${pkgs.stdenv.hostPlatform.system}-runtime",
  withUI ? true,
  withTests ? false,
  uiBackend ? "gtk3",
  softwareRendering ? false,
}:

assert pkgs.stdenv.hostPlatform.isLinux;
assert builtins.elem uiBackend [ "gtk3" "gtk4" ];
assert !softwareRendering || (withUI && withTests && uiBackend == "gtk3");
assert !softwareRendering || pkgs.mesa.version == "26.1.8";

let
  isS390Cross = packageSet:
    packageSet.stdenv.buildPlatform != packageSet.stdenv.hostPlatform
    && packageSet.stdenv.hostPlatform.config == "s390x-unknown-linux-gnu";

  # libdrm independently enables target Valgrind. Its s390 build uses
  # instructions outside the default assembler level, while Factor's
  # softpipe runtime neither runs nor links Valgrind.
  drmPkgs = if softwareRendering && isS390Cross pkgs then pkgs.extend (_final: prev: {
    libdrm = if isS390Cross prev then prev.libdrm.overrideAttrs (old: let
      nameOf = input: input.name or input.pname or "";
    in {
      buildInputs = builtins.filter
        (input: !(prev.lib.hasInfix "valgrind" (nameOf input)))
        old.buildInputs;
      mesonFlags = builtins.filter
        (flag: !(prev.lib.hasPrefix "-Dvalgrind=" flag))
        old.mesonFlags ++ [ "-Dvalgrind=disabled" ];
    }) else prev.libdrm;
  }) else pkgs;

  isBigEndianGirBrokenCross = packageSet:
    packageSet.stdenv.buildPlatform != packageSet.stdenv.hostPlatform
    && builtins.elem packageSet.stdenv.hostPlatform.config [
      "powerpc64-unknown-linux-gnuabielfv1"
      "s390x-unknown-linux-gnu"
    ];

  # The generic cross-introspection path emits little-endian helper binaries
  # which reject genuine MSB libraries. Factor consumes these C ABIs, not GIR.
  # Keep every choice based on prev so native build packages remain untouched.
  girPkgs = if isBigEndianGirBrokenCross drmPkgs then drmPkgs.extend (_final: prev: {
    gdk-pixbuf = if isBigEndianGirBrokenCross prev
      then prev.gdk-pixbuf.override { withIntrospection = false; }
      else prev.gdk-pixbuf;
    harfbuzz = if isBigEndianGirBrokenCross prev
      then prev.harfbuzz.override { withIntrospection = false; }
      else prev.harfbuzz;
    pango = if isBigEndianGirBrokenCross prev
      then prev.pango.override { withIntrospection = false; }
      else prev.pango;
    gtk3 = if isBigEndianGirBrokenCross prev
      then prev.gtk3.override { withIntrospection = false; }
      else prev.gtk3;
    gtk2 = if isBigEndianGirBrokenCross prev then prev.gtk2.overrideAttrs (old: {
      configureFlags = (old.configureFlags or [ ]) ++ [ "--disable-introspection" ];
    }) else prev.gtk2;
    librsvg = if isBigEndianGirBrokenCross prev
      then (prev.librsvg.override { withIntrospection = false; }).overrideAttrs (_old: {
        postInstall = "";
      })
      else prev.librsvg;
    at-spi2-core = if isBigEndianGirBrokenCross prev
      then prev.at-spi2-core.override { withIntrospection = false; }
      else prev.at-spi2-core;
  }) else drmPkgs;

  # linux-pam 1.7.2 does not create its declared man output when cross-built.
  # This remains after the target-specific overlay and retains the inner guard.
  runtimePkgs = if girPkgs.stdenv.buildPlatform != girPkgs.stdenv.hostPlatform
    && girPkgs.linux-pam.version == "1.7.2"
    then girPkgs.extend (_final: prev: {
      linux-pam = if prev.stdenv.buildPlatform != prev.stdenv.hostPlatform
        && prev.linux-pam.version == "1.7.2"
        then prev.linux-pam.overrideAttrs (old: {
          outputs = builtins.filter (output: output != "man") old.outputs;
        })
        else prev.linux-pam;
    })
    else girPkgs;
  inherit (runtimePkgs) lib;
  linuxUI = withUI && runtimePkgs.stdenv.hostPlatform.isLinux;
  gtk = if uiBackend == "gtk3" then runtimePkgs.gtk3 else runtimePkgs.gtk4;

  librsvgRuntime = runtimePkgs.runCommand
    "librsvg-${runtimePkgs.stdenv.hostPlatform.system}-runtime" { } ''
      mkdir -p "$out"
      cp -r --no-preserve=mode,ownership,timestamps ${runtimePkgs.librsvg}/. "$out/"
      rm -f "$out/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache"
    '';

  openal = if softwareRendering then runtimePkgs.openal.override {
    pipewireSupport = false;
    pulseSupport = false;
  } else runtimePkgs.openal;
  freealut = if softwareRendering
    then runtimePkgs.freealut.override { inherit openal; }
    else runtimePkgs.freealut;

  softpipeMesa = runtimePkgs.mesa.override {
    galliumDrivers = [ "softpipe" ];
    vulkanDrivers = [ ];
    vulkanLayers = [ ];
    withValgrind = false;
  };

  trimmedSoftpipeMesa = softpipeMesa.overrideAttrs (old: let
    nameOf = input: input.name or input.pname or "";
    containsAny = needles: value:
      builtins.any (needle: lib.hasInfix needle value) needles;
    dropTarget = input: containsAny [
      "clang" "libclc" "llvm" "SPIRV-LLVM" "spirv-tools"
      "directx-headers" "vulkan-loader" "libdisplay-info"
    ] (nameOf input);
    dropNative = input: input == null || containsAny [
      "rustc" "rust-bindgen" "rust-cbindgen" "glslang" "mesa-26.1.8"
    ] (nameOf input);
    dropFlag = flag: containsAny [
      "clang-libdir" "gallium-rusticl" "mesa-clc" "precomp-compiler"
      "microsoft-clc" "teflon" "video-codecs" "display-info" "gallium-va"
    ] flag;
  in {
    preConfigure = "";
    env = builtins.removeAttrs (old.env or { }) [ "MESON_PACKAGE_CACHE_DIR" ];
    buildInputs = builtins.filter (input: !dropTarget input) old.buildInputs;
    nativeBuildInputs = builtins.filter (input: !dropNative input) old.nativeBuildInputs;
    mesonFlags = builtins.filter (flag: !dropFlag flag) old.mesonFlags ++ [
      "-Dllvm=disabled" "-Dgallium-rusticl=false" "-Dmicrosoft-clc=disabled"
      "-Dspirv-tools=disabled" "-Dvideo-codecs=" "-Ddisplay-info=disabled"
      "-Dgallium-va=disabled"
    ];
    outputs = [ "out" ];
    disallowedRequisites = [ ];
    postInstall = "";
    postFixup = ''
      for json in $out/share/glvnd/egl_vendor.d/*.json; do
        substituteInPlace "$json" --replace-fail '"libEGL_' '"'"$out/lib/libEGL_"
      done
    '';
  });

  baseRuntime = with runtimePkgs; [
    openssl pcre pcre2 zlib readline libffi sqlite
    openal freealut libogg libvorbis capstone
  ] ++ lib.optionals runtimePkgs.stdenv.hostPlatform.isx86 [ runtimePkgs.udis86 ];
  uiRuntime = with runtimePkgs; [
    glib pango cairo gdk-pixbuf librsvgRuntime gtk
    libepoxy libGL libGLU libX11 libXcursor libXrandr libXi fontconfig freetype
  ] ++ lib.optionals (uiBackend == "gtk3") [ runtimePkgs.atk ];
  testRuntime = lib.optionals (linuxUI && withTests) [
    runtimePkgs.gtk2
    (if softwareRendering then trimmedSoftpipeMesa else runtimePkgs.mesa)
  ];
  runtimePackages = map lib.getLib
    (baseRuntime ++ lib.optionals linuxUI uiRuntime ++ testRuntime)
    ++ [ runtimePkgs.tzdata ]
    ++ lib.optionals linuxUI (with runtimePkgs; [
      gsettings-desktop-schemas dejavu_fonts shared-mime-info fontconfig.out
    ]);
in
runtimePkgs.buildEnv {
  inherit name;
  pathsToLink = [ "/lib" "/share" ];
  paths = runtimePackages;
  passthru = {
    packages = runtimePackages;
    inherit gtk openal freealut;
    librsvg = runtimePkgs.librsvg;
    mesa = if softwareRendering then trimmedSoftpipeMesa else runtimePkgs.mesa;
  };
}
