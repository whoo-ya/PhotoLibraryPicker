import UIKit

private enum DragDirection {
    case scroll
    case stop
    case up
    case down
}

/**
 Реализует сжатие переданного header при скролле CollectionView.
 */
public class HeaderMinimizeTool: NSObject, UIGestureRecognizerDelegate {
    
    private let assetViewContainerOriginalConstraintTop: CGFloat = 0
    private var dragDirection = DragDirection.up
    private var imaginaryCollectionViewOffsetStartPosY: CGFloat = 0.0
    private var cropBottomY: CGFloat  = 0.0
    private var dragStartPos: CGPoint = .zero
    private let dragDiff: CGFloat = 0
    private var isImageShown = true
    
    // The height constraint of the view with main selected image
    var topInstet: CGFloat {
        get {
            return headerViewTopConstraints.constant
        }
        set {
            if newValue >= headerViewMinimalHeight - headerView.frame.height {
                headerViewTopConstraints.constant = newValue
            }
        }
    }
    
    private let parentView: UIView
    private let headerView: UIView
    private let collectionView: UICollectionView
    private let headerViewTopConstraints: NSLayoutConstraint
    private let headerViewMinimalHeight: CGFloat
    
    init(parentView: UIView,
         headerView: UIView,
         collectionView: UICollectionView,
         headerViewTopConstraints: NSLayoutConstraint,
         headerViewMinimalHeight: CGFloat) {
        self.parentView = parentView
        self.headerView = headerView
        self.collectionView = collectionView
        self.headerViewTopConstraints = headerViewTopConstraints
        self.headerViewMinimalHeight = headerViewMinimalHeight
        
        super.init()
        
        self.registerForPanGesture(on: parentView)
    }
    
    func registerForPanGesture(on view: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        topInstet = 0
    }
    
    public func resetToOriginalState() {
        topInstet = assetViewContainerOriginalConstraintTop
        animateView()
        dragDirection = .up
    }
    
    fileprivate func animateView() {
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: [.curveEaseInOut, .beginFromCurrentState],
                       animations: {
                        self.parentView.layoutIfNeeded()
                       },
                       completion: nil)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith
                                    otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let p = gestureRecognizer.location(ofTouch: 0, in: parentView)
        // Desactivate pan on image when it is shown.
        if isImageShown {
            if p.y < headerView.frame.height {
                return false
            }
        }
        return true
    }
    
    @objc
    func panned(_ sender: UIPanGestureRecognizer) {
        
        let containerHeight = headerView.frame.height
        let currentPos = sender.location(in: parentView)
        let overYLimitToStartMovingUp = currentPos.y * 1.4 < cropBottomY - dragDiff
        
        switch sender.state {
        case .began:
            let view = sender.view
            let loc = sender.location(in: view)
            let subview = view?.hitTest(loc, with: nil)
            
            if subview == headerView
                && topInstet == assetViewContainerOriginalConstraintTop {
                return
            }
            
            dragStartPos = sender.location(in: parentView)
            cropBottomY = headerView.frame.origin.y + containerHeight
            
            // Move
            if dragDirection == .stop {
                dragDirection = (topInstet == assetViewContainerOriginalConstraintTop)
                    ? .up
                    : .down
            }
            
            // Scroll event of CollectionView is preferred.
            if (dragDirection == .up && dragStartPos.y < cropBottomY + dragDiff) ||
                (dragDirection == .down && dragStartPos.y > cropBottomY) {
                dragDirection = .stop
            }
        case .changed:
            switch dragDirection {
            case .up:
                if currentPos.y < cropBottomY - dragDiff {
                    topInstet =
                        max(headerViewMinimalHeight - containerHeight,
                            currentPos.y + dragDiff - containerHeight)
                }
            case .down:
                if currentPos.y > cropBottomY {
                    topInstet =
                        min(assetViewContainerOriginalConstraintTop, currentPos.y - containerHeight)
                }
            case .scroll:
                topInstet =
                    headerViewMinimalHeight - containerHeight
                    + currentPos.y - imaginaryCollectionViewOffsetStartPosY
            case .stop:
                if collectionView.contentOffset.y < 0 {
                    dragDirection = .scroll
                    imaginaryCollectionViewOffsetStartPosY = currentPos.y
                }
            }
            
        default:
            imaginaryCollectionViewOffsetStartPosY = 0.0
            if sender.state == UIGestureRecognizer.State.ended && dragDirection == .stop {
                return
            }
            
            if overYLimitToStartMovingUp && isImageShown == false {
                // The largest movement
                topInstet =
                    headerViewMinimalHeight - containerHeight
                animateView()
                dragDirection = .down
            } else {
                // Get back to the original position
                resetToOriginalState()
            }
        }
        
        // Update isImageShown
        isImageShown = topInstet == assetViewContainerOriginalConstraintTop
    }
}
