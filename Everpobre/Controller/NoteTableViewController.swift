//
//  NoteTableViewController.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 12/3/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import UIKit
import CoreData

let DEFAULT_NOTE_NAME = "My note"
let DEFAULT_NOTEBOOK_NAME = "My notebook"
let EXPIRATION_DELTA: Double = 60 * 60 * 24 * 30


// Delegado para comunicar este VC con el VC del detalle de la nota
protocol NoteTableViewControllerDelegate: class {
    // should, will, did
    func notesTableViewController(_ vc: NoteTableViewController, didSelectNote: Note)
}

class NoteTableViewController: UITableViewController {
    
    var fetchedResultController: NSFetchedResultsController<Note>!
    weak var delegate: NoteTableViewControllerDelegate?
    
    // Fetch Request
    let viewMOC = DataManager.sharedManager.persistentContainer.viewContext
    
    init() {
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        title = "Notes"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDefaultNotebook()
        
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")

        let sectionSort = NSSortDescriptor(key: "notebook.name", ascending: true)
        let noteSortByTitle = NSSortDescriptor(key: "title", ascending: true)
        let noteSortByDate = NSSortDescriptor(key: "createdAtTI", ascending: true)
        fetchRequest.sortDescriptors = [sectionSort, noteSortByTitle, noteSortByDate] // Ordena secciones por el nombre del notebook y las notas primero por fecha y luego por título
        
        fetchRequest.fetchBatchSize = 25
        
        fetchedResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewMOC,
            sectionNameKeyPath: "notebook.name",
            cacheName: nil)
        
        try! fetchedResultController.performFetch()
        
        fetchedResultController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isToolbarHidden = false
        let closeButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showNotebooksActions))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let addButtonLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(selectNotebookForNewNote))
        let addButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(addNewNoteToDefault))
        let addNoteButton = UIButton(type: UIButtonType.contactAdd)
        addNoteButton.addGestureRecognizer(addButtonTapGesture)
        addNoteButton.addGestureRecognizer(addButtonLongPressGesture)

        self.setToolbarItems([closeButton, flexibleSpace, UIBarButtonItem(customView: addNoteButton)], animated: false)
        
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
        
        cell?.textLabel?.text = fetchedResultController.object(at: indexPath).title
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Se obtiene la nota seleccionada
        let note = fetchedResultController.object(at: indexPath)
        
        // Usando splitViewController
        // Se notifica la nueva nota seleccionada en la lista de notas
        delegate?.notesTableViewController(self, didSelectNote: note)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultController.sections![section].name
    }
}

extension NoteTableViewController: NSFetchedResultsControllerDelegate {
    // Se ejecutará cuando hay cambios en el Core Data (mediante un save)
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
    
    @objc func selectNotebookForNewNote()  {
        // Modal para seleccionar el notebook
        let actionSheetAlert = UIAlertController(title: NSLocalizedString("Choose Notebook", comment: "Choose notebook to add a new note"), message: nil, preferredStyle: .actionSheet)
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        let notebooks = Notebook.notebooks(in: privateMOC)
        
        if (notebooks.fetchedObjects != nil && notebooks.fetchedObjects!.count > 0) {
            for notebook in notebooks.fetchedObjects! {
                let notebookAction = UIAlertAction(title: notebook.name, style: .default) { (alertAction) in
                    self.addNewNote(notebookId: notebook.objectID)
                }
                actionSheetAlert.addAction(notebookAction)
            }
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        actionSheetAlert.addAction(cancel)
        
        present(actionSheetAlert, animated: true, completion: nil)
    }
    
    @objc func addNewNoteToDefault() {
        let noteMapping = NoteMapping(title: DEFAULT_NOTE_NAME,
                                      content: "",
                                      createdAtTI: Date().timeIntervalSince1970,
                                      expiredAtTI: Date().timeIntervalSince1970 + EXPIRATION_DELTA)
        Note.add(noteMapping: noteMapping, in: nil)
    }
    
    @objc func addNewNote(notebookId: NSManagedObjectID)  {
        let noteMapping = NoteMapping(title: DEFAULT_NOTE_NAME,
                                      content: "",
                                      createdAtTI: Date().timeIntervalSince1970,
                                      expiredAtTI: Date().timeIntervalSince1970 + EXPIRATION_DELTA)
        Note.add(noteMapping: noteMapping, in: notebookId)
    }
    
    @objc func showNotebooksActions() {
        let notebooksVC = NotebookTableViewController()
        notebooksVC.didClose = {
            do {
                try self.fetchedResultController.performFetch()
            } catch { }
            
            self.tableView.reloadData()
        }
        
        let navNotebooksVC = notebooksVC.wrappedInNavigation()
        navNotebooksVC.modalPresentationStyle = .overCurrentContext
        
        self.present(navNotebooksVC, animated: true, completion: nil)
    }
    
    
    func createDefaultNotebook() {
        let notebook = Notebook.currentDefault(in: nil)

        // Si no existe, lo crea
        if notebook == nil {
            Notebook.add(name: DEFAULT_NOTEBOOK_NAME, isDefault: true)
        }
    }
}

