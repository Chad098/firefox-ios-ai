// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

class ChatGPTConnector {
    private let model: Model
    private let apiKey = "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" // needs to be stored securely
    private var task: URLSessionDataTask?
    
    init(model: Model = .davinci) {
        self.model = model
    }
    
    // MARK: - Private
    private func configureRequest(message: String) -> URLRequest? {
        guard let url = model.apiURL else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestData = """
        {
            "prompt": "\(message)",
            "temperature": 0.5,
            "max_tokens": 2048,
            "stop": "None"
        }
        """
        
        request.httpBody = requestData.data(using: .utf8)
        
        return request
    }
    
    private func handleRequestErrorIfNeeded(response: URLResponse?, error: Error?) -> ChatGPTError? {
        if let error = error {
            return .requestError(message: error.localizedDescription)
        }
        
        if let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) == false {
            return response.statusCode == 401 ? .authorization : .requestError(message: "Invalid Status Code. Code: \(response.statusCode)")
        }
        
        return nil
    }
    
    // MARK: - Public
    func fetchSummary(message: String, completion: @escaping ResultClosure<ChatGPTResponse, ChatGPTError>) {
        guard let request = configureRequest(message: message) else {
            completion(.failure(.invalidRequest))
            return
        }
        
        task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = self?.handleRequestErrorIfNeeded(response: response, error: error) {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let content = try? JSONDecoder().decode(ChatGPTResponse.self, from: data) else {
                completion(.failure(.missingData))
                return
            }
            
            completion(.success(content))
        }
        
        task?.resume()
    }
    
    func cancelTask() {
        task?.cancel()
        task = nil
    }
}
