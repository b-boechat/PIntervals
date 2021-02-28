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

    var exerciseOption = 0
    var plotOption = 0
    var timeOption = 0
    var exerciseTypePassed = 0
    var plotTypePassed = 0
    var timeTypePassed = 0
    
    
    // Context for core data storage.
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Stores exercise results.
    var results = [ExerciseResult]()
    
    // Gets calendar from user device.
    let calendar = Calendar.current
    
    // Gets current date.
    let currentDate = Date()
    
    @IBOutlet weak var barChart: BarChartView!
    
    @IBOutlet weak var portraitViewWarning: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exerciseTypePassed = exerciseOption
        plotTypePassed = plotOption
        timeTypePassed = timeOption
        print (exerciseTypePassed)
        print (plotTypePassed)
        print (timeTypePassed)
        
        changeOrientation()
        fetchResults()
        //removeResults()
        replaceWithDebugResults(resultsAsStruct4)
        
        barChart.noDataText = "Responda mais exercícios para obter estatísticas!"
        barChart.noDataTextColor = .white
        barChart.noDataFont = UIFont(name: "KohinoorBangla-Regular", size: 16)!
        
    
        presentSpecifiedStatistics(plotType: .intervalAccuracyPlot, exerciseType: .singingExercise, numberOfPastDaysConsidered: 5)

    }
    
    func presentSpecifiedStatistics(plotType: PlotType, exerciseType: ExerciseType, numberOfPastDaysConsidered: Int) {
        
        // Filter results by specified exercise type and date range.
        let filteredResults = filterResults{
            return $0.exerciseType == exerciseType.rawValue &&
                    (calendar).dateComponents([.day], from: $0.date!, to: currentDate).day! <= numberOfPastDaysConsidered
        }
        plotResultsByInterval(filteredResults)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // If orientation is going to change, call the apropriate changeOrientation function.
        super.viewWillTransition(to: size, with: coordinator)
        changeOrientation()
    }
    
    func changeOrientation() {
        // Change visibility of elements to match current orientation
        if UIDevice.current.orientation.isLandscape {
            // Enable chart and disable portrait warning.
            barChart.alpha = 1.0
            barChart.isUserInteractionEnabled = true
            portraitViewWarning.alpha = 0.0
        }
        else {
            // Enable portrait warning and disable chart.
            barChart.alpha = 0.0
            barChart.isUserInteractionEnabled = false
            portraitViewWarning.alpha = 1.0
        }
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
    
    func removeResults(){
        // Removes all saved results. Assumes fetch results has been called previously.
        for result in results {
            context.delete(result)
        }
        results.removeAll()
        do {
            try context.save()
        }
        catch {
            print("Error saving context: \(error)")
        }
    }
    
    func filterResults(_ providedResults: [ExerciseResult]? = nil, rule: (ExerciseResult) -> Bool) -> [ExerciseResult] {
        // Filter provided results array based on provided rule. Alternative to the filter() function, which is not available for Xcode 9.x
        
        let consideredResults = providedResults ?? results
        var filteredResults = [ExerciseResult]()
        for result in consideredResults where rule(result) {
            filteredResults.append(result)
        }
        return filteredResults
    }
    
    func calculateIntervalAnswerAccuracy(providedResults: [ExerciseResult], rawInterval: Int16) -> Double? {
        // Returns ratio of correct exercise answers for the given interval, only among consideredResults (so they can be filtered previously, for example by exercise or date).
        
        // Filter results by given correct interval, and calculate their total count.
        let resultsWithSpecifiedInterval = filterResults(providedResults){$0.correctInterval == rawInterval}
        let totalCount = Double(resultsWithSpecifiedInterval.count)
        if totalCount == 0 {
            // No data exists for this interval, among consideredResults.
            return nil
        }
        // Calculate count of correct answers for the given interval.
        var correctCount : Double = 0.0
        resultsWithSpecifiedInterval.forEach{
            if $0.result == true {
                correctCount += 1
            }
        }
        return correctCount/totalCount
        
    }
    
    func plotResultsByInterval(_ filteredResults: [ExerciseResult]) {
        
        var entries = [BarChartDataEntry]()
        // Get correct answer percentage for each interval.
        for i in 1 ... 12 {
            guard let percentage = calculateIntervalAnswerAccuracy(providedResults: filteredResults,  rawInterval: Int16(i)) else {
                print("Answer more exercises!")
                return
            }
            entries.append(BarChartDataEntry(x: Double(i), y: percentage))
        }
        // Create plot
        let dataSet = BarChartDataSet(values: entries, label: "Intervalos")
        let data = BarChartData(dataSets: [dataSet])
        barChart.data = data
        // Customize plot.
        
        barChart.chartDescription?.text = ""
        barChart.chartDescription?.textColor = .white
        barChart.chartDescription?.font = UIFont(name: "KohinoorBangla-Regular", size: 11)!
        
        barChart.drawValueAboveBarEnabled = true
        barChart.legend.enabled = false
        //barChart.legend.font = UIFont(name: "KohinoorBangla-Regular", size: 11)!
        //barChart.legend.textColor = .white
        
        
        let formatter = NumberFormatter(); formatter.numberStyle = .percent;
        
        barChart.xAxis.drawAxisLineEnabled = true
        barChart.xAxis.labelTextColor = .white
        barChart.xAxis.enabled = true
        barChart.xAxis.labelPosition = .bottom
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: [
            "", "2m", "2M", "3m", "3M", "4", "TT", "5", "6m", "6M", "7m", "7M", "8"])
        barChart.xAxis.setLabelCount(120, force: false)
        barChart.xAxis.axisMinimum = 0.5
        barChart.xAxis.axisMaximum = 12.5
        
        
        
        barChart.leftAxis.drawAxisLineEnabled = false
        barChart.leftAxis.enabled = false
        barChart.leftAxis.axisMinimum = 0.0
        barChart.leftAxis.axisMaximum = 1.05
        //barChart.leftAxis.labelTextColor = .white
        //barChart.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: formatter)
        barChart.leftAxis.labelTextColor = .white
        barChart.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: formatter)
        barChart.rightAxis.enabled = false
        
        dataSet.label = "Intervalos"
        dataSet.colors = [UIColor.init(red: 0.70, green: 0.89, blue: 0.80, alpha: 1), // #b3e2cd
            UIColor.init(red: 0.99, green: 0.80, blue: 0.67, alpha: 1), // #fdcdac
            UIColor.init(red: 0.80, green: 0.84, blue: 0.91, alpha: 1), // #cbd5e8
            UIColor.init(red: 0.96, green: 0.79, blue: 0.89, alpha: 1) // #f4cae4
        ]
        dataSet.valueFont = UIFont(name: "KohinoorBangla-Regular", size: 11)!
        dataSet.valueColors = [UIColor.white]
        dataSet.valueFormatter = DefaultValueFormatter(formatter: formatter)
        
        //This must stay at end of function
        barChart.notifyDataSetChanged()
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

