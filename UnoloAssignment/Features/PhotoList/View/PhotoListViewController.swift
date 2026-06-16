//
//  PhotoListViewController.swift
//  UnoloAssignment
//
//  Created by Hitesh Sapraon 16/06/26.
//

import UIKit

class PhotoListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyTitleLabel: UILabel!
    @IBOutlet weak var emptyRetryButton: UIButton!
    
    private let viewModel = PhotoListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        bindViewModel()
        viewModel.loadInitialData()
    }
    
    private func setupUI() {
        title = "Photos"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        
        showEmptyState(false)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 76, bottom: 0, right: 0)
        
        let nib = UINib(nibName: "PhotoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: PhotoCell.reuseIdentifier)
    }
    
    private func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            switch state {
            case .idle:
                break
            case .loading:
                self.activityIndicator.startAnimating()
                self.tableView.isHidden = true
                self.showEmptyState(false)
            case .loaded:
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
                self.showEmptyState(false)
            case .error(let message):
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = true
                self.showEmptyState(true, title: "Something went wrong", subtitle: message, showRetry: true)
            case .empty:
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = true
                self.showEmptyState(true, title: "No Photos", subtitle: "No photos available at the moment.", showRetry: false)
            }
        }
        
        viewModel.onPhotosUpdated = { [weak self] in
            guard let self else { return }
            self.tableView.reloadData()
        }
    }
    
    private func showEmptyState(_ show: Bool, title: String = "", subtitle: String = "", showRetry: Bool = false) {
        emptyTitleLabel.isHidden = !show
        emptyRetryButton.isHidden = !show || !showRetry
        
        if show {
            emptyTitleLabel.text = title
        }
    }
    
    @IBAction func retryTapped(_ sender: UIButton) {
        viewModel.refresh()
    }
}

extension PhotoListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.photoCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as! PhotoCell
        cell.configure(with: viewModel.photo(at: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let alert = UIAlertController(title: "Delete Photo", message: "Are you sure you want to delete this photo?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            self.viewModel.deletePhoto(at: indexPath.row) { success in
                if success {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        })
        
        present(alert, animated: true)
    }
}

extension PhotoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let photo = viewModel.photo(at: indexPath.row)
        let detailVC = PhotoDetailViewController(photo: photo)
        
        detailVC.onTitleUpdated = { [weak self] in
            guard let self else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        detailVC.onPhotoDeleted = { [weak self] in
            guard let self else { return }
            self.viewModel.deletePhotoFromDetail(at: indexPath.row) { success in
                if success {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - frameHeight - 100 {
            viewModel.loadNextPage()
        }
    }
}
