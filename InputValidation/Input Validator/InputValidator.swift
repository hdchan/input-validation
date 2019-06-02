//
//  InputValidator.swift
//  InputValidation
//
//  Created by Henry Chan on 5/31/19.
//  Copyright © 2019 HDC. All rights reserved.
//

import Foundation

protocol InputValidationErrorType: Error {}

enum InputValidationError: InputValidationErrorType {
    case noInput
}

class InputValidator<InputType> {
    struct Configuration {
        let returnNoInputError: Bool
        
        static var `default`: Configuration {
            return .init(returnNoInputError: true)
        }
    }
    
    private var headValidationHandler: ValidationHandler<InputType>?
    private var tailValidationHandler: ValidationHandler<InputType>?
    private let configuration: Configuration
    
    init(configuration: Configuration = .default) {
        self.configuration = configuration
    }
    
    func validate(input: InputType?) -> [InputValidationErrorType]? {
        guard let input = input else {
            return self.configuration.returnNoInputError ? [InputValidationError.noInput] : nil
        }
        let errors = headValidationHandler?.handleInputValidation(input: input) ?? []
        return errors.count > 0 ? errors : nil
    }
    
    internal func add(handler: ValidationHandler<InputType>) -> InputValidator {
        guard let _ = headValidationHandler else {
            self.headValidationHandler = handler
            self.tailValidationHandler = handler
            return self
        }
        tailValidationHandler?.next = handler
        tailValidationHandler = handler
        return self
    }
}

internal extension InputValidator {
    class ValidationHandler<InputType> {
        var next: ValidationHandler<InputType>?
        
        func handleInputValidation(input: InputType) -> [InputValidationErrorType] {
            fatalError("Validation not implemented")
        }
        
        func getErrors(for input: InputType, validate: () -> InputValidationErrorType?) -> [InputValidationErrorType] {
            var existingErrors = next?.handleInputValidation(input: input) ?? []
            if let newError = validate() {
                existingErrors.append(newError)
            }
            return existingErrors
        }
        
        func getErrors(for input: InputType, validate: () -> [InputValidationErrorType]?) -> [InputValidationErrorType] {
            var existingErrors = next?.handleInputValidation(input: input) ?? []
            if let newErrors = validate() {
                existingErrors += newErrors
            }
            return existingErrors
        }
    }
}

