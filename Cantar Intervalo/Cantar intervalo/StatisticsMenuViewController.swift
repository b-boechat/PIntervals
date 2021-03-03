//
//  StatisticsMenuViewController.swift
//  Cantar intervalo
//
//  Created by Andre on 28/02/2021.
//  Copyright © 2021 Bernardo. All rights reserved.
//

import UIKit

class StatisticsMenuViewController: UIViewController {
    
    var exerciseType : ExerciseType = .singingExercise
    var plotType : PlotType = .intervalAccuracyPlot
    var timeType : Int = 1
    
    
    @IBOutlet var exerciseTypeButtons: [UIButton]!
    
    @IBOutlet var plotTypeButtons: [UIButton]!
    
    @IBOutlet var timeTypeButtons: [UIButton]!
    
    @IBOutlet weak var middleContainer: UIView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        exerciseTypeButtons = exerciseTypeButtons.sorted{$0.tag < $1.tag}
        plotTypeButtons = plotTypeButtons.sorted{$0.tag < $1.tag}
        timeTypeButtons = timeTypeButtons.sorted{$0.tag < $1.tag}
        
        exerciseTypeButtons[0].setTitleColor(UIColor.init(red: 195/255, green: 200/255, blue: 0, alpha: 1.0), for: UIControlState.normal)
        plotTypeButtons[0].setTitleColor(UIColor.init(red: 195/255, green: 200/255, blue: 0, alpha: 1.0), for: UIControlState.normal)
        timeTypeButtons[0].setTitleColor(UIColor.init(red: 195/255, green: 200/255, blue: 0, alpha: 1.0), for: UIControlState.normal)
        
        self.view.bringSubview(toFront: middleContainer)
        
        exerciseTypeButtons.forEach{(button) in
            self.view.bringSubview(toFront: button)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func exerciseButtons(_ sender: UIButton) {
    
        exerciseTypeButtons.forEach{ (button) in
            if button.tag == sender.tag {
                button.setTitleColor(UIColor.init(red: 195/255, green: 200/255, blue: 0, alpha: 1.0), for: UIControlState.normal)
            }
            else {
                button.setTitleColor(UIColor.white, for: UIControlState.normal)
            }
        }
        exerciseType = ExerciseType(rawValue: Int16(sender.tag))!
        //print (exerciseType)
    }
    @IBAction func graphicsButton(_ sender: UIButton) {
        
        plotTypeButtons.forEach{ (button) in
            if button.tag == sender.tag {
                button.setTitleColor(UIColor.init(red: 195/255, green: 200/255, blue: 0, alpha: 1.0), for: UIControlState.normal)
            }
            else {
                button.setTitleColor(UIColor.white, for: UIControlState.normal)
            }
        }
    
        plotType = PlotType(rawValue: Int16(sender.tag))!
        //print (plotType)
    
    }
    @IBAction func timeButton(_ sender: UIButton) {
        
        timeTypeButtons.forEach{ (button) in
            if button.tag == sender.tag {
                button.setTitleColor(UIColor.init(red: 195/255, green: 200/255, blue: 0, alpha: 1.0), for: UIControlState.normal)
            }
            else {
                button.setTitleColor(UIColor.white, for: UIControlState.normal)
            }
        }
    
        timeType = sender.tag
        //print (timeType)
    
    }
    
    @IBAction func goToStatistics(_ sender: UIButton) {
        performSegue(withIdentifier: "goToStatistics", sender: self)
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToStatistics"{
    
            let statisticsPath = segue.destination as! StatisticsViewController
            
            statisticsPath.exerciseOption = exerciseType
            statisticsPath.plotOption = plotType
            statisticsPath.timeOption = timeType
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
