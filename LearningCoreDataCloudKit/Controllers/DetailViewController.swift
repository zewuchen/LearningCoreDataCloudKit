//
//  DetailViewController.swift
//  LearningCoreDataCloudKit
//
//  Created by Zewu Chen on 02/04/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

    @IBOutlet weak var txtNome: UITextField!
    @IBOutlet weak var txtCurso: UITextField!

    var managedObjectContext: NSManagedObjectContext!
    var materia: Materia!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let materia = self.materia else { return }

        self.txtNome.text = materia.nome
        self.txtCurso.text = materia.curso
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        if self.materia == nil {
            self.materia = (NSEntityDescription.insertNewObject(forEntityName: Materia.entityName, into: self.managedObjectContext) as! Materia)
        }

        self.materia.nome = self.txtNome.text
        self.materia.curso = self.txtCurso.text

        do {
            try self.managedObjectContext.save()
            _ = self.navigationController?.popViewController(animated: true)
        } catch {
            print("Não foi possível salvar")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.managedObjectContext.rollback()
    }

}
