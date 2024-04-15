function getCinnyUrl() {
    return browser.runtime.getURL("sidebar/index.html");
}

function openCinny() {
    browser.tabs.create({ url: getCinnyUrl() });
}

browser.action.onClicked.addListener(openCinny)