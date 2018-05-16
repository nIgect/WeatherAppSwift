//
//  HistoryTableViewController.swift
//  NiblSoftTestWork
//
//  Created by Kiryl Bukinevich on 4/18/18.
//  Copyright © 2018 Kiryl Bukinevich. All rights reserved.
//

import UIKit
import CoreData



class HistoryTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "History of search"
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreDataManager.shared.requests.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryTableViewCell
        let requsest = CoreDataManager.shared.requests[indexPath.row]
        
        cell?.cityLabel.text = requsest.city
        
        let tempString = NSString(format:"%.f",requsest.weather - 273)
        cell?.weatherLabel.text = " \(tempString) C"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        if let  currentDate = requsest.date{
            dateFormatter.dateFormat = "hh:mm dd-MM-yyyy"
            
            
            print(dateFormatter.string(from: (currentDate)))
            cell?.dateLabel.text = dateFormatter.string(from: (currentDate))
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92
    }
    
}

