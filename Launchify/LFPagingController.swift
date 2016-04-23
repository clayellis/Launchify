//
//  LFPagingController.swift
//
//  Created by Clay Ellis on 4/5/16.
//  Copyright © 2016 Clay Ellis. All rights reserved.
//

import UIKit

// TODO:
// - : Put this on Git
// - : Add a delegate method for "pageIsChanging"
// - : Fix the content offset of the new page when the top bar is up
// - : Fade the paging button in/out at the page is changed (maybe with using, which page is coming into/out of view and
//      what percentage of that view is visible, use the percentage to animate the alpha)
// - : Add support for more pages by making the paging buttons scroll
// - : Use a height constraint instead of a transform when moving the top bar

@objc protocol LFPagingControllerPagingDelegate: class {
    optional func pagingControll(pagingControl pagingControl: LFPagingController, pageIsChangingFromPageAtIndex fromIndex: Int, toPageAtIndex toIndex: Int)
    optional func pagingControll(pagingControl pagingControl: LFPagingController, pageDidChangeToPageAtIndex index: Int)
    optional func pagingControll(pagingControl pagingControl: LFPagingController, pagingButtonTappedAtIndex index: Int)
    optional func pagingControll(pagingControl pagingControl: LFPagingController, affectingScrollViewDidScrollPastThreshold threshold: CGFloat, withOffset offset: CGFloat, draggingUp: Bool)
}

class PagingViewController: UIViewController {
    var pagingController: LFPagingController?
    /// Called once the paging view controller has been successfully added to the paging controller.
    /// Important: Call super at the beginning of the method
    func didMoveToPagingController(pagingController: LFPagingController) {
        self.pagingController = pagingController
    }
}

// Requires that these methods be implemented in order to move the top bar
protocol LFPagingControllerAffectingScrollView {
    func scrollViewDidScroll(scrollView: UIScrollView)
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView)
}

public class LFPagingController: UIControl, UIScrollViewDelegate {
    
    // Delegates
    var pagingDelegates: [LFPagingControllerPagingDelegate] = []
    
    // Parent View Controller
    weak var parentViewController: UIViewController? {
        didSet {
            titleLabel.text = parentViewController?.title
        }
    }
    
    // Subviews
    dynamic let topBar = UIView() // Declared dynamic in order to observe
    private let titleLabel = UILabel()
    private let pagingButtonsStackView = UIStackView()
    private var pagingButtons = [UIButton]()
    private let selectionIndicator = UIView()
    private var selectionIndicatorCenterXConstraint: NSLayoutConstraint!
    private var selectionIndicatorWidthConstraint: NSLayoutConstraint!
    
    var pagingViewControllers = [UIViewController]()
    let pagingScrollView = UIScrollView()
    var pagingViews = [UIView]()
    
    // Paging Properties
    var currentIndex = 0
    var pageWidth: CGFloat {
        // Prevent 0 from being returned to avoid NaN division
        return max(pagingScrollView.frame.width, 1)
    }
    
    // MARK: - Initialization
    private convenience init() {
        self.init(frame: .zero)
        configureSubviews()
        configureLayout()
    }
    
    private func configureSubviews() {
        // Add Subviews
        addSubview(pagingScrollView)
        addSubview(topBar)
        topBar.addSubview(titleLabel)
        topBar.addSubview(pagingButtonsStackView)
        topBar.addSubview(selectionIndicator)
        
        // Style View
        backgroundColor = .clearColor()
        
        // Style Subviews
        topBar.backgroundColor = .lfDarkestGray()
        
        titleLabel.text = parentViewController?.title ?? "Parent VC Title"
        titleLabel.textColor = .whiteColor()
        titleLabel.font = UIFont.systemFontOfSize(17, weight: UIFontWeightMedium)
        
        pagingButtonsStackView.alignment = .Fill
        pagingButtonsStackView.axis = .Horizontal
        pagingButtonsStackView.distribution = .FillEqually
        
        selectionIndicator.backgroundColor = .lfGreen()
        
        pagingScrollView.delegate = self
        pagingScrollView.pagingEnabled = true
        pagingScrollView.showsHorizontalScrollIndicator = false
        pagingScrollView.showsVerticalScrollIndicator = false
        pagingScrollView.directionalLockEnabled = true
        pagingScrollView.bounces = true
        pagingScrollView.delaysContentTouches = false
    }
    
    private func configureLayout() {
        setTranslatesAutoresizingMaskIntoConstraintsToFalse(
            topBar, titleLabel, pagingButtonsStackView, selectionIndicator, pagingScrollView)
        
        // Add Constraints
        selectionIndicatorCenterXConstraint = selectionIndicator.centerXAnchor.constraintEqualToAnchor(centerXAnchor)
        selectionIndicatorWidthConstraint = selectionIndicator.widthAnchor.constraintEqualToAnchor(topBar.widthAnchor, multiplier: 1/3)
        
        NSLayoutConstraint.activateConstraints([
            // Top Bar
            topBar.leftAnchor.constraintEqualToAnchor(leftAnchor),
            topBar.rightAnchor.constraintEqualToAnchor(rightAnchor),
            topBar.topAnchor.constraintEqualToAnchor(topAnchor),
            topBar.heightAnchor.constraintEqualToConstant(LFPagingController.topBarBarHeight),
            
            // Title Label
            titleLabel.centerXAnchor.constraintEqualToAnchor(topBar.centerXAnchor),
            titleLabel.bottomAnchor.constraintEqualToAnchor(pagingButtonsStackView.topAnchor, constant: 0),
            
            // Paging Buttons Stack View
            pagingButtonsStackView.leftAnchor.constraintEqualToAnchor(topBar.leftAnchor),
            pagingButtonsStackView.rightAnchor.constraintEqualToAnchor(topBar.rightAnchor),
            pagingButtonsStackView.bottomAnchor.constraintEqualToAnchor(topBar.bottomAnchor),
            // (Height of the selection indicator + a constant height)
            pagingButtonsStackView.heightAnchor.constraintEqualToAnchor(selectionIndicator.heightAnchor, multiplier: 1.0, constant: 35),
            
            // Selection Bar
            selectionIndicatorCenterXConstraint,
            selectionIndicatorWidthConstraint,
            selectionIndicator.bottomAnchor.constraintEqualToAnchor(topBar.bottomAnchor),
            selectionIndicator.heightAnchor.constraintEqualToConstant(3),
            
            // Paging Scroll View
            pagingScrollView.leftAnchor.constraintEqualToAnchor(leftAnchor),
            pagingScrollView.rightAnchor.constraintEqualToAnchor(rightAnchor),
            pagingScrollView.topAnchor.constraintEqualToAnchor(topAnchor),
            pagingScrollView.bottomAnchor.constraintEqualToAnchor(bottomAnchor)
            ])
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        // Set the paging scroll view's content size to enable scrolling
        pagingScrollView.contentSize = CGSize(width: pagingScrollView.frame.width * CGFloat(pagingViews.count), height: 0)
    }
    
    func teardown() {
        for pagingViewController in pagingViewControllers {
            pagingViewController.removeFromParentViewController()
        }
        
        for pagingView in pagingViews {
            pagingView.removeFromSuperview()
        }
        
        parentViewController = nil
        pagingViews.removeAll()
        pagingViewControllers.removeAll()
        pagingDelegates.removeAll()
    }
    
    deinit {
        teardown()
    }
    
    // MARK: - Paging Delegates Notification Methods
    
    internal func addPagingDelegate(delegate: LFPagingControllerPagingDelegate) {
        pagingDelegates.append(delegate)
    }
    
    private func notifyPagingDelegates(pagingButtonTappedAtIndex index: Int) {
        for pagingDelegate in pagingDelegates {
            pagingDelegate.pagingControll?(pagingControl: self, pagingButtonTappedAtIndex: index)
        }
    }
    
    private func notifyPagingDelegates(pageDidChangeToPageAtIndex index: Int) {
        for pagingDelegate in pagingDelegates {
            pagingDelegate.pagingControll?(pagingControl: self,pageDidChangeToPageAtIndex: index)
        }
    }
    
    private func notifyPagingDelegates(pageIsChangingFromPageAtIdex fromIndex: Int, toPageAtIndex toIndex: Int) {
        for pagingDelegate in pagingDelegates {
            pagingDelegate.pagingControll?(pagingControl: self,pageIsChangingFromPageAtIndex: fromIndex, toPageAtIndex: toIndex)
        }
    }
    
    private func notifyPagingDelegates(affectingScrollViewDidScrollPastThreshold threshold: CGFloat, withOffset offset: CGFloat, draggingUp: Bool) {
        for pagingDelegate in pagingDelegates {
            pagingDelegate.pagingControll?(pagingControl: self,affectingScrollViewDidScrollPastThreshold: threshold, withOffset: offset, draggingUp: draggingUp)
        }
    }
    
    // MARK: - LFPageController Methods
    
    internal func addPagingViewController(pagingViewController: PagingViewController) {
        // Animation constants
        let animationDuration: NSTimeInterval = 0.3
        
        // Paging View
        // ------------------------------------
        // Tell the paging view controller that is has moved to a parent
        guard let parentViewController = parentViewController else {
            return print("LFPagingController view controller not added. Set parentViewController before continuing. Apple requires that custom container views signal to their children that they have moved to a new parent view controller. \"If you are implementing your own container view controller, it must call the didMoveToParentViewController: method of the child view controller after the transition to the new controller is complete...\"")
        }
        parentViewController.didMoveToParentViewController(pagingViewController)
        pagingViewController.loadViewIfNeeded()
        
        // Add the new paging view controller to the array of paging view controllers
        pagingViewControllers.append(pagingViewController)
        
        // Copy the paging view for convenience
        let pagingView = pagingViewController.view
        
        // Add the new paging view to the array of paging views
        pagingViews.append(pagingView)
        
        // Add the new paging view as a subview to the paging scroll view
        pagingScrollView.addSubview(pagingView)
        
        // Layout the new paging view
        pagingView.translatesAutoresizingMaskIntoConstraints = false
        
        // The left constraint is dependent on the index of the paging view
        var leftConstraint: NSLayoutConstraint!
        if pagingView == pagingViews.first! {
            leftConstraint = pagingView.leftAnchor.constraintEqualToAnchor(pagingScrollView.leftAnchor)
        } else {
            let pagingViewIndex = pagingViews.indexOf(pagingView)!
            let previousPagingView = pagingViews[pagingViewIndex - 1]
            leftConstraint = pagingView.leftAnchor.constraintEqualToAnchor(previousPagingView.rightAnchor)
        }
        
        // Activate constraints on the new paging view
        NSLayoutConstraint.activateConstraints([
            // Paging View
            leftConstraint,
            pagingView.widthAnchor.constraintEqualToAnchor(pagingScrollView.widthAnchor),
            pagingView.topAnchor.constraintEqualToAnchor(topAnchor),
            // Cannot constrain to the paging scroll view's bottom anchor, constrain to bottom anchor instead
            pagingView.bottomAnchor.constraintEqualToAnchor(bottomAnchor)
            ])
        
        // Paging Button
        // ------------------------------------
        // Create a new paging button with the new paging view's title
        let pagingButton = UIButton()
        pagingButton.setTitle(pagingViewController.title ?? "VC Title", forState: .Normal)
        pagingButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.3), forState: .Normal)
        pagingButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.7), forState: .Highlighted)
        pagingButton.setTitleColor(.whiteColor(), forState: .Selected)
        pagingButton.titleLabel!.font = UIFont.systemFontOfSize(15, weight: UIFontWeightMedium)
        pagingButton.titleLabel!.allowsDefaultTighteningForTruncation = true
        pagingButton.titleLabel!.adjustsFontSizeToFitWidth = true
        pagingButton.titleLabel!.minimumScaleFactor = 0.8
        
        // Add the new paging button to the array of paging buttons
        pagingButtons.append(pagingButton)
        
        // Add the new paging button view
        // Animate adding the new paging button by hiding it initially
        pagingButton.hidden = true
        // Hide the new paging view as well to avoid seeing it flash across the screen
        pagingView.hidden = true
        // Add the new paging button as an arranged subview of the paging buttons stack view
        pagingButtonsStackView.addArrangedSubview(pagingButton)
        UIView.animateWithDuration(animationDuration, delay: 0, options: [.AllowUserInteraction], animations: {
            // Unhiding the new paging button animates it in
            pagingButton.hidden = false
            }, completion: { _ in
                // Once the animation is complete, unhide the new paging view
                pagingView.hidden = false
        })
        
        // Set the new paging button's tag as the new paging view's index
        pagingButton.tag = pagingViews.indexOf(pagingView)!
        
        // Add the target for the new paging button to change the page
        pagingButton.addTarget(self, action: #selector(pagingButtonTapped(_:)), forControlEvents: .TouchUpInside)
        
        // If this is the first paging view added, update the appearance
        if pagingViewController == pagingViewControllers.first! {
            // Select the first paging button
            pagingButton.selected = true
            
            // Center the selection indicator on the first paging button
            selectionIndicatorCenterXConstraint.active = false
            selectionIndicatorCenterXConstraint = selectionIndicator.centerXAnchor.constraintEqualToAnchor(pagingButton.centerXAnchor)
            selectionIndicatorCenterXConstraint.active = true
        }
        
        // Resize the selection indicator's width based on the number of pages
        if pagingViewControllers.count > 3 {
            selectionIndicatorWidthConstraint.active = false
            // The new width is 1/n (n = the number of pages) of the paging buttons stack view
            selectionIndicatorWidthConstraint = selectionIndicator.widthAnchor.constraintEqualToAnchor(
                pagingButtonsStackView.widthAnchor, multiplier: 1/CGFloat(pagingViewControllers.count))
            // Animate the constraint change
            UIView.animateWithDuration(animationDuration, animations: {
                self.selectionIndicatorWidthConstraint.active = true
                self.layoutIfNeeded()
            })
        }
        
        // Relayout the view
        setNeedsLayout()
        
        // Signal to the paging view controller that it successfully moved to the paging controller
        pagingViewController.didMoveToPagingController(self)
    }
    
    @objc private func pagingButtonTapped(sender: UIButton) {
        // Change to that paging button's page by using the paging button's tag
        pageToIndex(sender.tag, animated: true)
        // Notify the delegates that the page has changed
        notifyPagingDelegates(pagingButtonTappedAtIndex: sender.tag)
    }
    
    internal func pageToIndex(index: Int, animated: Bool) {
        // Change the current index
        currentIndex = index
        // Update the paging buttons
        selectPagingButtonAtCurrentIndex()
        // Scroll to the new index by using the page width and new index to create a point to scroll to
        let targetOffset = CGPoint(x: CGFloat(index) * pageWidth, y: 0)
        pagingScrollView.setContentOffset(targetOffset, animated: animated)
    }
    
    private func updatePagingAfterPageChange() {
        // Determine the new index by dividing the offsetX by the page width
        // Round the offset down to decimal offsets
        let offsetX = floor(pagingScrollView.contentOffset.x)
        // We want a positive integer, so take the absolute value and cast it as an Int
        let newIndex = Int(fabs(offsetX / pageWidth))
        // Only signal that the index has change if it really did change
        if currentIndex != newIndex {
            currentIndex = newIndex
            selectPagingButtonAtCurrentIndex()
            // Notify the delegate that the page changed
            notifyPagingDelegates(pageDidChangeToPageAtIndex: currentIndex)
            // Make sure that the scrolling values for the previous page don't interfere with those of the new page
            resetScrollingValuesAfterPageChange()
        }
    }
    
    private func selectPagingButtonAtCurrentIndex() {
        // Select the current index paging button (turn it white) and deselect the rest (turn it gray)
        for (index, pagingButton) in pagingButtons.enumerate() {
            pagingButton.selected = index == currentIndex
        }
    }
    
    
    // MARK: - UIScrollView Delegate Methods
    
    private var previousOffsetX: CGFloat = 0    // keep track of the previous offset to calculate which page is being scrolled to
    
    private var previousOffsetY: CGFloat = 0    // keep track of the previous offset to calculate distance and direction
    private var scrollAmount: CGFloat = 0       // the total distance this unique swipe has travelled
    private var scrollVelocity: CGFloat = 0     // velocity helps adjust the finishing animation duration
    private var wasDraggingUp = false           // helps in determining if the scrolling direction has changed
    private var draggingUp = false              // specifies the scrolling direction
    private var topBarShouldAnimateUp = false   // tells the controller to finish animating when the swipe has ended
    private var topBarShouldAnimateDown = false // same as above
    static var topBarBarHeight: CGFloat = 91           // the height of the top bar
    static var collapsedPagingButtonScale: CGFloat = 0.9   // the collapsed scaled for the paging buttons
    var topBarAffectedByAffectingScrollViews = false    // whether the top bar should be affected (collapse) or not from affecting scroll views
    
    // TODO: Consider making these public to adjust from the outside
    private let pushPullThreshold: CGFloat = 100    // the distance the user must swipe before the top bar animates
    private let topBarUpPosition: CGFloat = -35     // the collapsed position of the top bar (distance from affine transform ty)
    private let topBarDownPosition: CGFloat = 0     // the resting position of the top bar (affine transform ty)
    
    private func resetScrollingValuesAfterPageChange() {
        previousOffsetX = 0
        // These values need to be reset after changing pages in order to animate the top bar changes correctly
        previousOffsetY = 0
        scrollAmount = 0
        scrollVelocity = 0
        wasDraggingUp = false
        draggingUp = false
        topBarShouldAnimateUp = false
        topBarShouldAnimateDown = false
    }
    
    func resetScrollingValues() {
        previousOffsetX = 0
        // Resetting scroll amount allows for each swipe to be calculated individually
        scrollAmount = 0
    }
    
    private func topBarIsInUpPosition() -> Bool {
        return topBar.transform.ty == topBarUpPosition
    }
    
    private func topBarIsInDownPosition() -> Bool {
        return topBar.transform.ty == topBarDownPosition
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        // THIS METHOD ONLY RECEIVES SCROLL EVENTS FROM THE PAGING SCROLL VIEW (HORIZONTAL)
        // Other expected scrollViewDidScroll events might be found in affectingScrollViewDidScroll()
        let offsetX = scrollView.contentOffset.x
        let totalPageWidth = scrollView.contentSize.width - pageWidth
        let percetangeScrolled = offsetX / totalPageWidth
        let firstPagingButton = pagingButtons.first!
        let lastPagingButton = pagingButtons.last!
        // TODO: Decide what to do if they are the same (potentially involve scrollView.bounces?)
        let distanceBetweenCenters = lastPagingButton.center.x - firstPagingButton.center.x
        let selectionIndicatorOffset = percetangeScrolled * distanceBetweenCenters
        selectionIndicator.transform.tx = selectionIndicatorOffset
        
        // Signal to the delegate that the page is changing
        // TODO: This is working properly when the user end dragging
        // Also signals incorrect indexes when scrolling back to 0 (reports -1)
        // We should really only signal that the view needs to load or something when the offset changes
        let draggingForward = offsetX < previousOffsetX
        let toIndex = currentIndex + (draggingForward ? -1 : 1)
        // Notify the delegates the page is changing
        notifyPagingDelegates(pageIsChangingFromPageAtIdex: currentIndex, toPageAtIndex: toIndex)
        previousOffsetX = offsetX
    }
    
    public func affectingScrollViewDidScroll(scrollView: UIScrollView) {
        if !shouldDiscardScroll(fromScrollView: scrollView) {
            scrollVelocity = scrollView.panGestureRecognizer.velocityInView(scrollView).y
            
            // Normalize the offsetY by adding the contentInset.top (sets the offsetY to 0 at original content offset)
            let offsetY = scrollView.contentOffset.y + scrollView.contentInset.top
            draggingUp = offsetY >= previousOffsetY
            let directionChanged = draggingUp != wasDraggingUp
            if directionChanged {
                // Reset the scroll amount since we're going to consider this a new swipe
                scrollAmount = 0
                // If the top bar was between its up and down position, finish the transition
                finishTopBarAnimationIfNeeded()
            }
            
            // Keep track of the amount the user has scrolled in this specific swipe
            scrollAmount += offsetY - previousOffsetY
            
            // If the top of scroll view was past the collapsed top bar and then passes it on the way down begin pulling the bar down
            // Only perform this block if the the top bar wasn't in its down position
            if offsetY < fabs(topBarUpPosition) && !topBarIsInDownPosition() {
                // Pivot between the original resting offsetY (0) and the top bar up position
                // to mimic the animation when the values aren't positive
                let offset = pivot(offsetY, between: 0, and: fabs(topBarUpPosition), clamped: true)
                beginAdjustingTopBar(withOffset: offset)
            }
            
            // If the scroll amount has passed the threshold, begin pulling/pushing the bar up/down
            if fabs(scrollAmount) > pushPullThreshold {
                // Normalize the offset by subtracting the threshold from the absolute value of the scroll amount to simplify the animation
                let offset = fabs(scrollAmount) - pushPullThreshold
                beginAdjustingTopBar(withOffset: offset)
            }
            
            // Set the "previously" values
            wasDraggingUp = draggingUp
            previousOffsetY = offsetY
        }
    }
    
    private func shouldDiscardScroll(fromScrollView scrollView: UIScrollView) -> Bool {
        // Scrolling past the bottom should be discarded, this method determines if the user has scrolled past the bottom
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.height
        // TODO: Determine if we need to account for scrollView.contentInset.bottom
        return offsetY + scrollViewHeight >= contentHeight
    }
    
    private func beginAdjustingTopBar(withOffset offset: CGFloat) {
        let animationDistance: CGFloat = 90
        
        // Notify the delegates the affecting scroll view is scrolling past the threshold
        notifyPagingDelegates(affectingScrollViewDidScrollPastThreshold: animationDistance, withOffset: offset, draggingUp: draggingUp)
        
        if !topBarAffectedByAffectingScrollViews {
            return
        }
        
        // Group One Animations - Top Bar ty, Paging Buttons scale
        let startGroupOne = draggingUp ? 0 : animationDistance
        let endGroupOne = draggingUp ? animationDistance : 0
        let pGroupOne = progress(offset, start: startGroupOne, end: endGroupOne, clamped: true)
        let tTopBarTy = transition(pGroupOne, start: topBarDownPosition, end: topBarUpPosition)
        let tButtonScale = transition(pGroupOne, start: 1, end: LFPagingController.collapsedPagingButtonScale)
        
        // Group Two Animations - Title Label alpha
        let groupTwoOffset: CGFloat = 20
        let startGroupTwo = draggingUp ? 0 : animationDistance
        let endGroupTwo = draggingUp ? animationDistance - groupTwoOffset: 0 + groupTwoOffset
        let pGroupTwo = progress(offset, start: startGroupTwo, end: endGroupTwo, clamped: true)
        let tTitleAlpha = transition(pGroupTwo, start: 1, end: 0)
        
        // Only apply the animations if the top bar is not in its up or down position
        if (draggingUp && !topBarIsInUpPosition()) ||
            (!draggingUp && !topBarIsInDownPosition()) {
            topBar.transform.ty = tTopBarTy
            for pagingButton in pagingButtons {
                pagingButton.transform = CGAffineTransformMakeScale(tButtonScale, tButtonScale)
            }
            titleLabel.alpha = tTitleAlpha
        }
        
        // Only finish the animation up or down if the bar is not in its up or down position (and depending on the dragging direction)
        topBarShouldAnimateUp = draggingUp && !topBarIsInUpPosition()
        topBarShouldAnimateDown = !draggingUp && !topBarIsInDownPosition()
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // For top bar animtions
        // Each swipe should be handled individually, so reset the values now
        resetScrollingValues()
        // This is the appropriate time to finish the top bar animations if needed
        finishTopBarAnimationIfNeeded()
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // For paging
        updatePagingAfterPageChange()
        
        // For top bar animtions
        resetScrollingValues()
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        // For paging
        updatePagingAfterPageChange()
        
        // For top bar animations
        resetScrollingValues()
    }
    
    private func finishTopBarAnimationIfNeeded() {
        // Finish animating the top bar's position at the end of swipe (if needed)
        // The duration is affected by the velocity of the swipe
        let duration: NSTimeInterval = min(0.4, Double(200 / fabs(scrollVelocity)))
        if topBarShouldAnimateDown {
            UIView.animateWithDuration(duration, delay: 0, options: [.AllowUserInteraction], animations: {
                self.topBar.transform.ty = self.topBarDownPosition
                self.titleLabel.alpha = 1
                for pagingButton in self.pagingButtons {
                    pagingButton.transform = CGAffineTransformMakeScale(1, 1)
                }
                }, completion: { _ in self.topBarShouldAnimateDown = false })
        }
        
        if topBarShouldAnimateUp {
            UIView.animateWithDuration(duration, delay: 0, options: [.AllowUserInteraction], animations: {
                self.topBar.transform.ty = self.topBarUpPosition
                self.titleLabel.alpha = 0
                for pagingButton in self.pagingButtons {
                    pagingButton.transform = CGAffineTransformMakeScale(LFPagingController.collapsedPagingButtonScale, LFPagingController.collapsedPagingButtonScale)
                }
                }, completion: { _ in self.topBarShouldAnimateUp = false })
        }
    }
    
}


