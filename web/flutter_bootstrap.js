// Custom Flutter web bootstrap.
//
// Renderer is pinned to CanvasKit on purpose. In Flutter 3.41 the default
// build (no --wasm) already ships CanvasKit only, but pinning it here makes
// the choice explicit and deterministic: even a future --wasm build keeps
// CanvasKit instead of silently preferring Skwasm, which would require
// cross-origin isolation (COOP/COEP headers) that our hosting does not set.
// CanvasKit also gives the highest visual fidelity, which suits this app.
//
// canvasKitBaseUrl points at the bundled artifacts (relative, so it honors
// the page's <base href>) instead of the gstatic CDN. This keeps loads
// deterministic and offline-capable and removes a third-party runtime
// dependency. Pair this with `flutter build web --no-web-resources-cdn`
// so the CDN URL is not baked into the build config.
{{flutter_js}}
{{flutter_build_config}}

// Resolves to the build's version string, or null for --pwa-strategy=none.
const serviceWorkerVersion = {{flutter_service_worker_version}};

_flutter.loader.load({
  config: {
    renderer: "canvaskit",
    canvasKitBaseUrl: "canvaskit/",
  },
  // Register Flutter's generated service worker (PWA offline / app-shell
  // cache) only when one was emitted; omit it for no-PWA builds so the loader
  // doesn't try to register a missing worker.
  serviceWorkerSettings: serviceWorkerVersion == null
    ? undefined
    : { serviceWorkerVersion },
});
