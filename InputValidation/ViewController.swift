//
//  ViewController.swift
//  InputValidation
//
//  Created by Henry Chan on 5/31/19.
//  Copyright © 2019 HDC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var errorLabel: UILabel!
    
    private lazy var passwordValidator = InputValidator<String>()
        .isEqualTo { self.confirmPasswordTextField.text }
        .isValidLength { $0 >= 8 }
        .hasAlphaCharacters()
        .hasNumericCharacters()
    
    private lazy var segmentValidator = InputValidator<Int>()
        .isEqualTo { 1 }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        segmentedControl.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    @objc private func editingChanged() {
        validateAllFields()
    }
    
    @objc private func valueChanged() {
        validateAllFields()
    }
    
    private func validateAllFields() {
        var errorStrings: [String] = []
        if let passwordErrors = passwordValidator.validate(input: passwordTextField.text) {
            errorStrings += passwordErrors.map { $0.description(for: "Password") ?? "" }
        }
        
        if let segmentErrors = segmentValidator.validate(input: segmentedControl.selectedSegmentIndex) {
            errorStrings += segmentErrors.map { $0.description(for: "Segment Control") ?? "" }
        }
        
        if errorStrings.count > 0 {
            errorLabel.textColor = .red
            errorLabel.text = errorStrings.joined(separator: "\n")
        } else {
            errorLabel.textColor = .green
            errorLabel.text = "Ready to Submit!"
        }
        
    }
}

