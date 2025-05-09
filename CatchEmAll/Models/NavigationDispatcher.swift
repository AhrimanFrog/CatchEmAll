import UIKit

struct NavigationDispatcher {
    let onItemSelect: (UIImage, UInt) -> Void
    let onErrorOccur: (Error) -> Void
}
