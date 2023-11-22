function sidebarToggle() {
    browser.sidebarAction.toggle()
}

browser.browserAction.onClicked.addListener(sidebarToggle)