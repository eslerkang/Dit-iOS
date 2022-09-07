//
//  ProfileViewController.swift
//  Dit
//
//  Created by 강태준 on 2022/09/06.
//

import UIKit
import SnapKit
import CoreData


final class ProfileViewController: UIViewController {
    var container: NSPersistentContainer!
    var context: NSManagedObjectContext!
    
    private var contributions = [Int]()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private lazy var monthLabel: UILabel = {
        let label = UILabel()
        label.text = "Your contributions in this month"
        label.font = .systemFont(ofSize: 20, weight: .regular)
        
        return label
    }()
    
    private lazy var monthCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(ContributionCollectionViewCell.self, forCellWithReuseIdentifier: "collectionViewCell")
        
        return collectionView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 8
        
        monthCollectionView.snp.makeConstraints {
            $0.height.equalTo((view.frame.width - 40) / 7 * 5.1)
        }
        
        [
            monthLabel,
            monthCollectionView
        ].forEach {
            stackView.addArrangedSubview($0)
        }
        
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        container = appDelegate.persistentContainer
        context = container.viewContext
        
        setupNavigation()
        setupLayout()
    }
}


extension ProfileViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 35
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as? ContributionCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        
        cell.setup()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        return CGSize(width: width, height: width)
    }
}


private extension ProfileViewController {
    func fetchData() {
        
    }
    
    func setupNavigation() {
        navigationItem.title = "Contributions"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupLayout() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
    }
}
