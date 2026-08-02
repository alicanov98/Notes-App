import UIKit


protocol AddNoteViewControllerDelegate: AnyObject {
    func addNoteViewController(
        _ controller: AddNoteViewController,
        didCreate note: Note
    )
}

final class AddNoteViewController: UIViewController {
    
    // MARK: - Delegate
    
    weak var delegate: AddNoteViewControllerDelegate?
    
    // MARK: - Properties
    
    private let addNotesViewModel: AddNotesViewModel
    
    
    // MARK: - UI Components
    
    private let titleField: UITextField = {
        let field = UITextField()
        field.placeholder = "Title"
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let textView: UITextView = {
        let view = UITextView()
        view.font = .preferredFont(forTextStyle: .body)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.separator.cgColor
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()



    // MARK: - Initialization
    
    init(viewModel:AddNotesViewModel) {
        self.addNotesViewModel = viewModel
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
    }
    
    // MARK: - Configuration
    
    private func configureUI() {
        title = "New Note"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(saveTapped)
        )

        view.addSubview(titleField)
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            textView.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
            textView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }

    private func configureBindings() {
        addNotesViewModel.onNoteCreated = { [weak self] note in
            guard let self else { return }
            
            delegate?.addNoteViewController(self, didCreate: note)
            
            navigationController?.popViewController(animated: true)
        }
        
        addNotesViewModel.onError = {[weak self] message in
            self?.showAlert(title: "Missing Title", message: message)
        }
    }
    
    @objc
    private func saveTapped() {
        addNotesViewModel.saveNote(title: titleField.text, text: textView.text)
    }
}



