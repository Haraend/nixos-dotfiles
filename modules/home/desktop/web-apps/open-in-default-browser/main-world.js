(function () {
  function isExternal(url) {
    try {
      const parsed = new URL(String(url), location.href);
      if (parsed.protocol !== "http:" && parsed.protocol !== "https:") {
        return false;
      }
      return parsed.origin !== location.origin;
    } catch {
      return false;
    }
  }

  const originalOpen = window.open;
  window.open = function (url, ...rest) {
    if (url && isExternal(url)) {
      window.postMessage({ __webappOpen: String(url) }, location.origin);
      return null;
    }
    return originalOpen.apply(this, [url, ...rest]);
  };
})();
