function sidebarToggle() {
    browser.sidebarAction.toggle()
}

browser.action.onClicked.addListener(sidebarToggle)