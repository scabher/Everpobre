//
//  NotebookTableViewController.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 18/4/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import UIKit
import CoreData

typealias DidClose = ()->()

class NotebookTableViewController: UITableViewController {
    
    var fetchedResultController: NSFetchedResultsController<Notebook>!
    var didClose: DidClose?
    
    // Fetch Request
    let viewMOC = DataManager.sharedManager.persistentContainer.viewContext
    
    
    init() {
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        
        title = "Notebooks"
        tableView.register(UINib.init(nibName: "NotebookTableViewCell", bundle: nil), forCellReuseIdentifier: "notebookCellReuseId")
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
        let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let addNotebookButton = UIButton(type: UIButtonType.contactAdd)
        addNotebookButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addNotebook)))

        self.setToolbarItems([closeButton, flexibleSpace, UIBarButtonItem(customView:  addNotebookButton)], animated: false)
        
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
        let notebook = fetchedResultController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "notebookCellReuseId") as? NotebookTableViewCell ?? NotebookTableViewCell()
        
        cell.notebook = notebook
        cell.nameTextField.text = notebook.name
        cell.isDefaultSwitch.isOn = notebook.isDefault
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let notebook = fetchedResultController.object(at: indexPath)
        if editingStyle == .delete {
            if (notebook.isDefault) {
                notifyUser(title: "Default notebook", message: "The selected notebook is set as defaul and cannot be removed", buttonText: "Ok")
                return
            }
            
            removeNotebook(notebook: notebook)
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
        dismiss(animated: true) {
            guard let done = self.didClose else { return }
            done()
        }
    }
    
    @objc func addNotebook() {
        Notebook.add(name: "New Notebook", isDefault: false)
    }
    
    func removeNotebook(notebook: Notebook) {
        if notebook.notes == nil || notebook.notes!.count == 0 {
            Notebook.remove(id: notebook.objectID, in: nil)
            return
        }
        
        selectNotebookToMoveNotes(from: notebook.objectID)
    }
    
    func selectNotebookToMoveNotes(from sourceId: NSManagedObjectID)  {
        // Modal para seleccionar el notebook
        let actionSheetAlert = UIAlertController(title: NSLocalizedString("Choose Notebook", comment: "Choose notebook to move notes"), message: nil, preferredStyle: .actionSheet)
        let notebooks = Notebook.notebooks(in: nil)
        
        if (notebooks.fetchedObjects != nil && notebooks.fetchedObjects!.count > 0) {
            for notebook in notebooks.fetchedObjects! {
                if (notebook.objectID != sourceId) {
                    let notebookAction = UIAlertAction(title: notebook.name, style: .default) { (alertAction) in
                        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
                        Notebook.moveNotes(from: sourceId, to: notebook.objectID, in: privateMOC)
                        Notebook.remove(id: sourceId, in: privateMOC)
                    }
                    actionSheetAlert.addAction(notebookAction)
                }
            }
        }
        
        let removeAllNotes = UIAlertAction(title: NSLocalizedString("Remove all notes", comment: "Remove all notes from source notebook"), style: .destructive) { (alertAction) in
            Notebook.remove(id: sourceId, in: nil)
        }
        actionSheetAlert.addAction(removeAllNotes)
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .default, handler: nil)
        actionSheetAlert.addAction(cancel)
        
        present(actionSheetAlert, animated: true, completion: nil)
    }
}
