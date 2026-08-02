import UIKit

final class NotesViewController: UIViewController {

    // MARK: - Properties
    
    private let viewModel: NotesViewModelProtocol
    
    
    // MARK: - UI Components

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No notes yet"
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Initialization
    
    init(viewModel: NotesViewModelProtocol){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureBindings()
        viewModel.loadNotes()
    }

    private func configureUI() {
        title = "Notes"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTapped)
        )

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NoteCell.self, forCellReuseIdentifier: NoteCell.reuseIdentifier)

        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        updateEmptyState()
    }


    private func configureBindings(){
        viewModel.onNotesChange = { [weak self] in
            guard let self else {return}
            
            self.tableView.reloadData()
            self.updateEmptyState()
        }
        
        viewModel.onError = { [weak self] message in
            self?.showAlert(title: "Error", message: message)
        }
    }
    
    // MARK: - UI Updates
    
    private func updateEmptyState(){
        emptyLabel.isHidden = !viewModel.isEmpty
    }
    
    // MARK: - Actions
    
    @objc
    private func addTapped(){
        let addNotesViewModel = AddNotesViewModel()
        
        let controller = AddNoteViewController(viewModel: addNotesViewModel)
        
        controller.delegate = self
        
        navigationController?.pushViewController(controller,animated: true)
    }
    
}


// MARK: - UITableViewDataSource


extension NotesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfNotes
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NoteCell.reuseIdentifier,
            for: indexPath
        ) as? NoteCell else {
            return UITableViewCell()
        }
        
        let note = viewModel.note(at: indexPath.row)
        cell.configure(with: note)
        return cell
    }
}


// MARK: - UITableViewDelegate


extension NotesViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }
            self.viewModel.deleteNote(at: indexPath.row)
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - AddNoteViewControllerDelegate


extension NotesViewController: AddNoteViewControllerDelegate {
    func addNoteViewController(_ controller: AddNoteViewController, didCreate note: Note) {
        viewModel.addNote(note)
    }
}
