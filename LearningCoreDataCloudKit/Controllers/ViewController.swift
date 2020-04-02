//
//  ViewController.swift
//  LearningCoreDataCloudKit
//
//  Created by Zewu Chen on 02/04/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController<Materia>!
    var materiaToDelete: Materia?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        configureFetchedResultsController()

        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Não foi possível buscar os dados")
        }
    }

    func configureFetchedResultsController() {
        let materiaFetchRequest = NSFetchRequest<Materia>(entityName: "Materia")
        let primarySortDescriptor = NSSortDescriptor(key: "nome", ascending: true)
        materiaFetchRequest.sortDescriptors = [primarySortDescriptor]

        self.fetchedResultsController = NSFetchedResultsController<Materia>(
            fetchRequest: materiaFetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)

        self.fetchedResultsController.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       guard let editorVC = segue.destination as? DetailViewController else { return }
       editorVC.managedObjectContext = self.managedObjectContext

       if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
           let selectedMateria = self.fetchedResultsController.object(at: selectedIndexPath)
           editorVC.materia = selectedMateria
       }
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }

        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }

        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let materia = fetchedResultsController.object(at: indexPath)

        cell.textLabel?.text = materia.nome
        cell.detailTextLabel?.text = materia.curso

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let materia = fetchedResultsController.object(at: indexPath)
            self.materiaToDelete = materia
            self.managedObjectContext.delete(self.materiaToDelete!)

            do {
                try self.managedObjectContext.save()
            } catch {
                self.managedObjectContext.rollback()
                print("Não conseguiu deletar, erro: \(error)")
            }
        }
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let insertIndexPath = newIndexPath {
                self.tableView.insertRows(at: [insertIndexPath], with: .fade)
            }
        case .delete:
            if let deleteIndexPath = indexPath {
                self.tableView.deleteRows(at: [deleteIndexPath], with: .fade)
            }
        case .update:
            if let updateIndexPath = indexPath {
                let cell = self.tableView.cellForRow(at: updateIndexPath)
                let updatedMateria = self.fetchedResultsController.object(at: updateIndexPath)

                cell?.textLabel?.text = updatedMateria.nome
                cell?.detailTextLabel?.text = updatedMateria.curso
            }
        case .move:
            if let deleteIndexPath = indexPath {
                self.tableView.deleteRows(at: [deleteIndexPath], with: .fade)
            }

            if let insertIndexPath = newIndexPath {
                self.tableView.insertRows(at: [insertIndexPath], with: .fade)
            }
        @unknown default:
            fatalError()
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        let sectionIndexSet = NSIndexSet(index: sectionIndex) as IndexSet

        switch type {
        case .insert:
            self.tableView.insertSections(sectionIndexSet, with: .fade)
        case .delete:
            self.tableView.deleteSections(sectionIndexSet, with: .fade)
        default:
            break
        }
    }
}
