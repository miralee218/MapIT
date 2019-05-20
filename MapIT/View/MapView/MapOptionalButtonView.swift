//
//  MapOptionalButtonView.swift
//  MapIT
//
//  Created by Mira on 2019/5/13.
//  Copyright © 2019 AppWork. All rights reserved.
//

import UIKit

class MapOptionalButtonView: UIView {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var addRecordButton: UIButton!
    @IBOutlet weak var moreOptionButton: UIButton!
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var listRecordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    var checkInButtonCenter: CGPoint!
    var pauseButtonCenter: CGPoint!
    var listRecordButtonCenter: CGPoint!
    var stopButtonCenter: CGPoint!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    private func commonInit() {
        Bundle.main.loadNibNamed("MapOptionalButtonView", owner: self, options: nil)
        addSubview(containerView)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        checkInButtonCenter = offset(byDistance: 100, inDirection: 270)
        pauseButtonCenter = offset(byDistance: 100, inDirection: 240)
        listRecordButtonCenter = offset(byDistance: 100, inDirection: 210)
        stopButtonCenter = offset(byDistance: 100, inDirection: 180)
        checkInButton.center = moreOptionButton.center
        pauseButton.center = moreOptionButton.center
        listRecordButton.center = moreOptionButton.center
        stopButton.center = moreOptionButton.center
        
    }
    private func offset(byDistance distance: CGFloat, inDirection degrees: CGFloat) -> CGPoint {
        let radians = degrees * .pi / 180
        let vertical = sin(radians) * distance
        let horizontal = cos(radians) * distance
        let position = CGPoint(x: moreOptionButton.center.x + horizontal, y: moreOptionButton.center.y + vertical)
        return position
    }
    
    @IBAction func addNewRecord(_ sender: Any) {
        addRecordButton.alpha = 0
        moreOptionButton.alpha = 1
    }
    @IBAction func viewMoreOption(_ sender: UIButton) {
        if moreOptionButton.currentImage == UIImage(named: ImageAsset.Icons_StartRecord.rawValue)! {
            buttonAppearAnimation(optionalButton: checkInButton, center: checkInButtonCenter, withDuration: 0.15)
            buttonAppearAnimation(optionalButton: pauseButton, center: pauseButtonCenter, withDuration: 0.3)
            buttonAppearAnimation(optionalButton: listRecordButton, center: listRecordButtonCenter, withDuration: 0.45)
            buttonAppearAnimation(optionalButton: stopButton, center: stopButtonCenter, withDuration: 0.6)
        } else {
            buttonDisappearAnimation(optionalButton: checkInButton,
                                     centerButton: moreOptionButton,
                                     withDuration: 0.2)
            buttonDisappearAnimation(optionalButton: pauseButton,
                                     centerButton: moreOptionButton,
                                     withDuration: 0.4)
            buttonDisappearAnimation(optionalButton: listRecordButton,
                                     centerButton: moreOptionButton,
                                     withDuration: 0.6)
            buttonDisappearAnimation(optionalButton: stopButton,
                                     centerButton: moreOptionButton,
                                     withDuration: 0.8)
        }
        toggleButton(button: sender, onImage: UIImage(named: ImageAsset.Icons_Mapping_Selected.rawValue
            )!, offImage: UIImage(named: ImageAsset.Icons_StartRecord.rawValue)!)
    }
    private func animation(withDuration: Double, action: @escaping () -> Void) {
        UIView.animate(withDuration: withDuration, animations: {
            action()
            self.containerView.layoutIfNeeded()
        })
    }
    private func buttonAppearAnimation(optionalButton: UIButton, center: CGPoint, withDuration: Double) {
        animation(withDuration: withDuration) {
            optionalButton.alpha = 1
            optionalButton.center = center
        }
    }
    private func buttonDisappearAnimation(optionalButton: UIButton, centerButton: UIButton, withDuration: Double) {
        animation(withDuration: withDuration) {
            optionalButton.alpha = 0
            optionalButton.center = centerButton.center
        }
    }
    private func toggleButton(button: UIButton, onImage: UIImage, offImage: UIImage) {
        if button.currentImage == offImage {
            button.setImage(onImage, for: .normal)
        } else {
            button.setImage(offImage, for: .normal)
        }
    }
    @IBAction func checkIn(_ sender: Any) {
    }
    @IBAction func pauseRecord(_ sender: Any) {
    }
    @IBAction func viewList(_ sender: Any) {
    }
    @IBAction func saveRecord(_ sender: Any) {
    }
    
}
