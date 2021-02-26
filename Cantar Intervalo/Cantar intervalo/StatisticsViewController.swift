//
//  StatisticsViewController.swift
//  Cantar intervalo
//
//  Created by Macintosh on 22/02/21.
//  Copyright © 2021 Bernardo. All rights reserved.
//

import UIKit
import CoreData
import Charts

class StatisticsViewController: UIViewController {

    // Context for core data storage.
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Stores exercise results.
    var results = [ExerciseResult]()
    
    @IBOutlet weak var barChart: BarChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDebugResults()
        
        fetchResults()
        plotResultsByInterval(exerciseType: .singingExercise)

        // Do any additional setup after loading the view.
    }

    func fetchResults() {
        // Load exercise results, which are saved as Core Data.
        let request : NSFetchRequest<ExerciseResult> = ExerciseResult.fetchRequest()
        
        do {
            results = try context.fetch(request)
        }
        catch {
            print("Error fetching request. \(error)")
        }
    }
    
    func plotResultsByInterval(exerciseType: ExerciseType) {
        
        let filteredResults = filterResults{$0.exerciseType == ExerciseType.singingExercise.rawValue}
        
        var entries = [BarChartDataEntry]()
        for i in 1 ... 12 {
            entries.append(BarChartDataEntry(x: Double(i), y: calculateIntervalPercentage(consideredResults: filteredResults, rawInterval: Int16(i))))
        }
        
        let dataSet = BarChartDataSet(values: entries, label: "Intervalos")
        let data = BarChartData(dataSets: [dataSet])
        barChart.data = data
        barChart.chartDescription?.text = "Porcentagem de acertos por intervalo."
        
        //All other additions to this function will go here
        
        //This must stay at end of function
        barChart.notifyDataSetChanged()
    }
    
    
    
    
    
    func filterResults(rule: (ExerciseResult) -> Bool) -> [ExerciseResult] {
        // Filter results array based on provided rule. Alternative to the filter() function, which is not available for Xcode 9.x
        var filteredResults = [ExerciseResult]()
        for result in results where rule(result) {
            filteredResults.append(result)
        }
        return filteredResults
    }
    
    func calculateIntervalPercentage(consideredResults: [ExerciseResult], rawInterval: Int16) -> Double {
        // Returns percentage of correct exercise answers for the given interval, only among consideredResults (so they can be filtered previously, for example by exercise or date).
        
        // Filter results by given correct interval, and calculate their total count.
        let resultsWithSpecifiedInterval = filterResults{$0.correctInterval == rawInterval}
        let totalCount = Double(resultsWithSpecifiedInterval.count)
        // Calculate count of correct answers for the given interval.
        var correctCount : Double = 0.0
        resultsWithSpecifiedInterval.forEach{
            if $0.result == true {
                correctCount += 1
            }
        }
        return 100.0*correctCount/totalCount
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
