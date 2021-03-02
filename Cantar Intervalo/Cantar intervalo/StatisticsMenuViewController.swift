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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func exerciseButtons(_ sender: UIButton) {
    
        exerciseType = ExerciseType(rawValue: Int16(sender.tag))!
        //print (exerciseType)
    }
    @IBAction func graphicsButton(_ sender: UIButton) {
    
        plotType = PlotType(rawValue: Int16(sender.tag))!
        //print (plotType)
    
    }
    @IBAction func timeButton(_ sender: UIButton) {
    
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
