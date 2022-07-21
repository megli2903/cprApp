//
//  CCStatsViewController.swift
//  chestCompressionSkill
//
//  Created by 2022 Summer Internship on 7/7/22.
//

import UIKit

class CCStatsViewController: UIViewController {

    var goodCCCt: Int! // # of good CC during time (30 sec) should be in range of 60 to
    var totalTouchCt: Int! // # of times of attemped CC
    
    @IBOutlet weak var pressureAccuracyBar: UIProgressView!
    @IBOutlet weak var pressureAccuracyLabel: UILabel!
    @IBOutlet weak var speedAccuracyBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // PRESSURE BAR
        var newgoodCCCt = (goodCCCt ?? 0)
        var newgoodtotalTouchCt = (totalTouchCt ?? 1)
        print("\(goodCCCt ?? 0)")
        print("\(totalTouchCt ?? 1)")
        var percentGoodCCs = Double(newgoodCCCt) / Double(newgoodtotalTouchCt)
        if percentGoodCCs > 0.95 { //range is 50->60.... in percent idk what it would be
            pressureAccuracyBar.tintColor = UIColor.green
        } else {
            pressureAccuracyBar.tintColor = UIColor.yellow
        }
        pressureAccuracyBar.progress = Float(percentGoodCCs)
        let percentRounded = String(format: "%.0f", percentGoodCCs*100)
        pressureAccuracyLabel.text = percentRounded + "%"
        pressureAccuracyLabel.textAlignment = NSTextAlignment.right
        
        //SPEED BAR
        speedAccuracyBar.progress = Float(Double(newgoodtotalTouchCt)/Double(100))
        if totalTouchCt > 60 { //range is 50->60.... in percent idk what it would be
            speedAccuracyBar.tintColor = UIColor.red
        } else if totalTouchCt < 50 {
            speedAccuracyBar.tintColor = UIColor.yellow
        } else {
            speedAccuracyBar.tintColor = UIColor.green
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
