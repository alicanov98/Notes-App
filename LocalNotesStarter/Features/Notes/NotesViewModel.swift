//
//  NotesViewModel.swift
//  LocalNotesStarter
//
//  Created by Malik Alijanov on 02.08.26.
//


import Foundation

protocol NotesViewModelProtocol:AnyObject {
    
    var onNotesChange: (() -> Void)? {get set}
    var onError: ((String) -> Void)? {get set}
    
    var numberOfNotes: Int {get}
    var isEmpty: Bool {get}
    
    func loadNotes()
    func note(at index: Int) -> Note
    func addNote(_ note: Note)
    func deleteNote(at index: Int)
}

final class NotesViewModel: NotesViewModelProtocol {
    
    // MARK: - Properties
    
    private(set) var notes: [Note] = []
    private let storage: NotesStoring
    
    // MARK: - Outputs
    
    var onNotesChange: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Computed Properties
    
    var numberOfNotes: Int {
        notes.count
    }
    
    var isEmpty: Bool {
        notes.isEmpty
    }
    
    // MARK: - Initialization
    
    init(storage: NotesStoring) {
        self.storage = storage
    }
    
    //MARK: - Public Methods
    
    func loadNotes(){
        do{
            notes = try storage.loadNotes()
            onNotesChange?()
        }catch{
            onError?("Notes cloud not be loaded: \(error.localizedDescription)")
        }
    }
    
    func note(at index: Int) -> Note {
        notes[index]
    }
    
    func addNote(_ note:Note){
        notes.append(note)
        
        do {
            try storage.saveNotes(notes)
            onNotesChange?()
        }catch {
            notes.removeLast()
            onError?("Note cloud not be saved \(error.localizedDescription)")
        }
    }
    
    func deleteNote(at index: Int) {
        guard notes.indices.contains(index) else {
            return
        }
        
        let deleteNote = notes.remove(at: index)
        
        do {
            try storage.saveNotes(notes)
            onNotesChange?()
        }catch {
            notes.insert(deleteNote, at: index)
            onError?("Note cloud not be deleted: \(error.localizedDescription)")
        }
    }
    

    
}
