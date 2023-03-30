// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

extension UITableView {
    func registerCell<T: UITableViewCell>(_ cell: T.Type) {
        register(
            .init(nibName: T.nibName, bundle: nil),
            forCellReuseIdentifier: T.nibName
        )
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ cell: T.Type) -> T? {
        dequeueReusableCell(withIdentifier: T.nibName) as? T
    }
}

// Move to new file eventually
extension UIViewController {
    static var nibName: String { "\(Self.self)" }
}

extension UIView {
    static var nibName: String { "\(Self.self)" }
}
