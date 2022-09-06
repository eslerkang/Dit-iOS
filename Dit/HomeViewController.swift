//
//  HomeViewController.swift
//  Dit
//
//  Created by 강태준 on 2022/09/05.
//

import UIKit
import SnapKit
import CoreData


final class HomeViewController: UIViewController {
    var container: NSPersistentContainer!
    private var todos = [Todo]()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.setImage(UIImage(systemName: "arrow.up.doc"), for: .search, state: .normal)
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.placeholder = "dit add todo"
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.searchBar.delegate = self
        
        return searchController
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.container = appDelegate.persistentContainer
        
        setupNavigation()
        setupLayout()
        fetchTodos()
    }
}


extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty
        else {
            searchBar.text = ""
            return
        }
        let date = Date()
        
        let todo = Todos(context: container.viewContext)
        todo.text = text
        todo.isDone = false
        todo.createdAt = date
        
        searchBar.text = ""
        searchBar.becomeFirstResponder()

        do {
            try container.viewContext.save()
        } catch {
            print("ERROR: \(error.localizedDescription)")
            return
        }
        
        todos.append(Todo(text: text, isDone: false, createdAt: date))
        
        tableView.reloadData()
    }
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(todos.count) todos to commit"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        var content = cell.defaultContentConfiguration()
        content.text = todos[indexPath.row].text
        content.image = UIImage(systemName: todos[indexPath.row].isDone ? "circle.fill" : "circle")
        
        cell.contentConfiguration = content
        cell.selectionStyle = .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        todos.remove(at: indexPath.row)
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}


private extension HomeViewController {
    func fetchTodos() {
        let readRequest = NSFetchRequest<NSManagedObject>(entityName: "Todos")
        let data = try! container.viewContext.fetch(readRequest)
        
        self.todos = data.compactMap { todo in
            guard let text = todo.value(forKey: "text") as? String,
                  let isDone = todo.value(forKey: "isDone") as? Bool,
                  let createdAt = todo.value(forKey: "createdAt") as? Date
            else {
                return nil
            }
            
            return Todo(text: text, isDone: isDone, createdAt: createdAt)
        }
    }
    
    func setupNavigation() {
        navigationItem.title = "Todo changes"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setupLayout() {
        [
            tableView
        ].forEach {
            view.addSubview($0)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    @objc func tapPlusButton() {
        print("hih")
    }
    
    @objc func tapBranchButton() {
        print("bebe")
    }
}
