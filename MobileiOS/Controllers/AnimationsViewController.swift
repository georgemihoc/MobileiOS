//
//  AnimationsViewController.swift
//  MobileiOS
//
//  Created by George on 04.01.2021.
//

import UIKit

class AnimationsViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var overrideAnimationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func groupedAnimationButtonPressed(_ sender: UIButton) {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath:
        "transform.rotation.y")
        rotation.toValue = 0
        rotation.fromValue = 2.61

        //Scale animation
        let scale: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        scale.toValue = 1
        scale.fromValue = 0

        //Adding animations to group
        let group = CAAnimationGroup()
        group.animations = [rotation,scale]
        group.duration = 5

        imageView.layer.add(group, forKey: nil)
    }
    
    @IBAction func shakeHead(_ sender: UIButton) {
        
        
        UIView.animate(
            withDuration: 0.75,
            animations: {
                self.imageView.transform = self.imageView.transform.rotated(by: 45)
        },
            completion:{ finished in
                if(finished){
                    UIView.animate(
                        withDuration: 1,
                        animations: {
                            self.imageView.transform = self.imageView.transform.rotated(by: -(45)*2)
                    },
                        completion:{ finished in
                            if(finished){
                                UIView.animate(
                                    withDuration: 0.75,
                                    animations: {
                                        self.imageView.transform = self.imageView.transform.rotated(by: 45)
                                },
                                    completion: { finished in
                                        // replay the animation
//                                        self.shakeHead(sender)
                                }
                                )
                            }
                    }
                    )
                }
        }
        )
    }
}
