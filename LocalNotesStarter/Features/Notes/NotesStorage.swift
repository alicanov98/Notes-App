//
//  NotesStorage.swift
//  LocalNotesStarter
//
//  Created by Malik Alijanov on 02.08.26.
//


import Foundation

protocol NotesStoring {
    func loadNotes() throws -> [Note]
    func saveNotes(_ notes: [Note]) throws
}

final class LocalNotesStorage: NotesStoring {

    // MARK: - Properties

    private var notesFileURL: URL {
        let documentsFolder = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        return documentsFolder.appendingPathComponent("notes.json")
    }

    // MARK: - Load Notes

    func loadNotes() throws -> [Note] {
        guard FileManager.default.fileExists(
            atPath: notesFileURL.path
        ) else {
            return []
        }

        let data = try Data(contentsOf: notesFileURL)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode([Note].self, from: data)
    }

    // MARK: - Save Notes

    func saveNotes(_ notes: [Note]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(notes)

        try data.write(
            to: notesFileURL,
            options: .atomic
        )
    }
}
