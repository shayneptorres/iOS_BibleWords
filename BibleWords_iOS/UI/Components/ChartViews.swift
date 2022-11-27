//
//  PieChartView.swift
//  BibleWords_iOS
//
//  Created by Shayne Torres on 11/23/22.
//

import Foundation
import SwiftUI
import Charts

struct WordIntervalPieChartView: UIViewRepresentable {
    @Binding var intervalWords: [Int:[Bible.WordInfo]]
    private let pieChartView = PieChartView()
    
    func makeUIView(context: Context) -> some PieChartView {
        pieChartView.data = chartData(from: intervalWords)
        return pieChartView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        pieChartView.data = chartData(from: intervalWords)
    }
    
    func chartData(from: [Int:[Bible.WordInfo]]) -> PieChartData {
        var chartDataEntries: [PieChartDataEntry] = []
        
        for set in intervalWords.sorted(by: { $0.key > $1.key }) {
            chartDataEntries.append(PieChartDataEntry(value: Double(set.value.count), label: set.key.toShortPrettyTime))
        }
        
        let chartData = PieChartData(dataSet: PieChartDataSet(entries: chartDataEntries))
        return chartData
    }
}

struct WordIntervalBarChartView: UIViewRepresentable {
    @Binding var intervalWords: [Int:[Bible.WordInfo]]
    private let barChartView = BarChartView()
    
    func makeUIView(context: Context) -> some BarChartView {
        barChartView.data = chartData(from: intervalWords)
        barChartView.xAxis.valueFormatter = IntervalBarChartFormatter()
        barChartView.pinchZoomEnabled = false
        barChartView.dragEnabled = false
    
        return barChartView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        barChartView.data = chartData(from: intervalWords)
    }
    
    func chartData(from: [Int:[Bible.WordInfo]]) -> BarChartData {
        var chartDataEntries: [BarChartDataEntry] = []
        
        for set in intervalWords.sorted(by: { $0.key > $1.key }) {
            let entry = BarChartDataEntry(x: Double(set.key), y: Double(set.value.count))
            chartDataEntries.append(entry)
        }
        let dataSet = BarChartDataSet(entries: chartDataEntries)
        dataSet.colors = [UIColor(.accentColor)]
        let chartData = BarChartData(dataSet: dataSet)
        return chartData
    }
    
    class IntervalBarChartFormatter: AxisValueFormatter {
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            VocabWord.defaultSRIntervals[value.toInt].toShortPrettyTime
        }
    }
}

struct WordProgressLineChart: UIViewRepresentable {
    @Binding var intervals: [Int]
    private let lineChartView = LineChartView()
    
    func makeUIView(context: Context) -> some LineChartView {
        lineChartView.data = chartData(from: intervals)
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawAxisLineEnabled = false
        lineChartView.rightAxis.drawAxisLineEnabled = false
        lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.drawLabelsEnabled = false
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.legend.enabled = false
        
        
        return lineChartView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        lineChartView.data = chartData(from: intervals)
    }
    
    func chartData(from: [Int]) -> LineChartData {
        var chartDataEntries: [ChartDataEntry] = []
        
        for (i, interval) in intervals.sorted().enumerated() {
            chartDataEntries.append(ChartDataEntry(x: Double(i), y: Double(interval)))
        }
        
        let dataSet = LineChartDataSet(entries: chartDataEntries)
        dataSet.colors = [UIColor(.accentColor)]
        dataSet.valueFormatter = Formatter()
        let chartData = LineChartData(dataSet: dataSet)
        
        return chartData
    }
    
    class Formatter: ValueFormatter {
        func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
            return VocabWord.defaultSRIntervals[value.toInt].toShortPrettyTime
        }
    }
}

struct VocabActivityLineChart: UIViewRepresentable {
    @Binding var groups: [ActivityGroup]
    private let lineChartView = LineChartView()
    
    func makeUIView(context: Context) -> some LineChartView {
        lineChartView.data = updateChartData()
        let formatter = GroupXAxisBarChartFormatter()
        formatter.groups = groups
        lineChartView.xAxis.valueFormatter = formatter
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawAxisLineEnabled = false
//        lineChartView.rightAxis.drawAxisLineEnabled = false
        lineChartView.leftAxis.drawLabelsEnabled = false
//        lineChartView.rightAxis.drawLabelsEnabled = false
        
        lineChartView.xAxis.labelPosition = .bottom
//        lineChartView.xAxis.drawLabelsEnabled = false
//        lineChartView.xAxis.drawAxisLineEnabled = false
//        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.legend.enabled = false
        
        return lineChartView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        lineChartView.data = updateChartData()
        let formatter = GroupXAxisBarChartFormatter()
        formatter.groups = groups
        lineChartView.xAxis.valueFormatter = formatter
    }
    
    func updateChartData() -> LineChartData {
        var chartDataEntries: [ChartDataEntry] = []
        
        for (i, group) in groups.enumerated() {
            chartDataEntries.append(ChartDataEntry(x: Double(i), y: Double(group.entries.count)))
        }
        
        let dataSet = LineChartDataSet(entries: chartDataEntries)
        dataSet.colors = [UIColor(.accentColor)]
//        let formatter = Formatter()
//        formatter.groups = groups
//        dataSet.valueFormatter = formatter
        let chartData = LineChartData(dataSet: dataSet)
        
        return chartData
    }
    
    class GroupXAxisBarChartFormatter: AxisValueFormatter {
        var groups: [ActivityGroup] = []
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return groups[value.toInt].shortName
        }
    }
}
