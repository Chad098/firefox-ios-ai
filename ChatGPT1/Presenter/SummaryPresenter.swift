// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

protocol SummaryPresenter: SummaryControllerDelegate {
    var delegate: SummaryPresenterDelegate? { get set }
    var downloadState: DownloadState { get }
    
    func startSummaryPresentationFlow()
}

protocol SummaryPresenterDelegate: UIViewController {
    var currentURL: URL? { get }
    var summaryController: TweetSummaryViewController? { get }
    
    func presentOptions(presenter: SummaryPresenter, animated: Bool, completion: @escaping VoidClosure)
    func presentContainerController(presenter: SummaryPresenter, animated: Bool)
    func updateContainerController(presenter: SummaryPresenter, data: [Tweet])
}
