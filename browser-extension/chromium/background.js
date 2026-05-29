const MENU_ID = "open-link-in-windows-sandbox";
const NATIVE_HOST_NAME = "com.sandboxquickopen.host";

chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: MENU_ID,
    title: "Open Link in Windows Sandbox",
    contexts: ["link"]
  });
});

chrome.contextMenus.onClicked.addListener((info) => {
  if (info.menuItemId !== MENU_ID) {
    return;
  }

  if (!info.linkUrl) {
    return;
  }

  chrome.runtime.sendNativeMessage(
    NATIVE_HOST_NAME,
    {
      action: "openUrl",
      url: info.linkUrl
    },
    (response) => {
      if (chrome.runtime.lastError) {
        console.error("Sandbox Quick Open native host error:", chrome.runtime.lastError.message);
        return;
      }

      console.log("Sandbox Quick Open response:", response);
    }
  );
});