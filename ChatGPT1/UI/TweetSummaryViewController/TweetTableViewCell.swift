// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import TTTAttributedLabel

class AttributedLabel: TTTAttributedLabel {}

// Skeleton cell
class TweetTableViewCell: UITableViewCell {
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var tagLabel: UILabel!
    @IBOutlet private weak var contentLabel: AttributedLabel!
    @IBOutlet private weak var separatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
        updateAppearance()
    }
    
    // MARK: - Private
    private func configure() {
        selectionStyle = .none
        
        configureProfileImageView()
        configureNameLabel()
        configureTagLabel()
        configureContentLabel()
    }
    
    private func configureProfileImageView() {
        profileImageView.image = .init(named: "chatgpt-twitter-icon")
    }
    
    private func configureNameLabel() {
        nameLabel.text = "Your Account Name"
        nameLabel.font = .systemFont(ofSize: 13, weight: .semibold)
    }
    
    private func configureTagLabel() {
        tagLabel.text = "@yourtag"
        tagLabel.font = .systemFont(ofSize: 10, weight: .light)
    }
    
    private func configureContentLabel() {
        contentLabel.isUserInteractionEnabled = false
        contentLabel.textInsets = .init(top: 0, left: 5, bottom: 0, right: 5)
        
        // needs to format hashtags also
        contentLabel.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
        contentLabel.font = .systemFont(ofSize: 12, weight: .regular)
        contentLabel.numberOfLines = 0
    }
    
    private func updateAppearance() {
        separatorView.backgroundColor = .gray.withAlphaComponent(0.6)
    }
    
    // MARK: - Public
    func configure(tweet: Tweet) {
        contentLabel.setText(tweet.tweet)
    }
}
