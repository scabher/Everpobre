//
//  NotebookTableViewController.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 18/4/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import UIKit
import CoreData

class NotebookTableViewController: UITableViewController {
    
    var fetchedResultController: NSFetchedResultsController<Notebook>!
    // Fetch Request
    let viewMOC = DataManager.sharedManager.persistentContainer.viewContext
    
    init() {
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        title = "Notebooks"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultController = Notebook.notebooks(in: viewMOC)
        fetchedResultController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isToolbarHidden = false
        let button = UIButton(type: .custom)
        button.setTitle("Add note", for: .normal)
        button.setTitleColor(view.tintColor, for: .normal)
        let addNoteButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        self.setToolbarItems([addNoteButton], animated: false)
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultController.sections!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultController.sections![section].numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
        }
        
        let notebook = fetchedResultController.object(at: indexPath)
        cell?.textLabel?.text = notebook.name
        
        return cell!
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let notebook = fetchedResultController.object(at: indexPath)
        if editingStyle == .delete {
            removeNotebook(notebook: notebook)
            //tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension NotebookTableViewController: NSFetchedResultsControllerDelegate {
    // Se ejecutará cuando hay cambios en el Core Data (mediante un save)
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

/*
 * Notebook UI actions
 */
extension NotebookTableViewController {
    @objc func close() {
        self.dismiss(animated: true) {
            do {
                try self.fetchedResultController.performFetch()
            } catch { }
        }
    }
    
    func removeNotebook(notebook: Notebook) {
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        if notebook.notes != nil && notebook.notes!.count > 0 {
            
        }
        
        Notebook.remove(name: notebook.name!, in: privateMOC)
        do {
            try self.fetchedResultController.performFetch()
            tableView.reloadData()
        } catch  { }
    }
}
