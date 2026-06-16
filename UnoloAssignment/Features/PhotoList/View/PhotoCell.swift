//
//  PhotoCell.swift
//  UnoloAssignment
//
//  Created by Hitesh Sapraon 16/06/26.
//

import UIKit
import SDWebImage

final class PhotoCell: UITableViewCell {
    
    static let reuseIdentifier = "PhotoCell"
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.sd_cancelCurrentImageLoad()
        thumbnailImageView.image = nil
        titleLabel.text = nil
        activityIndicator.startAnimating()
    }
    
    private func setupUI() {
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 8
        thumbnailImageView.backgroundColor = .secondarySystemBackground
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        thumbnailImageView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor)
        ])
        
        titleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .label
    }
    
    func configure(with photo: PhotoEntity) {
        titleLabel.text = photo.title
        activityIndicator.startAnimating()
        
        guard let url = URL(string: photo.thumbnailUrl ?? "") else {
            activityIndicator.stopAnimating()
            thumbnailImageView.image = UIImage(systemName: "photo")
            return
        }
        
        thumbnailImageView.sd_setImage(
            with: url,
            placeholderImage: nil,
            options: [.retryFailed, .avoidAutoSetImage]
        ) { [weak self] image, _, _, _ in
            guard let self else { return }
            self.activityIndicator.stopAnimating()
            UIView.transition(
                with: self.thumbnailImageView,
                duration: 0.2,
                options: .transitionCrossDissolve
            ) {
                self.thumbnailImageView.image = image ?? UIImage(systemName: "photo")
            }
        }
    }
}
