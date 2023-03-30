// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

class ChatGPTSummaryPresenter: SummaryPresenter {
    private let connector: ChatGPTConnector
    private(set) var downloadState: DownloadState = .notStarted
    
    private var message: String? {
        let path: String? = {
            guard let url = delegate?.currentURL?.absoluteString, var componets = URLComponents(string: url) else { return nil }
            
            componets.queryItems = nil
            return componets.url?.absoluteString
        }()
        
        guard let path = path else { return nil }
        
        return "Create a JSON Object with array of tweets based on the TOP 3 topics from webpage summary. Format each tweet as a twitter tweet. Each tweet must contain hashtags and a link to the source webpage. Use up to 3 sentances per headline and up to 3 hashtags per headline. \(path) do not include additional comments other than the json object"
    }
    
    weak var delegate: SummaryPresenterDelegate?
    
    init(connector: ChatGPTConnector = .init()) {
        self.connector = connector
    }
    
    // MARK: - Private
    private func showOptionSheet() {
        delegate?.presentOptions(presenter: self, animated: true) { [weak self] in
            guard let weakSelf = self else { return }
            
            weakSelf.fetchSummary()
            weakSelf.delegate?.presentContainerController(presenter: weakSelf, animated: true)
        }
    }
    
    private func fetchSummary() {
        guard let message = message, downloadState != .inProgress else { return }
        
        downloadState = .inProgress
        connector.fetchSummary(message: message) { [weak self] (result) in
            guard let weakSelf = self else { return }
            
            switch result {
            case let .success(response):
                weakSelf.downloadState = .successful
                weakSelf.presentSummary(response: response)
            case let .failure(error):
                weakSelf.downloadState = .failure
                weakSelf.delegate?.updateContainerController(presenter: weakSelf, data: [])
                print(error.message)
            }
        }
    }
    
    // Request seems timeout at various times, response is inconsistent, still would prefer to parse structured data
    private func parseTweets(response: ChatGPTResponse) -> Content? {
        guard let text = response.choices.first?.text.trimmingCharacters(in: .whitespacesAndNewlines), let data = text.data(using: .utf8) else {
            return nil
        }
        
        return try? JSONDecoder().decode(Content.self, from: data)
    }
    
    private func presentSummary(response: ChatGPTResponse) {
        let tweets = parseTweets(response: response)?.tweets ?? []
        if tweets.isEmpty { downloadState = .failure }
        delegate?.updateContainerController(presenter: self, data: tweets)
    }
    
    // MARK: - Public
    func startSummaryPresentationFlow() {
        showOptionSheet()
    }
}

// MARK: - SummaryControllerDelegate
extension ChatGPTSummaryPresenter: SummaryControllerDelegate {
    func didTapRetryButton(controller: UIViewController) {
        fetchSummary()
    }
    
    func willDismiss(controller: UIViewController) {
        connector.cancelTask()
    }
}
