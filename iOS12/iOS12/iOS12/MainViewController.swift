//
//  MainViewController.swift
//  iOS12
//
//  Created by CXY on 2019/5/5.
//  Copyright © 2019 cxy. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
    private lazy var items: [[String: String]] = {
        let arr = [["title": "ARKit 2", "description": "Multiuser and Persistent AR, Object Detection"],
                   ["title": "Siri Shortcuts", "description": ""],
                   ["title": "Interactive Controls in Notifications", "description": "Notification content app extensions now support user interactivity in custom views."],
                   ["title": "Network Framework", "description": "Easier way to create network connections"],
                   ["title": "Natural Language", "description": "Analyze natural language text and deduce metadata."]
        ]
        return arr
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "iOS12 New Features"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]["title"]
        cell.detailTextLabel?.text = items[indexPath.row]["description"]
        return cell
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if 4 == indexPath.row {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NL")
            navigationController?.pushViewController(vc, animated: true)
        } else if 3 == indexPath.row {
            navigationController?.pushViewController(NetworkViewController(), animated: true)
        } else if 2 == indexPath.row {
            navigationController?.pushViewController(CustomNotificationUIViewController(), animated: true)
        } else if 1 == indexPath.row {
            navigationController?.pushViewController(ShortcutsViewController(), animated: true)
        }
    }

}
