//
//  NoteTableViewController.swift
//  Everpobre
//
//  Created by Sergio Cabrera Hernández on 12/3/18.
//  Copyright © 2018 Sergio Cabrera Hernández. All rights reserved.
//

import UIKit
import CoreData

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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
        
        // Si no existe el notebook 'Default' lo crea
        createDefaultNotebook()
        
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
    
    @objc func addNewNote()  {
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        // Asíncrono
        privateMOC.perform {
            // KVC
            let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into: privateMOC) as! Notebook
            let dictNoteBook = [
                "name": "Mi notebook"
            ] as [String : Any]
            notebook.setValuesForKeys(dictNoteBook)
            
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: privateMOC) as! Note
            let dict = [
                "main_title": "Nueva nota from KVC",
                "createdAtTI": Date().timeIntervalSince1970,
                "notebook": notebook
            ] as [String : Any]
            note.setValuesForKeys(dict)

            // Se guarda en Core Data
            try! privateMOC.save()
        }
        
        // Síncrono
        // privateMOC.performAndWait { }
    }
    

    func createDefaultNotebook() {
        let fetchRequest = NSFetchRequest<Notebook>(entityName: "Notebook")
        let defaultNotebook: [Notebook]
        
        fetchRequest.predicate = NSPredicate(format: "name = %@", "Mi notebook")

        try! defaultNotebook = viewMOC.fetch(fetchRequest)
        
        // Si no existe, lo crea. Se usa el hilo principal para que espere antes de mostrar la pantalla
        if defaultNotebook.count == 0 {
            // Asíncrono
            viewMOC.performAndWait {
                // KVC
                let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into: self.viewMOC) as! Notebook
                let dictNoteBook = [
                    "name": "Default"
                    ] as [String : Any]
                notebook.setValuesForKeys(dictNoteBook)
                
                // Se guarda en Core Data
                try! self.viewMOC.save()
            }
        }
    }
}

