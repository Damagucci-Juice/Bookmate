//
//  ViewController.swift
//  Bookmate
//
//  Created by Gucci on 3/20/26.
//

import UIKit
import SwiftUI

// MARK: - HomeViewController

class ViewController: UIViewController {

    private let viewModel = HomeViewModel()
    private var hostingController: UIHostingController<HomeView>!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCallbacks()
        setupHostingController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.loadQuotes()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Setup

    private func setupHostingController() {
        let homeView = HomeView(viewModel: viewModel)
        hostingController = UIHostingController(rootView: homeView)
        hostingController.view.backgroundColor = AppColor.bg
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingController.didMove(toParent: self)
    }

    private func setupCallbacks() {
        viewModel.onQuoteTapped = { [weak self] index in
            self?.openCardCustomization(at: index)
        }
        viewModel.onSeeAllTapped = { [weak self] in
            let vc = QuoteListViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        viewModel.onEmptyCtaTapped = { [weak self] in
            self?.presentBookSelection()
        }
    }

    // MARK: - Navigation

    private func openCardCustomization(at index: Int) {
        let loadedQuotes = viewModel.loadedQuotes
        guard index < loadedQuotes.count else { return }

        let quote = loadedQuotes[index]
        guard let book = quote.book else { return }
        let tags = Array(quote.tags.map { $0.name })
        let page = quote.pageNumber.map { String($0) }

        let vc = CardCustomizationViewController(
            quoteText: quote.text,
            book: book,
            page: page,
            tags: tags,
            isExistingQuote: true,
            cardStyle: quote.cardStyle,
            quoteId: quote.id
        )
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    private func presentBookSelection() {
        let bookSelection = BookSelectionViewController()
        bookSelection.onBookSelected = { [weak self] book in
            self?.presentAddQuoteSheet(for: book)
        }
        let nav = UINavigationController(rootViewController: bookSelection)
        present(nav, animated: true)
    }

    private func presentAddQuoteSheet(for book: Book) {
        let sheet = AddQuoteSheetViewController()

        sheet.onCameraScanTapped = { [weak self] in
            guard let self else { return }
            let vc = CameraCaptureViewController(book: book)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            nav.setNavigationBarHidden(true, animated: false)
            self.present(nav, animated: true)
        }

        sheet.onManualEntryTapped = { [weak self] in
            guard let self else { return }
            let vc = ManualQuoteEntryViewController(book: book)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .pageSheet
            self.present(nav, animated: true)
        }

        if let presentationController = sheet.sheetPresentationController {
            presentationController.detents = [.custom { _ in 250 }]
            presentationController.prefersGrabberVisible = true
            presentationController.preferredCornerRadius = 24
        }

        present(sheet, animated: true)
    }
}
