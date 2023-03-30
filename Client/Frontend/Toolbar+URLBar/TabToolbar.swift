// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import UIKit
import Shared

class TabToolbar: UIView {
    // MARK: - Variables

    weak var tabToolbarDelegate: TabToolbarDelegate?

    let tabsButton = TabsButton()
    let addNewTabButton = ToolbarButton()
    let appMenuButton = ToolbarButton()
    let bookmarksButton = ToolbarButton()
    let forwardButton = ToolbarButton()
    let backButton = ToolbarButton()
    lazy var summaryButton: ToolbarButton? = .init()
    let multiStateButton = ToolbarButton()
    var actionButtons: [NotificationThemeable & UIButton] {
        [
            backButton,
            forwardButton,
            multiStateButton,
            addNewTabButton,
            tabsButton,
            summaryButton,
            appMenuButton
        ].compactMap { $0 }
    }

    private let privateModeBadge = BadgeWithBackdrop(imageName: ImageIdentifiers.privateModeBadge,
                                                     backdropCircleColor: UIColor.Defaults.MobilePrivatePurple)
    private let appMenuBadge = BadgeWithBackdrop(imageName: ImageIdentifiers.menuBadge)
    private let warningMenuBadge = BadgeWithBackdrop(imageName: ImageIdentifiers.menuWarning,
                                                     imageMask: ImageIdentifiers.menuWarningMask)

    var helper: TabToolbarHelper?
    private let contentView = UIStackView()

    // MARK: - Initializers
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setupAccessibility()

        addSubview(contentView)
        helper = TabToolbarHelper(toolbar: self)
        addButtons(actionButtons)

        privateModeBadge.add(toParent: contentView)
        appMenuBadge.add(toParent: contentView)
        warningMenuBadge.add(toParent: contentView)

        contentView.axis = .horizontal
        contentView.distribution = .fillEqually
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Setup

    override func updateConstraints() {
        privateModeBadge.layout(onButton: tabsButton)
        appMenuBadge.layout(onButton: appMenuButton)
        warningMenuBadge.layout(onButton: appMenuButton)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
        ])
        super.updateConstraints()
    }

    private func setupAccessibility() {
        backButton.accessibilityIdentifier = "TabToolbar.backButton"
        forwardButton.accessibilityIdentifier = "TabToolbar.forwardButton"
        multiStateButton.accessibilityIdentifier = "TabToolbar.multiStateButton"
        tabsButton.accessibilityIdentifier = "TabToolbar.tabsButton"
        addNewTabButton.accessibilityIdentifier = "TabToolbar.addNewTabButton"
        appMenuButton.accessibilityIdentifier = AccessibilityIdentifiers.Toolbar.settingsMenuButton
        summaryButton?.accessibilityIdentifier = "TabToolbar.tabsButton"
        accessibilityNavigationStyle = .combined
        accessibilityLabel = .TabToolbarNavigationToolbarAccessibilityLabel
    }

    func addButtons(_ buttons: [UIButton]) {
        buttons.forEach { contentView.addArrangedSubview($0) }
    }

    override func draw(_ rect: CGRect) {
        // No line when the search bar is on top of the toolbar
        guard isBottomSearchBar == false else { return }

        if let context = UIGraphicsGetCurrentContext() {
            drawLine(context, start: .zero, end: CGPoint(x: frame.width, y: 0))
        }
    }

    private func drawLine(_ context: CGContext, start: CGPoint, end: CGPoint) {
        context.setStrokeColor(UIColor.black.withAlphaComponent(0.05).cgColor)
        context.setLineWidth(2)
        context.move(to: CGPoint(x: start.x, y: start.y))
        context.addLine(to: CGPoint(x: end.x, y: end.y))
        context.strokePath()
    }
}

// MARK: - TabToolbarProtocol
extension TabToolbar: TabToolbarProtocol {
    var homeButton: ToolbarButton { multiStateButton }

    func privateModeBadge(visible: Bool) {
        privateModeBadge.show(visible)
    }

    func warningMenuBadge(setVisible: Bool) {
        // Disable other menu badges before showing the warning.
        appMenuBadge.show(appMenuBadge.badge.isHidden == false)
        warningMenuBadge.show(setVisible)
    }

    func updateBackStatus(_ canGoBack: Bool) {
        backButton.isEnabled = canGoBack
    }

    func updateForwardStatus(_ canGoForward: Bool) {
        forwardButton.isEnabled = canGoForward
    }

    func updateMiddleButtonState(_ state: MiddleButtonState) {
        helper?.setMiddleButtonState(state)
    }

    func updatePageStatus(_ isWebPage: Bool) { }

    func updateTabCount(_ count: Int, animated: Bool) {
        tabsButton.updateTabCount(count, animated: animated)
    }
}

// MARK: - Search Bar location properties
extension TabToolbar: SearchBarLocationProvider {}

// MARK: - Theme protocols

extension TabToolbar: NotificationThemeable, PrivateModeUI {
    func applyTheme() {
        backgroundColor = UIColor.legacyTheme.browser.background
        helper?.setTheme(forButtons: actionButtons)

        privateModeBadge.badge.tintBackground(color: UIColor.legacyTheme.browser.background)
        appMenuBadge.badge.tintBackground(color: UIColor.legacyTheme.browser.background)
        warningMenuBadge.badge.tintBackground(color: UIColor.legacyTheme.browser.background)
    }

    func applyUIMode(isPrivate: Bool) {
        privateModeBadge(visible: isPrivate)
    }
}
