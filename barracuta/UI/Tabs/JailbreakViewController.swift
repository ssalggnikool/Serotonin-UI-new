//
//  JailbreakViewController.swift
//  barracuta
//
//  Created by samara on 1/14/24.
//  Copyright © 2024 samiiau. All rights reserved.
//

import UIKit

class JailbreakViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView = UITableView()
    let cellReuseIdentifier = "TableCell"
    var data: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 44.0)))
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        
        let toolbarHeight: CGFloat = 70
        
        let jbButton = jbButton(state: .jailbreak)
        let fileListHeaderItem = UIBarButtonItem(customView: jbButton)
        
        toolbar.setItems([fileListHeaderItem], animated: false)
        
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: toolbarHeight),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.reloadData()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        data = Array(repeating: "Cell", count: 20)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
}

enum ButtonState {
    case done
    case jailbreak
    case jailbreaking
    case error
    case unsupported
}

class jbButton: UIButton {
    
    private var currentState: ButtonState
    private var activityIndicator: UIActivityIndicatorView!

    init(state: ButtonState) {
        self.currentState = state
        super.init(frame: .zero)
        
        configureButton(for: state)
        addTarget(self, action: #selector(jbTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func configureButton(for state: ButtonState) {

        UIView.animate(withDuration: 0.2) {
            self.alpha = 0.2
        } completion: { _ in
            self.layer.cornerRadius = 10
            self.frame = CGRect(x: 0, y: 0, width: 0, height: 40)
            self.setTitleColor(.white, for: .normal)
            self.layer.borderWidth = 0

            switch state {
            case .done:
                self.backgroundColor = .systemGreen
                self.setTitle("Userspace Reboot", for: .normal)
            case .jailbreak:
                self.backgroundColor = .systemPink
                self.setTitle("Jailbreak", for: .normal)
            case .jailbreaking:
                self.isEnabled = false
                self.backgroundColor = .systemPink.withAlphaComponent(0.2)
                self.setTitle("", for: .normal)
                self.layer.borderWidth = 1
                self.layer.borderColor = UIColor.systemPink.withAlphaComponent(0.6).cgColor
                self.showLoadingIndicator()
            case .error:
                self.isEnabled = false
                self.backgroundColor = .systemOrange.withAlphaComponent(0.2)
                self.setTitle("Error", for: .normal)
                self.setTitleColor(.systemOrange, for: .normal)
                self.layer.borderWidth = 1
                self.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.6).cgColor
            case .unsupported:
                self.isEnabled = false
                self.backgroundColor = .systemPink.withAlphaComponent(0.2)
                self.setTitle("Unsupported", for: .normal)
                self.setTitleColor(.systemPink, for: .normal)
                self.layer.borderWidth = 1
                self.layer.borderColor = UIColor.systemPink.withAlphaComponent(0.6).cgColor
            }

            UIView.animate(withDuration: 0.3) { self.alpha = 1.0 }
        }
    }



    private func showLoadingIndicator() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        activityIndicator.startAnimating()
    }
    
    @objc private func jbTapped() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        currentState = .jailbreaking
        self.configureButton(for: self.currentState)
        print("test")
    }
}
