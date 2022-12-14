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
    
    private var contributions = [ContributionEntity]()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private lazy var monthLabel: UILabel = {
        let label = UILabel()
        label.text = "Your this month's contributions"
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
        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        container = appDelegate.persistentContainer
//        context = container.viewContext
        container = PersistenceController.shared.container
        context = container.viewContext
        
        setupNavigation()
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }
}


extension ProfileViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contributions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as? ContributionCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        
        cell.setup(contribution: contributions[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let contribution = contributions[indexPath.row]
        let date = dateToSting(date: contribution.date)
        let message = "\(date)\n\(contribution.commit) commits"
        
        showToast(
            message: message,
            font: .systemFont(ofSize: 16, weight: .regular)
        )
    }
}


private extension ProfileViewController {
    func fetchData() {
        let calendar = Calendar(identifier: .gregorian)
        let today = calendar.startOfDay(for: Date())
        
        contributions = []
        
        for i in 0..<35 {
            guard let startDate = calendar.date(byAdding: .day, value: -34+i, to: today),
                  let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)
            else {
                return
            }
            let readRequest = NSFetchRequest<NSManagedObject>(entityName: "Todos")
            
            let isDonePredicate = NSPredicate(format: "isDone == YES")
            let startDatePredicate = NSPredicate(format: "updatedAt >= %@", startDate as CVarArg)
            let endDatePredicate = NSPredicate(format: "updatedAt < %@", endDate as CVarArg)
            
            readRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [isDonePredicate, startDatePredicate, endDatePredicate])
            
            let data = try! context.fetch(readRequest)
            
            contributions.append(ContributionEntity(date: startDate, commit: data.count))
        }
        monthCollectionView.reloadData()
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
    
    func showToast(message : String, font: UIFont) {
        let toastLabel = UILabel()
        
        toastLabel.backgroundColor = UIColor.label.withAlphaComponent(0.5)
        toastLabel.textColor = UIColor.systemBackground
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 2
        
        view.addSubview(toastLabel)
        toastLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(100)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
            $0.width.equalTo(150)
        }
        
        UIView.animate(withDuration: 2.0, delay: 0.5, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }
    
    func dateToSting(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "yyyy-MM-dd(E)"
        
        return formatter.string(from: date)
    }
}
