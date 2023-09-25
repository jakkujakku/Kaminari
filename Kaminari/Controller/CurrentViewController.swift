//
//  CurrentViewController.swift
//  Kaminari
//
//  Created by (^ㅗ^)7 iMac on 2023/09/25.
//

import SnapKit
import UIKit

class CurrentViewController: UIViewController {
    var collectionView = CustomCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    var currentThumbnailWeatherList: [CurrentWeatherMockup] = CurrentWeatherMockup.weatherList
    var currentTimelyWeatherList: [CurrentWeatherMockup] = CurrentWeatherMockup.weatherList
    var currentWeatherList: [CurrentWeatherMockup] = CurrentWeatherMockup.weatherList
        
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    deinit {
        print("### ViewController deinitialized")
    }
}

extension CurrentViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
}

extension CurrentViewController {
    func setupUI() {
        view.backgroundColor = .systemBackground
        self.configureCollectionView()
        self.collectionView.collectionViewLayout = self.createLayout()
        createDataSource()
        applySnapshot()
        registerCollectionViewCell()
    }
}

extension CurrentViewController {
    func configureCollectionView() {
        view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    func registerCollectionViewCell() {
        self.collectionView.register(CurrentThumbnailCell.self, forCellWithReuseIdentifier: CurrentThumbnailCell.identifier)
        self.collectionView.register(CurrentTimelyCell.self, forCellWithReuseIdentifier: CurrentTimelyCell.identifier)
        self.collectionView.register(CurrentWeatherCell.self, forCellWithReuseIdentifier: CurrentWeatherCell.identifier)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }
            let section: NSCollectionLayoutSection
                
            if sectionKind == .currentThumbnailWeatherList {
                let itemSize = self.collectionView.configureSectionItemSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = self.collectionView.configureSectionItem(layoutSize: itemSize)
                item.contentInsets = self.collectionView.configureContentInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                    
//                let groupHeight = NSCollectionLayoutDimension.absolute(150)
                let groupSize = self.collectionView.configureSectionItemSize(widthDimension: .fractionalWidth(0.95), heightDimension: .fractionalHeight(0.6))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                    
                section = NSCollectionLayoutSection(group: group)
                    
                section.interGroupSpacing = 0
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.contentInsets = self.collectionView.configureContentInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                    
            } else if sectionKind == .currentTimelyWeatherList {
                let itemSize = self.collectionView.configureSectionItemSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = self.collectionView.configureSectionItem(layoutSize: itemSize)
                item.contentInsets = self.collectionView.configureContentInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                    
//                let groupHeight = NSCollectionLayoutDimension.absolute(150)
                let groupSize = self.collectionView.configureSectionItemSize(widthDimension: .fractionalWidth(0.95), heightDimension: .fractionalHeight(0.3))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                    
                section = NSCollectionLayoutSection(group: group)
                    
                section.interGroupSpacing = 0
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.contentInsets = self.collectionView.configureContentInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                  
            } else if sectionKind == .currentWeatherList {
                let itemSize = self.collectionView.configureSectionItemSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = self.collectionView.configureSectionItem(layoutSize: itemSize)
                item.contentInsets = self.collectionView.configureContentInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                    
                let groupHeight = NSCollectionLayoutDimension.absolute(150)
                let groupSize = self.collectionView.configureSectionItemSize(widthDimension: .fractionalWidth(0.95), heightDimension: .fractionalHeight(0.8))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                    
                section = NSCollectionLayoutSection(group: group)
                    
                section.interGroupSpacing = 0
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.contentInsets = self.collectionView.configureContentInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                    
            } else {
                fatalError("Unknown section!")
            }
            return section
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    func createDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: self.collectionView) { (collectionView, indexPath, _) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { fatalError() }
            
            switch section {
            case .currentThumbnailWeatherList:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentThumbnailCell", for: indexPath) as? CurrentThumbnailCell else { preconditionFailure() }
                cell.backgroundColor = .systemRed
                return cell
                
            case .currentTimelyWeatherList:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentTimelyCell", for: indexPath) as? CurrentTimelyCell else { preconditionFailure() }
                cell.backgroundColor = .systemBlue
                return cell
                
            case .currentWeatherList:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentWeatherCell", for: indexPath) as? CurrentWeatherCell else { preconditionFailure() }
                cell.backgroundColor = .systemGreen
                return cell
            }
        }
    }
        
    func applySnapshot() {
        let sections = Section.allCases
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(sections)

        let currentThumbnailItem = self.currentThumbnailWeatherList.map { Item(currentThumbnailWeatherList: $0) }
        var firstSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        firstSnapshot.append(currentThumbnailItem)
                
        let currentTimelyItems = self.currentTimelyWeatherList.map { Item(currentTimelyWeatherList: $0) }
        var secondSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        secondSnapshot.append(currentTimelyItems)
                
        let currentWeatherItems = self.currentWeatherList.map { Item(currentWeatherList: $0) }
        var thirdSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        thirdSnapshot.append(currentWeatherItems)
                
        self.dataSource.apply(firstSnapshot, to: .currentThumbnailWeatherList, animatingDifferences: false)
        self.dataSource.apply(secondSnapshot, to: .currentTimelyWeatherList, animatingDifferences: false)
        self.dataSource.apply(thirdSnapshot, to: .currentWeatherList, animatingDifferences: false)
    }
}