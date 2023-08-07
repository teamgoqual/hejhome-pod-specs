//
//  CameraVideoView.swift
//  ThingSmartDeviceKitCameraSDKSampleApp
//
//  Created by Dasom Kim on 2023/04/03.
//

import Foundation
import ThingSmartCameraKit

class CameraVideoView: (UIView & ThingSmartVideoViewType), UIScrollViewDelegate {
    private var lastScale: CGFloat = 1.0
    let scrollView = UIScrollView()
    
    private var _renderView: (UIView & ThingSmartVideoViewType)?
    var renderView: (UIView & ThingSmartVideoViewType)? {
        get {
            return _renderView
        }
        set {
            guard let renderView = newValue else { return }
            _renderView = renderView
            
            setupScrollView()

            renderView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                renderView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                renderView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                renderView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                renderView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                renderView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                renderView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            ])
            
//            let widthConstraint = renderView.widthAnchor.constraint(equalTo: renderView.heightAnchor, multiplier: 16.0 / 9.0)
//            widthConstraint.priority = .defaultHigh
//
//            NSLayoutConstraint.activate([
//                renderView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
//                renderView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
//                renderView.widthAnchor.constraint(lessThanOrEqualTo: scrollView.widthAnchor),
//                renderView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
//                widthConstraint
//            ])
            
//            renderView.thing_setRotate?(90.0)
//            setupGestureRecognizers()
        }
    }
    
    var scaleToFill: Bool {
        get {
            ((self.renderView?.scaleToFill) != nil)
        }
        set {
            
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if scrollView.zoomScale == 1.0 {
            scrollView.zoomScale = 1.0
            scrollView.contentOffset = .zero
            scrollView.contentSize = bounds.size
        }
    }
    
    private func setupScrollView() {
        guard let renderView = renderView else { return }
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.bounces = false
        
        scrollView.addSubview(renderView)
        addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            scrollView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
        ])
        
        
        scrollView.contentSize = renderView.frame.size
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return renderView
    }
    
    func thing_setScaled(_ scaled: Float) {
        renderView?.thing_setScaled(scaled)
    }
    
    func thing_setOffset(_ offset: CGPoint) {
        renderView?.thing_setOffset(offset)
    }
    
    func thing_clear() {
        renderView?.thing_clear()
    }
    
    func screenshot() -> UIImage! {
        renderView?.screenshot()
    }
    
    func rotate(_ angle: Float) {
        renderView?.thing_setRotate?(angle)
    }
}
