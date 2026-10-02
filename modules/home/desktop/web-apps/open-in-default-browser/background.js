const APP_HOSTS = new Set([
  "web.whatsapp.com",
  "gemini.google.com",
]);

function isAppUrl(url) {
  if (!url) {
    return true;
  }
  if (
    url.startsWith("chrome://") ||
    url.startsWith("brave://") ||
    url.startsWith("chrome-extension://") ||
    url.startsWith("about:") ||
    url.startsWith("webapp-open:")
  ) {
    return true;
  }
  try {
    return APP_HOSTS.has(new URL(url).hostname);
  } catch {
    return true;
  }
}

chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  const url = changeInfo.url || tab.url;
  if (!url || isAppUrl(url) || !/^https?:\/\//i.test(url)) {
    return;
  }
  chrome.tabs.remove(tabId).catch(() => {});
});
