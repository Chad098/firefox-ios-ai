// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation

protocol SummaryControllerDelegate: AnyObject {
    func didTapRetryButton(controller: UIViewController)
    func willDismiss(controller: UIViewController)
}

class TweetSummaryViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var retryButton: UIButton!
    @IBOutlet private weak var loader: UIActivityIndicatorView!
    @IBOutlet private weak var exitButton: UIButton!
    
    private var downloadState: DownloadState = .notStarted {
        didSet {
            guard downloadState != oldValue else { return }
            updateUI()
        }
    }
    
    private var tweets: [String] = []
    weak var delegate: SummaryControllerDelegate?
    
    init() {
        super.init(nibName: Self.nibName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureRetryButton()
        configureLoader()
        configureExitButton()
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        delegate?.willDismiss(controller: self)
        super.dismiss(animated: flag, completion: completion)
    }
    
    // MARK: - Actions
    @objc
    private func didTapRetryButton(_ button: UIButton) {
        delegate?.didTapRetryButton(controller: self)
        downloadState = .inProgress
    }
    
    @objc
    private func didTapExitButton(_ button: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - Private
    private func configureTableView() {
        //tableView.delegate = self  // not needed for this example
        tableView.dataSource = self
        tableView.registerCell(TweetTableViewCell.self)
        
        tableView.separatorStyle = .none
        tableView.isHidden = true
    }
    
    private func configureRetryButton() {
        retryButton.setTitle("Retry", for: .normal)
        retryButton.setTitleColor(.lightGray, for: .normal)
        
        retryButton.isHidden = true
        retryButton.addTarget(self, action: #selector(didTapRetryButton), for: .touchUpInside)
    }
    
    private func configureExitButton() {
        exitButton.setTitle("Exit", for: .normal)
        exitButton.setTitleColor(.lightGray, for: .normal)
        
        exitButton.addTarget(self, action: #selector(didTapExitButton), for: .touchUpInside)
    }
    
    private func configureLoader() {
        loader.style = .large
        loader.startAnimating()
        loader.hidesWhenStopped = true
    }
    
    private func updateUI() {
        updateLoader()
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let weakSelf = self else { return }
            
            weakSelf.updateVisibility()
        } completion: { [weak self] (_) in
            guard self?.downloadState.isSuccessful == true else { return }
            
            self?.tableView.reloadData()
        }
    }
    
    private func updateLoader() {
        if downloadState.completed {
            loader.stopAnimating()
        } else if downloadState.isLoading, loader.isAnimating == false {
            loader.startAnimating()
        }
    }
    
    private func updateVisibility() {
        tableView.isHidden = downloadState != .successful
        tableView.alpha = downloadState.isSuccessful ? 1.0 : 0.0
        
        retryButton.isHidden = downloadState != .failure
        retryButton.alpha = downloadState.isFailure ? 1.0 : 0.0
        
        loader.isHidden = downloadState != .inProgress
        loader.alpha = downloadState.isLoading ? 1.0 : 0.0
    }
    
    // MARK: - Public
    func configure(tweets: [String], downloadState: DownloadState) {
        self.tweets = tweets
        self.downloadState = downloadState
    }
}

// MARK: - UITableViewDataSource
extension TweetSummaryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(TweetTableViewCell.self) else {
            return .init()
        }
        
        cell.configure(tweet: tweets[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tweets.count
    }
}
