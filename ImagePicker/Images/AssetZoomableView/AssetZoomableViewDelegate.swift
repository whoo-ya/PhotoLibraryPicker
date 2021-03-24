import Foundation

public protocol AssetZoomableViewDelegate: class {
    func assetZoomableViewDidLayoutSubviews(_ zoomableView: AssetZoomableView)
    func assetZoomableViewScrollViewDidZoom()
    func assetZoomableViewScrollViewDidEndZooming()
}
