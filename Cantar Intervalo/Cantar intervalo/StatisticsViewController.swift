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
        
        let filteredResults = filterResults{$0.exerciseType == ExerciseType.singingExercise.rawValue}
        
        plotResultsByInterval(filteredResults)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            ()
        }
        else {
            
        }
    }
    
    func changeToPortraitView () {
        barChart.alpha = 0.0
        barChart.isUserInteractionEnabled = false
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
    
    func plotResultsByInterval(_ filteredResults: [ExerciseResult]) {
        
        barChart.noDataText = "Responda mais exercícios para obter estatísticas!"
        barChart.noDataTextColor = .white
        barChart.noDataFont = UIFont(name: "KohinoorBangla-Regular", size: 16)!
        
        var entries = [BarChartDataEntry]()
        // Get correct answer percentage for each interval.
        for i in 1 ... 12 {
            guard let percentage = calculateIntervalAnswerAccuracy(consideredResults: filteredResults,  rawInterval: Int16(i)) else {
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
        barChart.legend.font = UIFont(name: "KohinoorBangla-Regular", size: 11)!
        barChart.legend.textColor = .white

        
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
        

        
        //barChart.leftAxis.drawAxisLineEnabled = false
        barChart.leftAxis.enabled = false
        //barChart.leftAxis.labelTextColor = .white
        //barChart.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: formatter)
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
    
    
    
    
    
    func filterResults(rule: (ExerciseResult) -> Bool) -> [ExerciseResult] {
        // Filter results array based on provided rule. Alternative to the filter() function, which is not available for Xcode 9.x
        var filteredResults = [ExerciseResult]()
        for result in results where rule(result) {
            filteredResults.append(result)
        }
        return filteredResults
    }
    
    func calculateIntervalAnswerAccuracy(consideredResults: [ExerciseResult], rawInterval: Int16) -> Double? {
        // Returns ratio of correct exercise answers for the given interval, only among consideredResults (so they can be filtered previously, for example by exercise or date).
        
        // Filter results by given correct interval, and calculate their total count.
        let resultsWithSpecifiedInterval = filterResults{$0.correctInterval == rawInterval}
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


final class CustomFormatter: IAxisValueFormatter {
    var labels: [String] = []
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let count = self.labels.count
        guard let axis = axis, count > 0 else {
            return ""
        }
        let factor = axis.axisMaximum / Double(count)
        let index = Int((value / factor).rounded())
        if index >= 0 && index < count {
            return self.labels[index]
        }
        return ""
    }
    init(labels_: [String]){
        labels = labels_
    }
}
