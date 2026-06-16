//
//  PhotoDetailViewController.swift
//  UnoloAssignment
//
//  Created by Pratibha Rai on 16/06/26.
//

import UIKit
import SDWebImage

final class PhotoDetailViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    private let viewModel: PhotoDetailViewModel
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    var onTitleUpdated: (() -> Void)?
    var onPhotoDeleted: (() -> Void)?
    
    init(photo: PhotoEntity) {
        self.viewModel = PhotoDetailViewModel(photo: photo)
        super.init(nibName: "PhotoDetailViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        populateData()
    }
    
    private func setupUI() {
        title = "Photo Detail"
        
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.clipsToBounds = true
        photoImageView.backgroundColor = .secondarySystemBackground
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .systemGray
        photoImageView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor)
        ])
        
        titleTextField.borderStyle = .roundedRect
        titleTextField.font = .systemFont(ofSize: 15, weight: .regular)
        titleTextField.returnKeyType = .done
        titleTextField.delegate = self
        
        var saveConfig = UIButton.Configuration.filled()
        saveConfig.title = "Save"
        saveConfig.cornerStyle = .medium
        saveConfig.baseBackgroundColor = .systemBlue
        saveConfig.baseForegroundColor = .white
        saveButton.configuration = saveConfig
        
        var deleteConfig = UIButton.Configuration.filled()
        deleteConfig.title = "Delete"
        deleteConfig.cornerStyle = .medium
        deleteConfig.baseBackgroundColor = .systemRed
        deleteConfig.baseForegroundColor = .white
        deleteButton.configuration = deleteConfig
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    private func bindViewModel() {
        viewModel.onSaveSuccess = { [weak self] in
            guard let self else { return }
            self.onTitleUpdated?()
            self.navigationController?.popViewController(animated: true)
        }
        
        viewModel.onSaveError = { [weak self] message in
            guard let self else { return }
            self.showAlert(title: "Error", message: message)
        }
        
        viewModel.onDeleteSuccess = { [weak self] in
            guard let self else { return }
            self.onPhotoDeleted?()
            self.navigationController?.popViewController(animated: true)
        }
        
        viewModel.onDeleteError = { [weak self] message in
            guard let self else { return }
            self.showAlert(title: "Error", message: message)
        }
    }
    
    private func populateData() {
        titleTextField.text = viewModel.title
        activityIndicator.startAnimating()
        
        photoImageView.sd_setImage(
            with: viewModel.imageURL,
            placeholderImage: nil,
            options: [.retryFailed, .avoidAutoSetImage]
        ) { [weak self] image, _, _, _ in
            guard let self else { return }
            self.activityIndicator.stopAnimating()
            UIView.transition(
                with: self.photoImageView,
                duration: 0.2,
                options: .transitionCrossDissolve
            ) {
                self.photoImageView.image = image ?? UIImage(systemName: "photo")
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        view.endEditing(true)
        guard let text = titleTextField.text else { return }
        viewModel.saveTitle(text)
    }
    
    @IBAction func deleteTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Delete Photo", message: "Are you sure you want to delete this photo?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.viewModel.deletePhoto()
        })
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension PhotoDetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
