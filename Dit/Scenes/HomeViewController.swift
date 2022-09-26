//
//  HomeViewController.swift
//  Dit
//
//  Created by 강태준 on 2022/09/05.
//

import UIKit
import UserNotifications

import SnapKit
import CodableFirebase
import FirebaseAuth
import FirebaseFirestore


final class HomeViewController: UIViewController {
    private let db = Firestore.firestore()
    private var user: User?
    
    private var todos = [Todo]()
    private var done = [Todo]()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.setImage(UIImage(systemName: "arrow.up.doc"), for: .search, state: .normal)
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.placeholder = "dit add todo"
        searchController.obscuresBackgroundDuringPresentation = false
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
        
        authorizeNotification()
        
        setupNavigation()
        setupLayout()
        fetchTodos()
    }
}


extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let user = Auth.auth().currentUser,
              let text = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty
        else {
            searchController.isActive = false
            return
        }
        let date = Date()
        let uuid = UUID()
        
        let todo = Todo(
            text: text,
            isDone: false,
            createdAt: date,
            updatedAt: date,
            userId: user.uid,
            uuid: uuid.uuidString
        )
        
        let todoData = try! FirestoreEncoder().encode(todo)
        
        db.collection("todos").document(uuid.uuidString).setData(todoData) { error in
            if let error {
                print("ERROR: \(error.localizedDescription)")
            }
        }
 
        view.endEditing(true)
       
        todos.append(todo)
        
        searchController.isActive = false
        reloadTableView()
    }
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let date = Date()

        switch indexPath.section {
        case 0:
            let commitAction = UIContextualAction(
                style: .normal,
                title: "commit") { action, view, handler in
                    var todo = self.todos[indexPath.row]
                    todo.isDone = true
                    todo.updatedAt = date
                
                    self.updateTodo(todo: todo)
                
                    self.todos.remove(at: indexPath.row)
                    self.done.append(todo)
                    
                    self.reloadTableView()
                    
                    handler(true)
                }
            
            return UISwipeActionsConfiguration(actions: [commitAction])
        case 1:
            let resetAction = UIContextualAction(
                style: .destructive,
                title: "reset") { action, view, handler in
                    var todo = self.done[indexPath.row]

                    todo.isDone = false
                    todo.updatedAt = date
                    
                    self.updateTodo(todo: todo)
                    
                    self.done.remove(at: indexPath.row)
                    self.todos.append(todo)
                    
                    self.reloadTableView()
                    handler(true)
                }
            
            return UISwipeActionsConfiguration(actions: [resetAction])
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section == 0 {
            return .delete
        }
        
        return .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let todo = todos[indexPath.row]
            
            self.db.collection("todos").document(todo.uuid).delete()
            
            todos.remove(at: indexPath.row)
            reloadTableView()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
             return todos.count
        case 1:
             return done.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "\(todos.count) todos to commit"
        case 1:
            return "\(done.count) commits today"
        default:
            return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        switch(indexPath.section) {
        case 0:
            var content = cell.defaultContentConfiguration()
            content.text = todos[indexPath.row].text
            content.image = UIImage(systemName: "circle")
            
            cell.contentConfiguration = content
        case 1:
            var content = cell.defaultContentConfiguration()
            content.text = done[indexPath.row].text
            content.image = UIImage(systemName: "circle.fill")
            
            cell.contentConfiguration = content
        default:
            return cell
        }
        
        cell.selectionStyle = .none

        return cell
    }
}


private extension HomeViewController {
    func updateTodo(todo: Todo) {
        let todoData = try! FirestoreEncoder().encode(todo)
        db.collection("todos").document(todo.uuid).setData(todoData) { error in
            if let error {
                print("ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchTodos() {
        let calnedar = Calendar(identifier: .gregorian)
        let today = calnedar.startOfDay(for: Date())
        guard let tomorrow = calnedar.date(byAdding: .day, value: 1, to: today),
              let user = Auth.auth().currentUser
        else {
            return
        }
        
        db.collection("todos")
            .whereField("isDone", isEqualTo: false)
            .whereField("userId", isEqualTo: user.uid)
            .getDocuments { querySnapshot, error in
                if let error {
                    print("ERROR: \(error.localizedDescription)")
                }
                
                guard let snapshot = querySnapshot
                else {
                    print("ERROR: Fetching snapshots")
                    return
                }
                
                let documents = snapshot.documents
                
                self.todos = documents.compactMap { document in
                    var data = document.data()
                    
                    guard let updatedAt = data["updatedAt"] as? Timestamp,
                            let createdAt = data["createdAt"] as? Timestamp
                    else {
                        return nil
                    }
                    data["updatedAt"] = updatedAt.dateValue()
                    data["createdAt"] = createdAt.dateValue()
                    
                    do {
                        return try FirestoreDecoder().decode(Todo.self, from: data)
                    } catch {
                        print("ERROR: \(error.localizedDescription)")
                        return nil
                    }
                }
                
                self.reloadTableView()
            }
                
        db.collection("todos")
            .whereField("isDone", isEqualTo: true)
            .whereField("userId", isEqualTo: user.uid)
            .whereField("updatedAt", isGreaterThanOrEqualTo: today)
            .whereField("updatedAt", isLessThan: tomorrow)
            .getDocuments { querySnapshot, error in
                if let error {
                    print("ERROR: \(error.localizedDescription)")
                }
                guard let snapshot = querySnapshot
                else {
                    print("ERROR: Fetching snapshots")
                    return
                }
                
                let documents = snapshot.documents
                
                self.done = documents.compactMap { document in
                    var data = document.data()
                    
                    guard let updatedAt = data["updatedAt"] as? Timestamp,
                            let createdAt = data["createdAt"] as? Timestamp
                    else {
                        return nil
                    }
                    data["updatedAt"] = updatedAt.dateValue()
                    data["createdAt"] = createdAt.dateValue()

                    do {
                        return try FirestoreDecoder().decode(Todo.self, from: data)
                    } catch {
                        print("ERROR: \(error.localizedDescription)")
                        return nil
                    }
                    
                }
                self.reloadTableView()
            }

        reloadTableView()
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
    
    func reloadTableView() {
        tableView.reloadData()
        UIApplication.shared.applicationIconBadgeNumber = todos.count        
    }
    
    func authorizeNotification() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.badge], completionHandler: { _, error in
                if let error = error {
                    print("ERROR: \(error.localizedDescription)")
                }
            })
    }
}
