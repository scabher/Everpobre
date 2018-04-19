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
protocol NotesTableViewControllerDelegate: class {
    // should, will, did
    func notesTableViewController(_ vc: NotesTableViewController, didSelectNote: Note)
}

class NotesTableViewController: UITableViewController {
    
    // var noteList:[Note] = []  // Se sustituye por fetchedResultController
    // var observer: NSObjectProtocol?
    
    var fetchedResultController: NSFetchedResultsController<Note>!
    weak var delegate: NotesTableViewControllerDelegate?
    
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
        
        // TODO: Paso de parámetros a un selector
//        let addButtonLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(selectNotebookForNewNote))
//        let addButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(addNewNoteToDefault))
//        let addNoteButton = UIButton(type: UIButtonType.custom)
//        addNoteButton.setTitle("Add Note", for: UIControlState.normal)
//        addNoteButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
//        addNoteButton.addGestureRecognizer(addButtonTapGesture)
//        addNoteButton.addGestureRecognizer(addButtonLongPressGesture)
//        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addNoteButton)
//        
//        
//        let notebookButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(showNotebooksActions))
//        let manageNotebooksButton = UIButton(type: UIButtonType.custom)
//        manageNotebooksButton.setTitle("Notebooks", for: UIControlState.normal)
//        manageNotebooksButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
//        manageNotebooksButton.addGestureRecognizer(notebookButtonTapGesture)
//        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: manageNotebooksButton)
        
        //(barButtonSystemItem: .add, target: self, action: #selector(addNewNoteInDefault))
        // navigationItem.rightBarButtonItem?.customView = addNoteButton
        
        // Si no existe el notebook 'Default' lo crea
        addNewNotebook(name: DEFAULT_NOTEBOOK_NAME, canExist: true)
        
        // Forma antigua
        // 1.- Creamos el objeto
        //let fetchRequest = NSFetchRequest<Note>()
        
        // 2.- Qué entidad es de la que queremos objetos
        //fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Note", in: viewMOC)
        
        // Variante
        //let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        
        // Otra variante más
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        
        // 3.- (Opcional) Indicamos orden
        let sectionSort = NSSortDescriptor(key: "notebook.name", ascending: true)
        let noteSortByTitle = NSSortDescriptor(key: "title", ascending: true)
        let noteSortByDate = NSSortDescriptor(key: "createdAtTI", ascending: true)
        fetchRequest.sortDescriptors = [sectionSort, noteSortByTitle, noteSortByDate] // Ordena secciones por el nombre del notebook y las notas primero por fecha y luego por título
        
        fetchRequest.fetchBatchSize = 25
        
        // 5.- Usando un Model Controller
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

extension NotesTableViewController: NSFetchedResultsControllerDelegate {
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
                    self.addNewNote(notebookName: alertAction.title!)
                }
                actionSheetAlert.addAction(notebookAction)
            }
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        actionSheetAlert.addAction(cancel)
        
        present(actionSheetAlert, animated: true, completion: nil)
    }
    
    @objc func addNewNoteToDefault() {
        addNewNote(notebookName: DEFAULT_NOTEBOOK_NAME)
    }
    
    @objc func addNewNote(notebookName: String)  {
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        Note.add(name: DEFAULT_NOTE_NAME, in: notebookName, using: privateMOC)
    }
    
    @objc func showNotebooksActions() {
        let notebooksVC = NotebookTableViewController()
        notebooksVC.dismiss(animated: true) {
            try! self.fetchedResultController.performFetch()
            self.tableView.reloadData()
        }
        
        let navNotebooksVC = notebooksVC.wrappedInNavigation()
        navNotebooksVC.modalPresentationStyle = .overCurrentContext
        
        self.present(navNotebooksVC, animated: true, completion: nil)
        
//        // Modal para seleccionar acciones sobre notebook
//        let actionSheetAlert = UIAlertController(title: NSLocalizedString("Notebook actions", comment: "Choose notebook action"), message: nil, preferredStyle: .actionSheet)
//
//
//        let newNotebookAction = UIAlertAction(title: NSLocalizedString("New Notebook", comment: "Create a new notebook"), style: .default) { (alertAction) in
//            self.addNewNotebook(name: "TempName", canExist: false)
//        }
//        actionSheetAlert.addAction(newNotebookAction)
//
//        let removeNotebookAction = UIAlertAction(title: NSLocalizedString("Delete Notebook", comment: "Delete a notebook"), style: .default) { (alertAction) in
//            self.removeNotebook(name: "Mi notebook")
//        }
//        actionSheetAlert.addAction(removeNotebookAction)
//
//        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
//        actionSheetAlert.addAction(cancel)
//
//        present(actionSheetAlert, animated: true, completion: nil)
    }
    
    
    func addNewNotebook(name: String, canExist: Bool) {
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        let notebook = Notebook.named(name: name, in: privateMOC)

        // Si no existe, lo crea. Se usa el hilo principal para que espere antes de mostrar la pantalla
        if notebook == nil {
            Notebook.add(name: name, in: privateMOC)
            showAlert(title: "Notebook created", message: "The notebook was created successfuly", buttonText: "Ok")
        } else if !canExist {
            showAlert(title: "Notebook not created", message: "This notebook name already exists", buttonText: "Ok")
        }
    }
    
   
    func showAlert(title: String, message: String, buttonText: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancel = UIAlertAction(title: buttonText, style: .default, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

