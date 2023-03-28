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
        
        return "Create a JSON string based on the TOP 3 headlines from webpage summary, format each as a twitter tweet. Each json record must contain a tweet with hashtags and a link to the source webpage, link field with the source webpage. Use up to 5 sentances per headline and up to 3 hashtags per headline. \(path)"
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
    
    private func parseTweets(response: ChatGPTResponse) -> [Tweet]? {
        guard let data = response.choices.first?.text.data(using: .utf8) else { return nil }
        
        return try? JSONDecoder().decode([Tweet].self, from: data)
    }
    
    private func presentSummary(response: ChatGPTResponse) {
        let tweets = parseTweets(response: response) ?? []
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
