// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

enum ChatGPTError: Error {
    case authorization
    case invalidRequest
    case missingData
    case requestError(message: String)
    
    var message: String {
        switch self {
        case .authorization:
            return "Not Authorized, check API Key. Code 401"
        case .invalidRequest:
            return "Could not create URLRequest"
        case .missingData:
            return "No Data received from request"
        case let .requestError(message):
            return message
        }
    }
}
