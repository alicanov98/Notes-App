//
//  AddNotesViewModel.swift
//  LocalNotesStarter
//
//  Created by Malik Alijanov on 02.08.26.
//

import Foundation

final class AddNotesViewModel  {
    
    //MARK: - Outputs
    
    var onNoteCreated:((Note) -> Void)?
    var onError:((String) -> Void)?
    
    // MARK: - Actions
    
    func saveNote(title:String?,text:String?){
        let trimedTitle = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trimedText = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !trimedTitle.isEmpty else {
            onError?("Enter a title before saving.")
            return
        }
    
        let note = Note(
            id: UUID(),
            title: trimedTitle,
            text: trimedText,
            createdAt: Date()
        )
        
        onNoteCreated?(note)
    }
}
