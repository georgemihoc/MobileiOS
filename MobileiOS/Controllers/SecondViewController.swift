//
//  SecondViewController.swift
//  MobileiOS
//
//  Created by George on 30/07/2020.
//  Copyright © 2020 George. All rights reserved.
//

import UIKit
import IHProgressHUD

class SecondViewController: UIViewController{
    
    var name: String = ""
    var data: String = ""
    var itemId: String = ""
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var imageTake: UIImageView!
    private let imageController = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.text = name
        dateTextField.text = data
        
        
        downloadItemPicture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func downloadItemPicture() {
        IHProgressHUD.show()
        DatabaseManager.manager.getItemPicture(itemId: itemId, completion: { [weak self] result in
            guard let strongSelf = self else { return }
            switch result{
            case .success(let profilePic):
                strongSelf.imageTake.image = profilePic
            default:
                print("No image found")
            }
            IHProgressHUD.dismiss()
        })
    }
    
    


    @IBAction func cameraPressed(_ sender: Any) {
        AlertManager.manager.delegate = self
        AlertManager.manager.showPhotoAlert(currentViewController: self)
    }
   
    //MARK: - Saving Image here
    @IBAction func save(_ sender: AnyObject) {
        guard let selectedImage = imageTake.image else {
            AlertManager.manager.showGeneralAlert(currentViewController: self, title: "Error", message: "Image not found")
            return
        }
        UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @IBAction func locationButtonPressed(_ sender: UIButton) {
        NavigationManager.manager.navigateToCoordinatesViewController(currentViewController: self,itemId: itemId)
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            AlertManager.manager.showGeneralAlert(currentViewController: self, title: "Save error", message: error.localizedDescription)
        } else {
            AlertManager.manager.showGeneralAlert(currentViewController: self, title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
}

extension SecondViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else{
            print("No image selected")
            return
        }
        imageTake.image = image
        DatabaseManager.manager.deletePreviousPicture(itemId: itemId)
        DatabaseManager.manager.uploadItemPicture(image: image, itemId: itemId)
    }
}

extension SecondViewController: ServiceDelegate {
    func redirectingImagePickerController(source: UIImagePickerController.SourceType) {
        imageController.sourceType = source
        imageController.allowsEditing = true
        imageController.delegate = self
        present(imageController, animated: true)
    }
}
