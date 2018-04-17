//
//  NoteTableViewController.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 12/3/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import UIKit
import CoreData

let DEFAULT_NOTEBOOK_NAME = "Mi notebook"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Paso de parámetros a un selector
        let addButtonLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(selectNotebookForNewNote))
        let addButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(addNewNoteToDefault))
        let addNoteButton = UIButton(type: UIButtonType.custom)
        addNoteButton.setTitle("Add Note", for: UIControlState.normal)
        addNoteButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
        addNoteButton.addGestureRecognizer(addButtonTapGesture)
        addNoteButton.addGestureRecognizer(addButtonLongPressGesture)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addNoteButton)
        
        
        let notebookButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(showNotebooksActions))
        let manageNotebooksButton = UIButton(type: UIButtonType.custom)
        manageNotebooksButton.setTitle("Notebooks", for: UIControlState.normal)
        manageNotebooksButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
        manageNotebooksButton.addGestureRecognizer(notebookButtonTapGesture)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: manageNotebooksButton)
        
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
        //NotificationCenter.default.addObserver(tableView, selector: #selector(updateInfo), name: NSNotification(NSManagedObjectContextDidSave), object: nil)
        tableView.reloadData()
    }
    
    @objc func updateInfo() {
        // El notification center puede despachar en cualquier hilo
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
        
        if (fetchedResultController.sections != nil && fetchedResultController.sections!.count > 0) {
            for notebook in fetchedResultController.sections! {
                let notebookAction = UIAlertAction(title: notebook.name, style: .default) { (alertAction) in
                    self.addNewNote(name: notebook.name)
                }
                actionSheetAlert.addAction(notebookAction)
            }
        }
        else {
            let notebookAction = UIAlertAction(title: DEFAULT_NOTEBOOK_NAME, style: .default) { (alertAction) in
                self.addNewNote(name: DEFAULT_NOTEBOOK_NAME)
            }
            actionSheetAlert.addAction(notebookAction)
        }
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        actionSheetAlert.addAction(cancel)
        
        present(actionSheetAlert, animated: true, completion: nil)
    }
    
    @objc func addNewNoteToDefault() {
        addNewNote(name: DEFAULT_NOTEBOOK_NAME)
    }
    
    @objc func addNewNote(name: String?)  {
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        let notebookName = name ?? DEFAULT_NOTEBOOK_NAME
        
        // Asíncrono
        privateMOC.perform {
            // KVC
            // Se busca el notebook según el nombre
            let fetchRequest = NSFetchRequest<Notebook>(entityName: "Notebook")
            let notebooks: [Notebook]
            
            fetchRequest.predicate = NSPredicate(format: "name = %@", notebookName)
            
            try! notebooks = privateMOC.fetch(fetchRequest)
            
            // Si no existe el notebook asociado se aborta la acción
            if notebooks.count == 0 {
                // TODO: Mostrar mensaje a usuario
                return
            }
            
            let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into: privateMOC) as! Notebook
            let dictNoteBook = [
                "name": notebookName
                ] as [String : Any]
            notebook.setValuesForKeys(dictNoteBook)
            
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: privateMOC) as! Note
            let dict = [
                "main_title": "Nueva nota from KVC",
                "createdAtTI": Date().timeIntervalSince1970,
                "expiredAtTI": Date().timeIntervalSince1970 + EXPIRATION_DELTA,
                "notebook": notebooks.first!
                ] as [String : Any]
            note.setValuesForKeys(dict)
            
            // Se guarda en Core Data
            try! privateMOC.save()
        }
        
        // Síncrono
        // privateMOC.performAndWait { }
    }
    
    @objc func showNotebooksActions() {
        // Modal para seleccionar acciones sobre notebook
        let actionSheetAlert = UIAlertController(title: NSLocalizedString("Notebook actions", comment: "Choose notebook action"), message: nil, preferredStyle: .actionSheet)
        
        
        let newNotebookAction = UIAlertAction(title: NSLocalizedString("New Notebook", comment: "Create a new notebook"), style: .default) { (alertAction) in
            self.addNewNotebook(name: "TempName", canExist: false)
        }
        actionSheetAlert.addAction(newNotebookAction)

        let removeNotebookAction = UIAlertAction(title: NSLocalizedString("Delete Notebook", comment: "Delete a notebook"), style: .default) { (alertAction) in
            self.removeNotebook(name: "TempName")
        }
        actionSheetAlert.addAction(removeNotebookAction)
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        actionSheetAlert.addAction(cancel)
        
        present(actionSheetAlert, animated: true, completion: nil)
    }
    
    
    func addNewNotebook(name: String, canExist: Bool) {
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        let fetchRequest = NSFetchRequest<Notebook>(entityName: "Notebook")
        let notebooks: [Notebook]
        
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        try! notebooks = privateMOC.fetch(fetchRequest)
        
        // Si no existe, lo crea. Se usa el hilo principal para que espere antes de mostrar la pantalla
        if notebooks.count == 0 {
            // Asíncrono
            privateMOC.perform {
                // KVC
                let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into: privateMOC) as! Notebook
                let dictNoteBook = [
                    "name": name
                    ] as [String : Any]
                notebook.setValuesForKeys(dictNoteBook)
                
                // Se guarda en Core Data
                try! privateMOC.save()
            }
        } else if canExist {
            // TODO: Mostar notificación al usuario de que ya existe un notebook con ese nombre
        }
    }
    
    func removeNotebook(name: String) {
        let fetchRequest = NSFetchRequest<Notebook>(entityName: "Notebook")
        let notebooks: [Notebook]
        
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        
        try! notebooks = viewMOC.fetch(fetchRequest)
        
        // Si no existe, lo crea. Se usa el hilo principal para que espere antes de mostrar la pantalla
        if notebooks.count > 0 {
            if notebooks.first!.notes != nil && notebooks.first!.notes!.count > 0 {
                // TODO: Seleccionar qué hacer con las notas del notebook
            }
            
            
            // Finalmente se elimina el notebook - Asíncrono
            viewMOC.perform {
                // KVC
//                let notebook = NSEntityDescription. insertNewObject(forEntityName: "Notebook", into: self.viewMOC) as! Notebook
//                let dictNoteBook = [
//                    "name": name
//                    ] as [String : Any]
//                notebook.setValuesForKeys(dictNoteBook)
//
//                // Se guarda en Core Data
//                try! self.viewMOC.save()
            }
        }
    }
}

