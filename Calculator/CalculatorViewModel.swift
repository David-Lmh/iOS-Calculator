//
//  CalculatorViewModel.swift
//  Calculator
//
//  Created by DavidLiu on 10/10/2023.
//

import Foundation

func sine(val: Double) -> Double {
    return (sin(val*Double.pi/180.0)*100000).rounded()/100000

}

func cosine(val: Double) -> Double {
    return (cos(val*Double.pi/180.0)*100000).rounded()/100000
}

class CalculatorViewModel: ObservableObject {
    
    @Published var value = "0"
    
    @Published var valueList = ""
    
    @Published var mode = ["DEC", "BIN", "HEX"]
    
    @Published var selectedMode = "DEC" {
        didSet {
            switch selectedMode {
            case "BIN":
                value = String(Int(value) ?? 0 , radix: 2)
            case "HEX":
                value = String(Int(value) ?? 0 , radix: 16, uppercase: true)
            default:
                value = "\(accumulator)"
            }
        }
        willSet {
            value = String(format: "%.0f", accumulator)
        }
    }
    
    private var accumulator: Double {
        set {
            if newValue == 0 {
                self.value = "0"
            } else {
                if selectedMode == "BIN" {
                    self.value = String(Int(newValue), radix: 2)
                } else if selectedMode == "DEC" {
                    self.value = "\(newValue)"
                } else if selectedMode == "HEX" {
                    self.value = String(Int(newValue), radix: 16).uppercased()
                }
            }
        }
        get{
            if selectedMode == "BIN" {
                return Double(Int(value, radix: 2) ?? 0)
            }
            if selectedMode == "HEX" {
                return Double(Int(value, radix: 16) ?? 0)
            }
            return Double(value) ?? 0
        }
    }
    
    let portraitDECButtons: [[CalcuButton]] = [
        [.pi, .e, .sin, .cos],
        [.clear, .negative, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .subtract],
        [.one, .two, .three, .add],
        [.zero, .decimal, .equal]
    ]
    
    let portraitBINButtons: [[CalcuButton]] = [
        [.add, .subtract, .multiply, .divide],
        [.zero, .one, .equal, .clear],
    ]
    
    let portraitHEXButtons: [[CalcuButton]] = [
        [.clear, .equal],
        [.add, .subtract, .multiply, .divide],
        [.seven, .eight, .nine, .F],
        [.four, .five, .six, .E],
        [.one, .two, .three, .D],
        [.zero, .A, .B, .C]
    ]
    
    let landscapeDECButtons: [[CalcuButton]] = [
        [.seven, .eight, .nine, .divide, .clear, .pi],
        [.four, .five, .six, .multiply, .cos, .e],
        [.one, .two, .three, .subtract, .sin, .negative],
        [.zero, .decimal, .add, .equal, .percent]
    ]
    
    let landscapeBINButtons: [[CalcuButton]] = [
        [.add, .subtract, .multiply, .divide],
        [.zero, .one, .equal, .clear],
    ]
    
    let landscapeHEXButtons: [[CalcuButton]] = [
        [.seven, .eight, .nine, .F, .clear],
        [.four, .five, .six, .E, .add, .subtract],
        [.one, .two, .three, .D, .multiply, .divide],
        [.zero, .A, .B, .C, .equal]
    ]
    
    private var isUserEnteringNumber = false
    
    private var hasPerformedEqual = false
    
    private var operations: Dictionary<String, Operations> = [
        CalcuButton.pi.rawValue: Operations.constant(Double.pi),
        CalcuButton.e.rawValue: Operations.constant(M_E),
        CalcuButton.negative.rawValue: Operations.unaryOperation({-$0}),
        CalcuButton.percent.rawValue: Operations.unaryOperation({$0/100}),
        CalcuButton.sin.rawValue: Operations.unaryOperation(sine),
        CalcuButton.cos.rawValue: Operations.unaryOperation(cosine),
        CalcuButton.add.rawValue: Operations.binaryOperation({$0+$1}),
        CalcuButton.subtract.rawValue: Operations.binaryOperation({$0-$1}),
        CalcuButton.multiply.rawValue: Operations.binaryOperation({$0*$1}),
        CalcuButton.divide.rawValue: Operations.binaryOperation({$0/$1}),
        CalcuButton.equal.rawValue: Operations.equal,
        CalcuButton.clear.rawValue: Operations.clear
    ]
    
    private enum Operations {
        case constant(Double)
        case binaryOperation((Double, Double) -> Double)
        case unaryOperation((Double)->Double)
        case equal
        case clear
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    private var pendingBinaryOperations: [PendingBinaryOperation] = []
    
    private var operationStack: [String] = []
    
    private var valueListArray: [String] = []
    
    private func performPendingBinaryOperation() {
        var finalQueue: [String] = []
        var operatorStack: [String] = []
        var numStack: [Double] = []
        
        let operators: [String: (precedence: Int, isLeftAssociative: Bool)] = [
            "+": (precedence: 1, isLeftAssociative: true),
            "-": (precedence: 1, isLeftAssociative: true),
            "x": (precedence: 2, isLeftAssociative: true),
            "/": (precedence: 2, isLeftAssociative: true)
        ]
        
        for op in operationStack {
            if let number = Double(op) {
                finalQueue.append(String(number))
            } else if op == "e" {
                finalQueue.removeLast()
            } else if op == "π" {
                finalQueue.removeLast()
            } else if op == "sin" {
                finalQueue.removeLast()
            } else if op == "cos" {
                finalQueue.removeLast()
            } else if op == "+/-" {
                finalQueue.removeLast()
            } else if op == "%" {
                finalQueue.removeLast()
            } else if let operatorData = operators[op] {
                let currentOperatorPrecedence = operatorData.precedence
                let currentOperatorIsLeftAssociative = operatorData.isLeftAssociative
                
                while let topOperator = operatorStack.last,
                      let topOperatorPrecedence = operators[topOperator]?.precedence,
                      (currentOperatorIsLeftAssociative && currentOperatorPrecedence <= topOperatorPrecedence) ||
                      (!currentOperatorIsLeftAssociative && currentOperatorPrecedence < topOperatorPrecedence) {
                    finalQueue.append(operatorStack.removeLast())
                }
                operatorStack.append(op)
            }
        }
        
        while !operatorStack.isEmpty {
            finalQueue.append(operatorStack.removeLast())
        }
        
        for op in finalQueue {
            if let number = Double(op) {
                numStack.append(number)
            } else {
                let operand2 = numStack.removeLast()
                let operand1 = numStack.removeLast()
                switch op {
                case "+":
                    numStack.append(operand1 + operand2)
                case "-":
                    numStack.append(operand1 - operand2)
                case "x":
                    numStack.append(operand1 * operand2)
                case "/":
                    numStack.append(operand1 / operand2)
                default:
                    break
                }
            }
        }
        accumulator = ((numStack.first ?? 0)*100000).rounded()/100000
        operationStack = []
    }
    
    func resetCalculator() {
        self.value = "0"
        isUserEnteringNumber = false
        operationStack = []
        accumulator = 0
        valueListArray = []
        valueList = ""
    }
    
    func didTap(button: CalcuButton) {
        if hasPerformedEqual {
            resetCalculator()
            hasPerformedEqual = false
        }
        if button.isDigit == true {
            digitPressed(button: button)
            valueListPressed(button: button)
        }
        else {
            operationPressed(button: button)
            valueListPressed(button: button)
        }
    }
    
    func digitPressed(button: CalcuButton) {
        let number = button.rawValue
        if !isUserEnteringNumber {
            self.value = "0"
        }
        if self.value.contains(".") && number == "." {
            isUserEnteringNumber = true
            self.value = "\(self.value)"
        }
        else {
            if self.value == "0" {
                if number == "0" {
                    isUserEnteringNumber = false
                }
                else if number == "." {
                    isUserEnteringNumber = true
                    self.value = "\(self.value)\(number)"
                }
                else {
                    isUserEnteringNumber = true
                    self.value.removeFirst()
                    self.value = "\(self.value)\(number)"
                }
            }
            else {
                isUserEnteringNumber = true
                self.value = "\(self.value)\(number)"
            }
        }
    }
    
    func operationPressed(button: CalcuButton) {
        isUserEnteringNumber = false
        var equalButton: Bool = false
        if let operation = operations[button.rawValue] {
            switch operation {
            case .constant(let resultValue):
                accumulator = resultValue
            case .unaryOperation(let function):
                accumulator = function(accumulator)
            case .binaryOperation(let function):
                pendingBinaryOperations.append(PendingBinaryOperation(function: function, firstOperand: accumulator))
            case .equal:
                equalButton = true
                hasPerformedEqual = true
            case .clear:
                operationStack = []
                accumulator = 0
                valueListArray = []
                valueList = ""
                hasPerformedEqual = true
            }
        }
        operationStack.append(self.value)
        if button != .clear && button != .equal{
            operationStack.append(button.rawValue)
        }
        if equalButton {
            performPendingBinaryOperation()
        }
    }
    
    // to find the last non digit number Index
    func findLastNonDigitIndex(stringArray: [String]) -> Int {
        let nonDigit = CharacterSet.decimalDigits.inverted
        for (index, element) in stringArray.enumerated().reversed().dropLast() {
            if element.rangeOfCharacter(from: nonDigit) != nil && element != "." {
                return index
            }
        }
        return 0
    }
    
    // to find the last operator Index
    func findLastOperatorIndex(stringArray: [String]) -> Int {
        for i in stride(from: stringArray.count - 1, through: 0, by: -1) {
            let element = stringArray[i]
            if element == "+" || element == "-" || element == "x" || element == "/" {
                return i
            }
        }
        return 0
    }
    
    func valueListPressed(button: CalcuButton) {
        valueListArray.append(button.rawValue)
        var index: Int = 0
        var cache: String = ""
        if button == .clear {
            valueListArray = []
            valueList = ""
        } else if button == .sin {
            valueListArray.removeLast()
            index = findLastNonDigitIndex(stringArray: valueListArray)
            if index == 0 {
                if index == valueListArray.count {
                    cache = "0"
                } else {
                    for i in (index...valueListArray.count - 1) {
                        cache += String(valueListArray[i])
                    }
                    valueListArray.removeSubrange(index...valueListArray.count - 1)
                }
            } else {
                if index == valueListArray.count - 1 {
                    if valueListArray[index] == "+" || valueListArray[index] == "-" || valueListArray[index] == "x" || valueListArray[index] == "/" {
                        cache = ""
                    } else {
                        cache = String(valueListArray[index])
                        valueListArray.remove(at: index)
                    }
                } else {
                    for i in (index + 1...valueListArray.count - 1) {
                        cache += String(valueListArray[i])
                    }
                    valueListArray.removeSubrange(index + 1...valueListArray.count - 1)
                }
            }
            valueListArray.append("sin(\(cache))")
        } else if button == .cos {
            valueListArray.removeLast()
            index = findLastNonDigitIndex(stringArray: valueListArray)
            if index == 0 {
                if index == valueListArray.count {
                    cache = "0"
                } else {
                    for i in (index...valueListArray.count - 1) {
                        cache += String(valueListArray[i])
                    }
                    valueListArray.removeSubrange(index...valueListArray.count - 1)
                }
            } else {
                if index == valueListArray.count - 1 {
                    if valueListArray[index] == "+" || valueListArray[index] == "-" || valueListArray[index] == "x" || valueListArray[index] == "/" {
                        cache = ""
                    } else {
                        cache = String(valueListArray[index])
                        valueListArray.remove(at: index)
                    }
                } else {
                    for i in (index + 1...valueListArray.count - 1) {
                        cache += String(valueListArray[i])
                    }
                    valueListArray.removeSubrange(index + 1...valueListArray.count - 1)
                }
            }
            
            valueListArray.append("cos(\(cache))")
        } else if button == .negative {
            valueListArray.removeLast()
            index = findLastNonDigitIndex(stringArray: valueListArray)
            if index == valueListArray.count - 1 && index != 0{
                if valueListArray[index-1] == "+" || valueListArray[index-1] == "x"  || valueListArray[index-1] == "/" {
                    valueListArray.insert("-", at: index)
                } else if valueListArray[index-1] == "-" && index > 1{
                    if valueListArray[index-2] == "+" || valueListArray[index-2] == "x"  || valueListArray[index-2] == "/" || valueListArray[index-2] == "-"{
                        valueListArray.remove(at: index-1)
                    } else {
                        valueListArray.insert("-", at: index)
                    }
                } else if index == 1 && valueListArray[index-1] == "-" {
                    valueListArray.remove(at: index-1)
                }
            } else if index > 0 && (valueListArray[index] == "+" || valueListArray[index] == "-" || valueListArray[index] == "x" || valueListArray[index] == "/") {
                valueListArray.insert("-", at: index+1)
                if valueListArray[index+1] == "-" && valueListArray[index] == "-" && (valueListArray[index-1] == "+" || valueListArray[index-1] == "x"  || valueListArray[index-1] == "/") {
                    valueListArray.remove(at: index+1)
                    valueListArray.remove(at: index)
                } else if valueListArray[index+1] == "-" && valueListArray[index] == "-" && valueListArray[index-1] == "-" {
                    valueListArray.remove(at: index+1)
                    valueListArray.remove(at: index)
                }
                if index == 1 && valueListArray[0] == "-" {
                    valueListArray.remove(at: 0)
                    valueListArray.remove(at: index)
                }
            } else if index > 0 {
                valueListArray.insert("-", at: index)
                index = findLastNonDigitIndex(stringArray: valueListArray)
            } else if index == 0 {
                if valueListArray.count != 0 {
                    valueListArray.insert("-", at: index)
                }
                index = findLastNonDigitIndex(stringArray: valueListArray)
                if index == 1 && valueListArray[index] == "-" {
                    valueListArray.remove(at: index)
                    valueListArray.remove(at: index-1)
                }
            }
        } else if button == .equal {
            if valueListArray.count > 0 && valueListArray[valueListArray.count-1] == "=" {
                valueListArray.removeLast()
            } else if valueListArray.count == 0 {
                valueListArray = []
            }
        } else if button == .zero {
            index = findLastOperatorIndex(stringArray: valueListArray)
            if valueListArray.count > 1 && valueListArray.count-1 == index && (valueListArray[valueListArray.count-1] == "+" || valueListArray[valueListArray.count-1] == "-" || valueListArray[valueListArray.count-1] == "x" || valueListArray[valueListArray.count-1] == "/") {
                
                valueListArray.removeLast()
                valueListArray.removeLast()
                valueListArray.append("=")
            }
            if valueListArray.count == 0 {
                valueListArray.removeLast()
            } else if valueListArray.count == 1 && valueListArray[0] == "0" {
                valueListArray.removeLast()
            }
        } else if button == .add {
            if valueListArray.count == 1 {
                valueListArray.insert("0", at: 0)
            }
        } else if button == .subtract {
            if valueListArray.count == 1 {
                valueListArray.insert("0", at: 0)
            }
        } else if button == .multiply {
            if valueListArray.count == 1 {
                valueListArray.insert("0", at: 0)
            }
        } else if button == .divide {
            if valueListArray.count == 1 {
                valueListArray.insert("0", at: 0)
            }
        } else if button == .e || button == .pi {
            if valueListArray.count > 1 {
                if valueListArray[valueListArray.count-2] != "+" || valueListArray[valueListArray.count-2] != "-" || valueListArray[valueListArray.count-2] != "x" || valueListArray[valueListArray.count-2] != "/" {
                    cache = valueListArray.removeLast()
                    index = findLastOperatorIndex(stringArray: valueListArray)
                    if index != 0 {
                        if index < valueListArray.count - 1 {
                            valueListArray.removeSubrange(index+1...valueListArray.count-1)
                        }
                    } else {
                        valueListArray = []
                    }
                    valueListArray.append(cache)
                }
            }
        } else if button == .one || button == .two || button == .three || button == .four || button == .five || button == .six || button == .seven || button == .eight || button == .nine {
            if valueListArray.count > 0 {
                index = findLastNonDigitIndex(stringArray: valueListArray)
                if index == 0 {
                    if valueListArray[0] == "e" || valueListArray[0] == "π" {
                        valueListArray.removeFirst()
                    }
                } else if index == valueListArray.count - 1 && (valueListArray[valueListArray.count-1] != "+" || valueListArray[valueListArray.count-1] != "-" || valueListArray[valueListArray.count-1] != "x" || valueListArray[valueListArray.count-1] != "/") {
                    cache = valueListArray.removeLast()
                    index = findLastOperatorIndex(stringArray: valueListArray)
                    if index != 0 {
                        if index == valueListArray.count - 1 {
                            valueListArray.removeSubrange(index...valueListArray.count-1)
                        } else {
                            valueListArray.removeSubrange(index+1...valueListArray.count-1)
                        }
                    } else {
                        valueListArray = []
                    }
                    valueListArray.append(cache)
                }
            }
        } else if button == .decimal {
            cache = valueListArray.removeLast()
            if valueListArray.last == "." {
                valueListArray.removeLast()
            }
            if valueListArray.last == "e" || valueListArray.last == "π" {
                valueListArray.removeLast()
                valueListArray.append("0")
            }
            if valueListArray.last == "+" || valueListArray.last == "-" || valueListArray.last == "x" || valueListArray.last == "/" || valueListArray.isEmpty {
                valueListArray.append("0")
            }
            valueListArray.append(cache)
        }
        self.valueList = "\(valueListArray.joined())"
    }
}
