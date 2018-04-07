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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
        
        // Fetch Request
        let viewMOC = DataManager.sharedManager.persistentContainer.viewContext
        
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
        let sortByDate = NSSortDescriptor(key: "createdAtTI", ascending: true)
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortByDate, sortByTitle] // Ordena primero por fecha y luego por título
        
        // 4.- (Opcional) Filtrado
        let created24H = Date().timeIntervalSince1970 - 24 * 3600
        let predicate = NSPredicate(format: "createdAtTI >= %f", created24H)    // Puede usarse cualquier expresión SQL
        fetchRequest.predicate = predicate
        
        fetchRequest.fetchBatchSize = 25
        
        // 5.- Ejecutamos la request
        // try! noteList = viewMOC.fetch(fetchRequest)
        
        // 5.- Usando un Model Controller
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewMOC, sectionNameKeyPath: nil, cacheName: nil)
        
        try! fetchedResultController.performFetch()
        
        fetchedResultController.delegate = self
    }
    
//    denit {
//        if let obs = observer {
//            NotificationCenter.default.removeObserver(obs)
//        }
//    }
    
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
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
    @objc func addNewNote()  {
        // Tradicionalmente.
        let privateMOC = DataManager.sharedManager.persistentContainer.newBackgroundContext()
        
        // Asíncrono
        privateMOC.perform {
            // KVC
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: privateMOC) as! Note
            let dict = ["main_title":"Nueva nota from KVC","createdAtTI":Date().timeIntervalSince1970] as [String : Any]
            
            note.setValuesForKeys(dict)
            
            // Se guarda en Core Data
            try! privateMOC.save()
        }
        
        // Síncrono
        // privateMOC.performAndWait { }
    }
}

