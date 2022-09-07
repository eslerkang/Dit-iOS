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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        container = appDelegate.persistentContainer
        context = container.viewContext
    }
}
