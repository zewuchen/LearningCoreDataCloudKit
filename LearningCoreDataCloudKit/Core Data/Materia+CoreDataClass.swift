//
//  Materia+CoreDataClass.swift
//  LearningCoreDataCloudKit
//
//  Created by Zewu Chen on 02/04/20.
//  Copyright © 2020 Zewu Chen. All rights reserved.
//

import Foundation
import CoreData


public class Materia: NSManagedObject {
    @NSManaged public var nome: String?
    @NSManaged public var curso: String?

    static var entityName: String { return "Materia" }
}
