# PhotoGallery

An iOS application built as part of a technical assessment. Fetches photos from a REST API with pagination, persists them locally using Core Data, and allows users to edit titles and delete records.

---

## Requirements

- Xcode 15+
- iOS 15.0+
- Swift 5.9+
- Internet connection on first launch

---

## Setup

1. Clone the repository
2. Open `PhotoGallery.xcodeproj`
3. SDWebImage is integrated via Swift Package Manager — dependencies resolve automatically on first build
4. Select a simulator or device and hit Run

No additional configuration needed.

---

## Project Structure

```
PhotoGallery/
├── App/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
│
├── Core/
│   ├── CoreData/
│   │   ├── PhotoGallery.xcdatamodeld
│   │   ├── CoreDataStack.swift
│   │   ├── PhotoEntity+CoreDataClass.swift
│   │   └── PhotoRepository.swift
│   ├── Network/
│   │   ├── NetworkService.swift
│   │   └── APIEndpoint.swift
│   └── PageTracker.swift
│
├── Features/
│   ├── PhotoList/
│   │   ├── Model/
│   │   │   └── Photo.swift
│   │   ├── ViewModel/
│   │   │   └── PhotoListViewModel.swift
│   │   └── View/
│   │       ├── PhotoListViewController.swift
│   │       ├── PhotoListViewController.xib
│   │       ├── PhotoCell.swift
│   │       └── PhotoCell.xib
│   └── PhotoDetail/
│       ├── ViewModel/
│       │   └── PhotoDetailViewModel.swift
│       └── View/
│           ├── PhotoDetailViewController.swift
│           └── PhotoDetailViewController.xib
│
└── Resources/
    └── Assets.xcassets
```

---

## Architecture

**MVVM** with closure-based bindings. No third-party architecture frameworks or reactive libraries.

```
NetworkService  ──►  PhotoRepository  ──►  PhotoListViewModel  ──►  PhotoListViewController
                          │                                                    │
                    CoreDataStack                                      PhotoDetailViewController
                                                                               │
                                                                     PhotoDetailViewModel
                                                                               │
                                                                       PhotoRepository
```

ViewModels expose state via closures (`onStateChange`, `onPhotosUpdated`, etc). ViewControllers bind to these in `viewDidLoad` and update UI accordingly. ViewModels have zero UIKit imports.

---

## Features

### Pagination
Photos are fetched from the API page by page (20 records per page) as the user scrolls. Each page is saved to Core Data immediately after fetching. On subsequent launches, pages already fetched are loaded directly from Core Data without hitting the network again.

Page tracking is handled by `PageTracker` which persists fetched page numbers in `UserDefaults`. This ensures a page is never re-fetched from the API, even across app restarts.

### Offline First / Core Data as Source of Truth
Core Data is always the source of truth for what is displayed. The API is only consulted when a page has not been fetched before. User edits (title updates, deletions) are persisted to Core Data immediately and are never overwritten by subsequent API fetches.

### Deduplication
Before saving any API response to Core Data, all existing record IDs are loaded into a `Set<Int64>` and checked against incoming records. Records already present are skipped, preventing duplicates even in edge cases.

### Image Loading
SDWebImage handles async image loading and disk/memory caching. Each cell cancels its in-flight image request in `prepareForReuse` to prevent image flickering during fast scrolls. A `UIActivityIndicatorView` is shown while the image loads, replacing the typical placeholder approach for a cleaner experience.

### Edit Title
Tapping any photo opens the detail screen with the full-size image and an editable title field. Saving updates Core Data immediately and reflects the change back in the list via a callback closure.

### Delete
Photos can be deleted via swipe-to-delete on the list or via the Delete button on the detail screen. A confirmation alert is shown before deletion. The list updates immediately in both cases. Deleted records are never re-fetched from the API since page tracking is based on page number, not record count.

### Error Handling
Network failures surface a user-readable error message with a Retry button. Core Data errors are handled gracefully with a rollback on failure. An empty state is shown if no records exist.

---

## Known Limitations & Assumptions

### Image URLs
The API response from `jsonplaceholder.typicode.com/photos` returns image URLs pointing to `via.placeholder.com`, which has been defunct for some time. As a workaround, image URLs are substituted at save time with equivalent URLs from [picsum.photos](https://picsum.photos), using the photo's `id` as a seed value to ensure each photo gets a consistent and unique image across launches.

| | Example |
|---|---|
| Original thumbnail | `https://via.placeholder.com/150/92c952` |
| Replaced thumbnail | `https://picsum.photos/seed/1/150/150` |
| Original full image | `https://via.placeholder.com/600/92c952` |
| Replaced full image | `https://picsum.photos/seed/1/600/600` |

This substitution happens in `PhotoRepository.savePhotos()` before Core Data persistence and has no effect on the rest of the app's logic.

### First Launch
On first launch the app fetches the first page from the API, saves it to Core Data, and displays it. Subsequent pages are fetched on demand as the user scrolls. A loading indicator is shown during the initial fetch.

### Delete and Re-fetch
Deleting a record removes it from Core Data permanently. Since page tracking is based on page number (not record count), the deleted record's page is never re-fetched from the API, so the deletion is permanent across sessions.

---

## Dependencies

| Library | Version | Purpose | Integration |
|---|---|---|---|
| SDWebImage | 5.x | Async image loading and caching | Swift Package Manager |

---

## API Reference

| Property | Value |
|---|---|
| Endpoint | `https://jsonplaceholder.typicode.com/photos` |
| Pagination | `?_page=1&_limit=20` |
| Method | GET |
| Total Records | 5000 |

