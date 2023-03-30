// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

extension ChatGPTConnector {
    enum Model {
        case davinci
        case curie
        case babbage
        case ada
        
        var apiURL: URL? {
            let path: String
            
            switch self {
            case .davinci:
                path = "https://api.openai.com/v1/engines/text-davinci-003/completions"
            case .curie:
                path = "https://api.openai.com/v1/engines/text-curie-001/completions"
            case .babbage:
                path = "https://api.openai.com/v1/engines/text-babbage-001/completions"
            case .ada:
                path = "https://api.openai.com/v1/engines/text-ada-001/completions"
            }
            
            return .init(string: path)
        }
    }
}
