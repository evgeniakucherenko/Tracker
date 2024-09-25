//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 24.09.2024.
//

import UIKit

final class OnboardingViewController: UIViewController,
                                      UIPageViewControllerDataSource,
                                      UIPageViewControllerDelegate {
    
    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .black
        return pageControl
    }()
    
    private var pages = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPages()
        setupPageViewController()
        setupPageControl()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else {
            return nil
        }
        
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < pages.count - 1 else {
            return nil
        }
        
        return pages[currentIndex + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, 
            let currentViewController = pageViewController.viewControllers?.first,
            let currentIndex = pages.firstIndex(of: currentViewController) {
                pageControl.currentPage = currentIndex
            }
    }
    
    private func setupPageViewController() {
        
        pageControl.numberOfPages = pages.count
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        for view in pageViewController.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.isScrollEnabled = true
                scrollView.delaysContentTouches = false
                scrollView.canCancelContentTouches = true
                scrollView.panGestureRecognizer.cancelsTouchesInView = false
            }
        }
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
                pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        if let firstPage = pages.first {
            pageViewController.setViewControllers(
                [firstPage],
                direction: .forward,
                animated: true, completion: nil
            )
        }
    }
    
    private func setupPages() {
        let page1 = OnboardingPageViewController(
            imageName: "onboardingBlue",
            text: "Отслеживайте только то, что хотите"
        )
        
        let page2 = OnboardingPageViewController(
            imageName: "onboardingRed",
            text: "Даже если это не литры воды и йога"
        )
        
        pages = [page1, page2]
    }
    
    private func setupPageControl() {
        view.addSubview(pageControl)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -135),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func finishOnboarding() {

        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        
        if let window = view.window {
            let mainViewController = TabBarController()
            window.rootViewController = mainViewController
            window.makeKeyAndVisible()
        } else {
            print("Не удалось получить window из view.window")
        }
    }
}

