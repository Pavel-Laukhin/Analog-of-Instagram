//
//  TableViewController.swift
//  Course2FinalTask
//
//  Created by Павел on 06.07.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import DataProvider

class TableViewController: UITableViewController {
    
    var lastSelectedRow: IndexPath?
    var currentlySelectedRow: IndexPath?
    
    var users: [User]
    
    // Настраиваем инициализатор, чтобы при инициализации передавался массив юзеров. Без этого массива нам табличный контроллер не нужен:
    init(users: [User], title: String) {
        self.users = users
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Регистрируем ячейку:
        tableView.register(TableViewCell.self, forCellReuseIdentifier: String(describing: TableViewCell.self))
    }
    
    // MARK: - Table view data source
    
    // Устанавливаем 1 секцию:
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    // Устанавливаем количество строк, равное количеству юзеров в массиве юзеров:
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
    }
    
    // Устанавливаем многоразовую ячейку:
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = (tableView.dequeueReusableCell(withIdentifier: String(describing: TableViewCell.self), for: indexPath) as? TableViewCell) else { return UITableViewCell() }
        
        // Configure the cell...
        cell.user = users[indexPath.row]
        
        return cell
    }
    
    // Устанавливаем высоту строки, равную 45 поинтов:
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Сохраняем позицию выбранной строки:
        currentlySelectedRow = indexPath
        
        // Делаем так, чтобы подсветка строки не выключалась сама по себе:
        clearsSelectionOnViewWillAppear = false
        
        // Пушим контроллер с профилем пользователя:
        navigationController?.pushViewController(ProfileViewController(user: users[indexPath.row]), animated: true)
    }
    
    // Делаем так, чтобы подсветка строки не сразу исчезала, а с задержкой:
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let row = currentlySelectedRow {
            tableView.deselectRow(at: row, animated: true)
        }
    }
    
}


