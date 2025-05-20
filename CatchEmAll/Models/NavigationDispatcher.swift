struct NavigationDispatcher {
    let onItemSelect: (UInt) -> Void
    let onErrorOccur: (Error) -> Void
}
