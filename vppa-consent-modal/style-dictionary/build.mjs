// build.mjs — generate per-platform constants from ../tokens.json (W3C DTCG).
//
//   cd style-dictionary && npm install && npm run build
//
// Outputs into build/:
//   css/tokens.css        CSS custom properties (all primitives, px) -> vppa-modal.html :root
//   ios/Colors.swift      Swift UIColor constants -> replace color values in the `Tok` enum
//   android/colors.xml    Android <color> resources -> Compose/XML color refs
//   json/tokens.flat.json flat key/value map (all tokens, with units) -> any other consumer
//
// SCALE NOTE — colors are generated for every platform because they are unambiguous and the
// highest-value thing to keep machine-synced. Dimensions are authored at the OTT 1920 (1080p)
// px scale and exported to CSS + the neutral flat JSON; each native platform applies its own
// scale factor (tvOS points are ~1:1 at 1080p HD; Android dp depends on the density baseline,
// commonly 1dp = 2px on a 1080p TV), so native dimension constants stay hand-tuned in the
// platform files rather than machine-emitted with one misleading value.
//
// Composite typography and shadow tokens are emitted to the flat JSON only and are otherwise
// consumed from component-spec.json, since each platform expresses them differently.

import StyleDictionary from 'style-dictionary';

const typeOf = (t) => t.$type ?? t.type;

// CSS gets all primitives (px is native there); native platforms get colors only.
StyleDictionary.registerFilter({
  name: 'primitivesOnly',
  filter: (t) => new Set(['color', 'dimension', 'number', 'duration']).has(typeOf(t)),
});
StyleDictionary.registerFilter({
  name: 'colorsOnly',
  filter: (t) => typeOf(t) === 'color',
});

const sd = new StyleDictionary({
  source: ['../tokens.json'],
  usesDtcg: true,
  log: { verbosity: 'default' },
  platforms: {
    css: {
      transformGroup: 'css',
      buildPath: 'build/css/',
      files: [{
        destination: 'tokens.css',
        format: 'css/variables',
        filter: 'primitivesOnly',
        options: { outputReferences: true },
      }],
    },
    ios: {
      transformGroup: 'ios-swift-separate',
      buildPath: 'build/ios/',
      files: [{
        destination: 'Colors.swift',
        format: 'ios-swift/class.swift',
        filter: 'colorsOnly',
        options: { className: 'VppaColors', accessControl: 'public' },
      }],
    },
    android: {
      transformGroup: 'android',
      buildPath: 'build/android/',
      files: [{
        destination: 'colors.xml',
        format: 'android/resources',
        filter: 'colorsOnly',
      }],
    },
    json: {
      transformGroup: 'js',
      buildPath: 'build/json/',
      files: [{
        destination: 'tokens.flat.json',
        format: 'json/flat',
      }],
    },
  },
});

await sd.hasInitialized;
await sd.buildAllPlatforms();
