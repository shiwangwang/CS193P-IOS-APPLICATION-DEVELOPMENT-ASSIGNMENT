//
//  ViewController.swift
//  Calculator
//
//  Created by shiww on 17/3/2.
//  Copyright © 2017年 Stanford University. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var display: UILabel!
  @IBOutlet weak var descriptionDisplay: UILabel!
  @IBOutlet weak var variablesDisplay: UILabel!
  
  override func viewDidLoad() {
    descriptionDisplay.text = " "
  }
  
  
  var userIsInTheMiddleOfTyping = false
  
  var displayValue: Double {
    get {
      return Double(display.text!)!
    }
    set {
      let numberFormatter = NumberFormatter()
      numberFormatter.numberStyle = .decimal
      numberFormatter.maximumFractionDigits = 6
      display.text = numberFormatter.string(from: NSNumber(value: newValue))
    }
  }
  
  var result: (result: Double?, isPending: Bool, description: String, error: String?) = (nil, false, " ", nil) {
    didSet {
      if let errorInfo = result.error {
        descriptionDisplay.text = errorInfo
      }else {
        if let accumulator = result.result {
          displayValue = accumulator
        }
        if result.isPending {
          descriptionDisplay.text = result.description + "..."
        } else {
          descriptionDisplay.text =	result.description == " " ? " " : result.description + "="
        }
      }
      
    }
  }
  
  private var brain = CalclatorBrain()
  private var variables: [String: Double] = [:] {
    didSet {
      variablesDisplay.text = " "
      for (name,value) in variables {
        variablesDisplay.text?.append("\(name) = \(value)")
      }
    }
  }
  
  @IBAction func touchDigit(_ sender: UIButton) {
    let digit = sender.currentTitle!
    if userIsInTheMiddleOfTyping {
      let textCurrentlyInDisplay = display.text!
      
      if  textCurrentlyInDisplay.contains(".") && digit == "." {
        return
      } else{
        display.text = textCurrentlyInDisplay + digit
      }
      
    } else {
      display.text = digit
      userIsInTheMiddleOfTyping = true
    }
  }
  
  @IBAction func clear(_ sender: Any) {
    brain = CalclatorBrain()
    userIsInTheMiddleOfTyping = false
    display.text = " "
    descriptionDisplay.text = " "
    variables = Dictionary<String, Double>()
  }
  @IBAction func performOperation(_ sender: UIButton) {
    if userIsInTheMiddleOfTyping {
      brain.setOperand(displayValue)
      userIsInTheMiddleOfTyping = false
    }
    if let mathematicalSymbol = sender.currentTitle {
      brain.performOperation(mathematicalSymbol)
    }
    result = brain.evaluateWithErrorReport(using: variables)
  }
  @IBAction func defineVariable(_ sender: UIButton) {
    if let symbol = sender.currentTitle {
      userIsInTheMiddleOfTyping = false
      brain.setOperand(variable: symbol)
      result = brain.evaluateWithErrorReport(using: variables)
    }
  }
  @IBAction func initialVariable(_ sender: UIButton) {
    userIsInTheMiddleOfTyping = false
    let symbol = String(sender.currentTitle!.characters.last!)
    variables[symbol] = Double(display.text!)
    result = brain.evaluateWithErrorReport(using: variables)
  }
  @IBAction func undoOrBackspace(_ sender: Any) {
    if userIsInTheMiddleOfTyping {
      //remove last character in display
      if var operand = display.text {
        operand.remove(at: operand.index(before: operand.endIndex))
        display.text = " " + operand
      }
    } else {
      //undo last command
      brain.undoOperation()
      result = brain.evaluateWithErrorReport(using: variables)
    }
  }
  
  
}

