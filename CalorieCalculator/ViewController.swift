//
//  ViewController.swift
//  CalorieCalculator
//
//  Created by Harikrishnan on 19/06/2021.
//

import UIKit
import Combine

struct Event {
    let title : String
    let met : Double
}

class ViewController: UIViewController {

    private let notificationCenter = NotificationCenter.default
    
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var eventTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var result: UILabel!
    
    @Published private var weight : Double?
    @Published private var duration : Double?
    @Published private var selectedMET : Double? = 0.0
    
    private var subscribers =  Set<AnyCancellable>()
    
    let eventPickerView = UIPickerView()
    
    let events = [Event(title: "Cycling", met: 9.5),
                  Event(title: "Kickboxing", met: 10),
                  Event(title: "Swimming", met: 8),
                  Event(title: "Football", met: 7),
                  Event(title: "Aerobics", met: 6.83)
                 ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventPickerView.delegate = self
        eventPickerView.dataSource = self
        eventTextField.inputView = eventPickerView
        observeInputDataFields()
    }
    
    private func observeInputDataFields() {
        
        notificationCenter.publisher(for: UITextField.textDidChangeNotification, object: weightTextField).sink(receiveValue: {
            
            guard let textField = $0.object as? UITextField,
                  let text = textField.text,
                  !text.isEmpty,
                  let weight = Double(text) else {
                self.weight = nil
                return
            }
            self.weight = weight
            
        }).store(in: &subscribers)
        
        notificationCenter.publisher(for: UITextField.textDidChangeNotification, object: durationTextField).sink(receiveValue: {
            
            guard let textField = $0.object as? UITextField,
                  let text = textField.text,
                  !text.isEmpty,
                  let duration = Double(text) else {
                self.duration = nil
                return
            }
            self.duration = duration
            
        }).store(in: &subscribers)
        
        
        notificationCenter.publisher(for: UITextField.textDidChangeNotification, object: eventTextField).sink(receiveValue: {
            
            guard let textField = $0.object as? UITextField,
                  let text = textField.text,
                  !text.isEmpty else {
                self.selectedMET = 0
                return
            }
        }).store(in: &subscribers)
        
       
       
        
        Publishers.CombineLatest3($weight, $duration,$selectedMET).sink {[weak self] (weight,duration,selectedMET) in
            
            guard let this = self else {return}
            guard let weight = weight ,let duration = duration, let selectedMET = selectedMET  else {
                this.result.text = "Please provide all details"
                return
            }
            
            let totalCaloriesBurned = (duration * selectedMET * 3.5 * weight) / 200

            let energyText = totalCaloriesBurned.toString()
            
            let attributedEnergyText = NSAttributedString().formatText(text: energyText, size: 65)
            
            let attributedUnitText = NSAttributedString().formatText(text: "kCal", size: 32)
            
            let combination = NSMutableAttributedString()
            
            combination.append(attributedEnergyText)
            combination.append(attributedUnitText)
            
            this.result.attributedText = combination
            
        }.store(in: &subscribers)
        
    }

    

}

extension ViewController : UIPickerViewAccessibilityDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return events.count
    }
    
     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return events[row].title
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedMET = events[row].met
        eventTextField.text = events[row].title
    }
    
}

extension Double {
    
    func toString() -> String {
        return String(describing: self)
        
    }
}

extension NSAttributedString {
    func formatText(text:String, size: CGFloat) -> NSAttributedString
    {
        let font = UIFont(name: "Avenir-Medium", size: size)
        let attributes = [NSAttributedString.Key.font: font]
        return NSAttributedString(string: text, attributes: attributes as [NSAttributedString.Key : Any])
    }
    
}
