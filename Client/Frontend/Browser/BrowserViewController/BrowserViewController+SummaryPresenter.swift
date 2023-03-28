// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

extension BrowserViewController: SummaryPresenterDelegate {
    var currentURL: URL? { tabManager.selectedTab?.url }
    
    // MARK: - Private
    private func createOptionsAlert(_ completion: @escaping VoidClosure) -> UIAlertController {
        let alert = UIAlertController(
            title: "ChatGPT Summary",
            message: "Please Select an option",
            preferredStyle: .actionSheet
        )
        
        let tweetAction = UIAlertAction(
            title: "Tweet",
            style: .default
        ) { (_) in
            completion()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        [tweetAction, cancel].forEach { alert.addAction($0) }
        
        return alert
    }
    
    // MARK: - Public
    func presentOptions(presenter: SummaryPresenter, animated: Bool, completion: @escaping VoidClosure) {
        let alert = createOptionsAlert(completion)
        present(alert, animated: animated)
    }
    
    func presentContainerController(presenter: SummaryPresenter, animated: Bool) {
        let controller = TweetSummaryViewController()
        controller.delegate = presenter
        
        summaryController = controller
        present(controller, animated: true)
    }
    
    func updateContainerController(presenter: SummaryPresenter, data: [Tweet]) {
        DispatchQueue.main.async { [weak self] in
            self?.summaryController?.configure(tweets: data, downloadState: presenter.downloadState)
        }
    }
}
