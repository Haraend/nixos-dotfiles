function isExternal(url) {
  try {
    const parsed = new URL(url, location.href);
    if (parsed.protocol !== "http:" && parsed.protocol !== "https:") {
      return false;
    }
    return parsed.origin !== location.origin;
  } catch {
    return false;
  }
}

function requestOpen(url) {
  if (!isExternal(url)) {
    return;
  }
  const anchor = document.createElement("a");
  anchor.href = `webapp-open://open?url=${encodeURIComponent(url)}`;
  anchor.rel = "noreferrer";
  document.documentElement.appendChild(anchor);
  anchor.click();
  anchor.remove();
}

document.addEventListener(
  "click",
  (event) => {
    const clicked = event.target.closest?.("a[href]");
    if (!clicked) {
      return;
    }
    const href = clicked.href;
    if (!href || !isExternal(href)) {
      return;
    }
    event.preventDefault();
    event.stopImmediatePropagation();
    requestOpen(href);
  },
  true,
);

window.addEventListener("message", (event) => {
  if (event.origin !== location.origin) {
    return;
  }
  const url = event.data?.__webappOpen;
  if (typeof url === "string" && isExternal(url)) {
    requestOpen(url);
  }
});
