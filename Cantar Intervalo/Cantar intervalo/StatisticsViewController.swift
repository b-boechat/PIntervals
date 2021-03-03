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

    var exerciseOption: ExerciseType?
    var plotOption: PlotType?
    var timeOption: Int?
    
    
    // Context for core data storage.
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Stores exercise results.
    var results = [ExerciseResult]()
    
    // Gets calendar from user device.
    let calendar = Calendar.current
    
    // Gets current date.
    let currentDate = Date()
    
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var pieChart: PieChartView!
    
    @IBOutlet var intervalButtons: [UIButton]!
    
    
    
    @IBOutlet weak var portraitViewWarning: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let exerciseTypePassed = exerciseOption!
        let plotTypePassed = plotOption!
        let timeTypePassed = timeOption!
        
        //print (exerciseTypePassed)
        //print (plotTypePassed)
        //print (timeTypePassed)
        
        intervalButtons.forEach{(button) in
            self.view.bringSubview(toFront: button)
        }
        
        adjustIntervalButtonsColors(forActiveTag: 0)
        
        changeOrientation()
        
        fetchResults()
        //removeResults()
        //replaceWithDebugResults(resultsAsStruct4)
        
        
        // Setup no data appearance. Bar chart has to be "" since it contains pie chart and, as such, must always be visible.
        barChart.noDataText = ""
        pieChart.noDataText = "Responda mais exercícios para obter resultados para esse intervalo!"
        pieChart.noDataTextColor = .white
        pieChart.noDataFont = UIFont(name: "KohinoorBangla-Regular", size: 14)!
        
        presentSpecifiedStatistics(plotType: plotTypePassed, exerciseType: exerciseTypePassed, numberOfPastDaysConsidered: timeTypePassed)
        
 

    }
    
    func presentSpecifiedStatistics(plotType: PlotType, exerciseType: ExerciseType, numberOfPastDaysConsidered: Int, intervalReference: Int16 = 1) {
        
        // Filter results by specified exercise type and date range.
        let filteredResults = filterResults{
            return $0.exerciseType == exerciseType.rawValue &&
                    (calendar).dateComponents([.day], from: $0.date!, to: currentDate).day! <= numberOfPastDaysConsidered
        }
        if plotType == .intervalAccuracyPlot {
            plotIntervalAccuracy(filteredResults)
        }
        else {
            plotIntervalConfusion(filteredResults, reference: intervalReference, exerciseType: exerciseType)
        }
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
            portraitViewWarning.alpha = 0.0
            if plotOption == PlotType.intervalAccuracyPlot {
                barChart.alpha = 1.0
                pieChart.isUserInteractionEnabled = true
                barChart.isUserInteractionEnabled = true
                pieChart.alpha = 0.0
                intervalButtons.forEach{(button) in
                    button.isEnabled = false
                    button.alpha = 0.0
                }

            }
            else {
                pieChart.alpha = 1.0
                pieChart.isUserInteractionEnabled = true
                barChart.isUserInteractionEnabled = true
                barChart.alpha = 1.0
                intervalButtons.forEach{(button) in
                    button.isEnabled = true
                    button.alpha = 1.0
                }
                
            }
        }
        else {
            // Enable portrait warning and disable charts.
            barChart.alpha = 0.0
            barChart.isUserInteractionEnabled = false
            pieChart.alpha = 0.0
            pieChart.isUserInteractionEnabled = false
            portraitViewWarning.alpha = 1.0
            intervalButtons.forEach{(button) in
                button.isEnabled = false
                button.alpha = 0.0
            }
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
        // Removes all saved results.
        
        fetchResults()
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
    
    func calculateIntervalConfusion(providedResults: [ExerciseResult], reference: Int16, exerciseType: ExerciseType) -> [PieChartDataEntry]? {
        // Filter results by given correct interval, and calculate their total count.
        let resultsWithSpecifiedInterval = filterResults(providedResults){$0.correctInterval == reference}
        let totalCount = Double(resultsWithSpecifiedInterval.count)
        if totalCount == 0 {
            // No data exists for this interval, among consideredResults.
            return nil
        }
        
        var confusionArray = [PieChartDataEntry]()
        // Loops through possible intervals.
        let ranges = [reference..<(12+1), 1..<reference]
        for i in ranges.joined() {
            // For each interval, calculate the percentage of times it was answered, when reference was the correct answer.
            var confusion : Double = 0
            resultsWithSpecifiedInterval.forEach{
                if $0.answeredInterval == Int16(i) {
                    confusion += 1
                }
            }
            //print("i = \(i): \(confusion/totalCount)")
            confusionArray.append(PieChartDataEntry(value: confusion/totalCount, label: intervalsShortNameArray[Int(i)-1]))
        }
        if exerciseType == .singingExercise {
            // No note maintained has to be added.
            var confusion : Double = 0
            resultsWithSpecifiedInterval.forEach{
                if $0.answeredInterval == NO_NOTE_MAINTAINED {
                    confusion += 1
                }
            }
            confusionArray.append(PieChartDataEntry(value: confusion/totalCount, label: "Sem nota"))
        }
        
        
        return confusionArray
    }
    
    
    
    func plotIntervalConfusion (_ filteredResults: [ExerciseResult], reference: Int16, exerciseType: ExerciseType) {
        
        // Exercise type has to be passed because of NO_NOTE_MAINTAINED
        
        guard let entries = calculateIntervalConfusion(providedResults: filteredResults, reference: reference, exerciseType: exerciseType) else {
            // Display noDataText
            pieChart.data = nil
            pieChart.notifyDataSetChanged()
            return
        }
        let dataSet = PieChartDataSet(values: entries, label: "")
        let data = PieChartData(dataSet: dataSet)
        pieChart.data = data
        barChart.chartDescription?.text = ""
        
        dataSet.colors = [UIColor.init(red: 0.670, green: 1.0, blue: 0.365, alpha: 1),
                          
                          UIColor.init(red: 1.00, green: 1.00, blue: 0.70, alpha: 1), // #ffffb2
                          UIColor.init(red: 1.00, green: 0.80, blue: 0.36, alpha: 1), // #fecc5c
                          UIColor.init(red: 0.99, green: 0.55, blue: 0.24, alpha: 1), // #fd8d3c
                          UIColor.init(red: 0.94, green: 0.23, blue: 0.13, alpha: 1), // #f03b20
                          UIColor.init(red: 0.74, green: 0.0, blue: 0.15, alpha: 1), // #bd0026
            
                          UIColor.init(red: 0.74, green: 0.0, blue: 0.74, alpha: 1), //
            
                          UIColor.init(red: 0.74, green: 0.0, blue: 0.15, alpha: 1), // #bd0026
                          UIColor.init(red: 0.94, green: 0.23, blue: 0.13, alpha: 1), // #f03b20
                          UIColor.init(red: 0.99, green: 0.55, blue: 0.24, alpha: 1), // #fd8d3c
                          UIColor.init(red: 1.00, green: 0.80, blue: 0.36, alpha: 1), // #fecc5c
                          UIColor.init(red: 1.00, green: 1.00, blue: 0.70, alpha: 1), // #ffffb2
            
                          UIColor.init(red: 0.3, green: 0.3, blue: 0.3, alpha: 1) // For NO_NOTE_MAINTAINED, it's the same color as missing result for the interval accuracy plot.
        ]
        
        
        dataSet.valueFont = UIFont(name: "KohinoorBangla-Regular", size: 12)!
        dataSet.valueColors = [UIColor.black, UIColor.black, UIColor.black, UIColor.black,
                               UIColor.white, UIColor.white, UIColor.white, UIColor.white, UIColor.white,
                               UIColor.black, UIColor.black, UIColor.black,
                               UIColor.white
        ]
        
        
        
        dataSet.valueFormatter = PieChartValueFormatter()
        
        dataSet.selectionShift = 0
        //dataSet.drawValuesEnabled = false
        
        pieChart.legend.textColor = UIColor.white
        pieChart.legend.font = UIFont(name: "KohinoorBangla-Regular", size: 12)!
        pieChart.chartDescription?.text = ""
        pieChart.holeRadiusPercent = 0.3
        pieChart.transparentCircleRadiusPercent = 0.35
        pieChart.drawEntryLabelsEnabled = false
        
        
        
        pieChart.notifyDataSetChanged()
        
    }
    
    func plotIntervalAccuracy(_ filteredResults: [ExerciseResult]) {
        
        var entries = [BarChartDataEntry]()
        var resultsExistForInterval = [Bool](repeating: true, count: 12)
        //var resultsExistForInterval = [Bool](repeating: true, count: 12)
        // Get correct answer percentage for each interval.
        for i in 1 ... 12 {
            var accuracy = calculateIntervalAnswerAccuracy(providedResults: filteredResults,  rawInterval: Int16(i))
            if accuracy == nil {
                accuracy = 0.5
                resultsExistForInterval[i-1] = false
            }
            entries.append(BarChartDataEntry(x: Double(i), y: accuracy!))
        }
        // Create plot
        let dataSet = BarChartDataSet(values: entries, label: "Intervalos")
        let data = BarChartData(dataSets: [dataSet])
        barChart.data = data
        // Customize plot.
        
        barChart.chartDescription?.text = ""
        //barChart.chartDescription?.textColor = .white
        //barChart.chartDescription?.font = UIFont(name: "KohinoorBangla-Regular", size: 11)!
        
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
        
        let missingResultColor = UIColor.init(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
        
        //print(resultsExistForInterval[0])
        
        dataSet.label = "Intervalos"
        dataSet.colors = [resultsExistForInterval[0] ? UIColor.init(red: 0.70, green: 0.89, blue: 0.80, alpha: 1) : missingResultColor, // #b3e2cd
            resultsExistForInterval[1] ? UIColor.init(red: 0.99, green: 0.80, blue: 0.67, alpha: 1) : missingResultColor, // #fdcdac
            resultsExistForInterval[2] ? UIColor.init(red: 0.80, green: 0.84, blue: 0.91, alpha: 1) : missingResultColor, // #cbd5e8
            resultsExistForInterval[3] ? UIColor.init(red: 0.96, green: 0.79, blue: 0.89, alpha: 1) : missingResultColor, // #f4cae4
            resultsExistForInterval[4] ? UIColor.init(red: 0.70, green: 0.89, blue: 0.80, alpha: 1) : missingResultColor, // #b3e2cd
            resultsExistForInterval[5] ? UIColor.init(red: 0.99, green: 0.80, blue: 0.67, alpha: 1) : missingResultColor, // #fdcdac
            resultsExistForInterval[6] ? UIColor.init(red: 0.80, green: 0.84, blue: 0.91, alpha: 1) : missingResultColor, // #cbd5e8
            resultsExistForInterval[7] ? UIColor.init(red: 0.96, green: 0.79, blue: 0.89, alpha: 1) : missingResultColor, // #f4cae4
            resultsExistForInterval[8] ? UIColor.init(red: 0.70, green: 0.89, blue: 0.80, alpha: 1) : missingResultColor, // #b3e2cd
            resultsExistForInterval[9] ? UIColor.init(red: 0.99, green: 0.80, blue: 0.67, alpha: 1) : missingResultColor, // #fdcdac
            resultsExistForInterval[10] ? UIColor.init(red: 0.80, green: 0.84, blue: 0.91, alpha: 1) : missingResultColor, // #cbd5e8
            resultsExistForInterval[11] ? UIColor.init(red: 0.96, green: 0.79, blue: 0.89, alpha: 1) : missingResultColor // #f4cae4
        ]
        dataSet.valueFont = UIFont(name: "KohinoorBangla-Regular", size: 11)!
        dataSet.valueColors = [UIColor.white]
        dataSet.valueFormatter = DefaultValueFormatter(formatter: formatter)
        
        //This must stay at end of function
        barChart.notifyDataSetChanged()
    }
    
    
    func adjustIntervalButtonsColors(forActiveTag tag: Int) {
        intervalButtons.forEach{(button) in
            if button.tag == tag {
                button.backgroundColor = UIColor.init(red: 240/255, green: 122/255, blue: 160/255, alpha: 1.0) // #f58142
            }
            else {
                button.backgroundColor = UIColor.init(red: 0.45, green: 0.56, blue: 1.00, alpha: 1.0) // #728fff
            }
        }
    }
    
    @IBAction func changeReferenceForIntervalConfusion(_ sender: UIButton) {
        //print(sender.tag)
        
        adjustIntervalButtonsColors(forActiveTag: sender.tag)
        
        presentSpecifiedStatistics(plotType: plotOption!, exerciseType: exerciseOption!, numberOfPastDaysConsidered: timeOption!, intervalReference: Int16(sender.tag + 1))
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

public class PieChartValueFormatter: NSObject, IValueFormatter {
    public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return value == 0 ? "" : formatter.string(from: NSNumber(value:value))!
    }
}



