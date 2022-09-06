//
//  HomeViewController.swift
//  Dit
//
//  Created by 강태준 on 2022/09/05.
//

import UIKit
import SnapKit
import CoreData
import UserNotifications


final class HomeViewController: UIViewController {
    var container: NSPersistentContainer!
    private var todos = [Todo]()
    private var done = [Todo]()
    
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
        
        authorizeNotification()
        
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
        let uuid = UUID()
        
        let todo = Todos(context: container.viewContext)
        todo.text = text
        todo.isDone = false
        todo.createdAt = date
        todo.uuid = uuid
        
        searchBar.text = ""
        searchBar.becomeFirstResponder()

        do {
            try container.viewContext.save()
        } catch {
            print("ERROR: \(error.localizedDescription)")
            return
        }
        
        todos.append(Todo(text: text, isDone: false, createdAt: date, uuid: uuid))
        
        reloadTableView()
    }
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch indexPath.section {
        case 0:
            let commitAction = UIContextualAction(
                style: .normal,
                title: "commit") { action, view, handler in
                    print("hihi")
                    handler(true)
                }
            
            return UISwipeActionsConfiguration(actions: [commitAction])
        case 1:
            return nil
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            print("hihi")
        case 1:
            return
        default:
            return
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            var todo = todos[indexPath.row]
            todo.isDone = true
            
            let readRequest = NSFetchRequest<NSManagedObject>(entityName: "Todos")
            readRequest.predicate = NSPredicate(format: "uuid == %@", todo.uuid as CVarArg)
            
            do {
                let data = try container.viewContext.fetch(readRequest)
                let targetTodo = data[0]
                
                targetTodo.setValue(true, forKey: "isDone")
                
                try container.viewContext.save()
            } catch {
                print("ERROR: \(error.localizedDescription)")
                return
            }
            
            todos.remove(at: indexPath.row)
            done.append(todo)
        case 1:
            var todo = done[indexPath.row]
            todo.isDone = false
            
            let readRequest = NSFetchRequest<NSManagedObject>(entityName: "Todos")
            readRequest.predicate = NSPredicate(format: "uuid == %@", todo.uuid as CVarArg)
            
            do {
                let data = try container.viewContext.fetch(readRequest)
                let targetTodo = data[0]
                
                targetTodo.setValue(false, forKey: "isDone")
                
                try container.viewContext.save()
            } catch {
                print("ERROR: \(error.localizedDescription)")
                return
            }
            done.remove(at: indexPath.row)
            todos.append(todo)
            
        default:
            return
        }
        
        reloadTableView()
    }
}


private extension HomeViewController {
    func fetchTodos() {
        let calnedar = Calendar(identifier: .gregorian)
        let today = calnedar.startOfDay(for: Date())
        guard let tomorrow = calnedar.date(byAdding: .day, value: 1, to: today)
        else
        {
            return
        }
        
        let readTodosRequest = NSFetchRequest<NSManagedObject>(entityName: "Todos")
        readTodosRequest.predicate = NSPredicate(format: "isDone == NO")
        let todosData = try! container.viewContext.fetch(readTodosRequest)
        
        self.todos = todosData.compactMap { todo in
            guard let text = todo.value(forKey: "text") as? String,
                  let isDone = todo.value(forKey: "isDone") as? Bool,
                  let createdAt = todo.value(forKey: "createdAt") as? Date,
                  let uuid = todo.value(forKey: "uuid") as? UUID
            else {
                return nil
            }
            return Todo(text: text, isDone: isDone, createdAt: createdAt, uuid: uuid)
        }
        
        let readDoneRequest = NSFetchRequest<NSManagedObject>(entityName: "Todos")
        let todayPredicate = NSPredicate(format: "createdAt >= %@", today as CVarArg)
        let tomorrowPredicate = NSPredicate(format: "createdAt < %@", tomorrow as CVarArg)
        let isDonePredicate = NSPredicate(format: "isDone == YES")
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [todayPredicate, tomorrowPredicate, isDonePredicate])
        readDoneRequest.predicate = compound
        let doneData = try! container.viewContext.fetch(readDoneRequest)
        
        self.done = doneData.compactMap { todo in
            guard let text = todo.value(forKey: "text") as? String,
                  let isDone = todo.value(forKey: "isDone") as? Bool,
                  let createdAt = todo.value(forKey: "createdAt") as? Date,
                  let uuid = todo.value(forKey: "uuid") as? UUID
            else {
                return nil
            }
            return Todo(text: text, isDone: isDone, createdAt: createdAt, uuid: uuid)
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
    
    @objc func tapPlusButton() {
        print("hih")
    }
    
    @objc func tapBranchButton() {
        print("bebe")
    }
}
