// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

enum DownloadState {
    case notStarted
    case inProgress
    case successful
    case failure
    
    var isLoading: Bool { self == .inProgress }
    var isSuccessful: Bool { self == .successful }
    var isFailure: Bool { self == .failure }
    
    var completed: Bool { self == .successful || self == .failure }
}
