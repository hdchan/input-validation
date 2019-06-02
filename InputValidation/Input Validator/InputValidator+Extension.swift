//
//  InputValidator+Extension.swift
//  InputValidation
//
//  Created by Henry Chan on 5/31/19.
//  Copyright © 2019 HDC. All rights reserved.
//

import Foundation

extension InputValidationErrorType {
    func description(for fieldName: String) -> String? {
        if let error = self as? InputValidationError {
            switch error {
            case .noInput:
                return "\(fieldName) is empty"
            }
        } else if let error = self as? CustomInputValidationError {
            switch error {
            case .notEqual:
                return "\(fieldName) has incorrect value"
            case .noComparingInput:
                return "\(fieldName) has no comparing input"
            case .failedComparison:
                return "\(fieldName) failed comparison"
            case .invalidLength:
                return "\(fieldName) has invalid length"
            case .noAlphaCharacters:
                return "\(fieldName) does not contain alpha characters"
            case .noNumericaCharacters:
                return "\(fieldName) does not contain numeric characters"
            case .noSpecialCharacters:
                return "\(fieldName) does not contain any special characters"
            }
        }
        return nil
    }
}

enum CustomInputValidationError: InputValidationErrorType {
    case notEqual
    case noComparingInput
    case failedComparison
    case invalidLength
    case noAlphaCharacters
    case noNumericaCharacters
    case noSpecialCharacters
}

extension InputValidator where InputType: Equatable {
    func isEqualTo(comparingInput: @escaping () -> InputType?) -> InputValidator {
        return add(handler: EqualityValidator(comparingInput: comparingInput))
    }
}

extension InputValidator where InputType: Comparable {
    func meetsCondition(condition: @escaping (InputType) -> Bool) -> InputValidator {
        return add(handler: ComparableValidator(condition: condition))
    }
}

extension InputValidator where InputType == String {
    func isEqualTo(isCaseSensitive: Bool = true, comparingInput: @escaping () -> String?) -> InputValidator {
        return add(handler: StringEqualityValidator(isCaseSensitive: isCaseSensitive, comparingInput: comparingInput))
    }
    
    func isValidLength(condition: @escaping (Int) -> Bool) -> InputValidator {
        return add(handler: LengthValidator(condition: condition))
    }
    
    func hasAlphaCharacters() -> InputValidator {
        return add(handler: AlphaCharacterValidator())
    }
    
    func hasNumericCharacters() -> InputValidator {
        return add(handler: NumericCharacterValidator())
    }
    
    func hasSpecialCharacters(excludedCharacterSet: CharacterSet? = nil) -> InputValidator {
        return add(handler: SpecialCharacterValidator(excludedCharacterSet: excludedCharacterSet))
    }
}

internal extension InputValidator where InputType: Equatable {
    class EqualityValidator: ValidationHandler<InputType> {
        private let comparingInput: () -> InputType?
        
        init(comparingInput: @escaping () -> InputType?) {
            self.comparingInput = comparingInput
        }
        
        override func handleInputValidation(input: InputType) -> [InputValidationErrorType] {
            return getErrors(for: input) { () -> InputValidationErrorType? in
                guard let comparingInput = comparingInput() else {
                    return CustomInputValidationError.noComparingInput
                }
                if input != comparingInput {
                    return CustomInputValidationError.notEqual
                }
                return nil
            }
        }
    }
}

internal extension InputValidator where InputType: Comparable {
    class ComparableValidator: ValidationHandler<InputType> {
        private let condition: (InputType) -> Bool
        
        init(condition: @escaping (InputType) -> Bool) {
            self.condition = condition
        }
        
        override func handleInputValidation(input: InputType) -> [InputValidationErrorType] {
            return getErrors(for: input) { () -> InputValidationErrorType? in
                if condition(input) == false {
                    return CustomInputValidationError.failedComparison
                }
                return nil
            }
        }
    }
}

internal extension InputValidator {
    class StringEqualityValidator: ValidationHandler<String> {
        private let isCaseSensitive: Bool
        private let comparingInput: () -> String?
        
        init(isCaseSensitive: Bool, comparingInput: @escaping () -> String?) {
            self.isCaseSensitive = isCaseSensitive
            self.comparingInput = comparingInput
        }
        
        override func handleInputValidation(input: String) -> [InputValidationErrorType] {
            return getErrors(for: input) { () -> InputValidationErrorType? in
                guard let comparingInput = comparingInput() else {
                    return CustomInputValidationError.noComparingInput
                }
                if isCaseSensitive == true {
                    if input != comparingInput {
                        return CustomInputValidationError.notEqual
                    }
                } else {
                    if input.caseInsensitiveCompare(comparingInput) != .orderedSame {
                        return CustomInputValidationError.notEqual
                    }
                }
                return nil
            }
        }
    }
    
    class LengthValidator: ValidationHandler<String> {
        private let condition: ((Int) -> Bool)
        
        init(condition: @escaping (Int) -> Bool) {
            self.condition = condition
        }
        
        override func handleInputValidation(input: String) -> [InputValidationErrorType] {
            return getErrors(for: input) { () -> InputValidationErrorType? in
                if condition(input.count) == false {
                    return CustomInputValidationError.invalidLength
                }
                return nil
            }
        }
    }
    
    class AlphaCharacterValidator: ValidationHandler<String> {
        override func handleInputValidation(input: String) -> [InputValidationErrorType] {
            return getErrors(for: input) { () -> InputValidationErrorType? in
                let charset = CharacterSet.uppercaseLetters.union(.lowercaseLetters)
                if input.rangeOfCharacter(from: charset) == nil {
                    return CustomInputValidationError.noAlphaCharacters
                }
                return nil
            }
        }
    }
    
    class NumericCharacterValidator: ValidationHandler<String> {
        override func handleInputValidation(input: String) -> [InputValidationErrorType] {
            return getErrors(for: input) { () -> InputValidationErrorType? in
                let charset: CharacterSet = .decimalDigits
                if input.rangeOfCharacter(from: charset) == nil {
                    return CustomInputValidationError.noNumericaCharacters
                }
                return nil
            }
        }
    }
    
    class SpecialCharacterValidator: ValidationHandler<String> {
        private let excludedCharacterSet: CharacterSet
        
        init(excludedCharacterSet: CharacterSet? = nil) {
            self.excludedCharacterSet = excludedCharacterSet ?? CharacterSet(charactersIn: "")
        }
        
        override func handleInputValidation(input: String) -> [InputValidationErrorType] {
            return getErrors(for: input) { () -> InputValidationErrorType? in
                let charset = CharacterSet.alphanumerics
                    .union(excludedCharacterSet)
                    .inverted
                if input.rangeOfCharacter(from: charset) == nil {
                    return CustomInputValidationError.noSpecialCharacters
                }
                return nil
            }
            
        }
    }
}
