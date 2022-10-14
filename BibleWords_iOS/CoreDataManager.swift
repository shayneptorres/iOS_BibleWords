//
//  CoreDataManager.swift
//  MyMinistryPeople
//
//  Created by Shayne Torres on 6/8/21.
//

import Foundation
import CoreData
import SwiftUI

class CoreDataManager {    
    static func transaction(context: NSManagedObjectContext, completion: (() -> Void)?) {
        context.perform {
            completion?()

            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
