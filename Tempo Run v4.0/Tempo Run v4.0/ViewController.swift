//
//  ViewController.swift
//  Tempo Run v4.0
//
//  Created by Jimmy Maslen on 6/20/19.
//  Copyright © 2019 Jimmy Maslen. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit
import CoreLocation

var audioPlayer = AVAudioPlayer()


class ViewController: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let locationManager = CLLocationManager()
    
    var songs:[String] = []
    
    var currentSong:String = ""
    
    @IBOutlet weak var desiredDistanceTextField: UITextField!
    
    @IBOutlet weak var desiredTimeTextField: UITextField!
    
    @IBOutlet weak var paceLabel: UILabel!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    var desiredSpeed = Double()

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = self
        pickerView.dataSource = self
        
        gettingSongName()
        
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
    }
    
    /*
        Required picker view functions
    */
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return songs.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return songs[row]
    }
    
    /*
        Setup functions
    */
    
    func gettingSongName()
    {
        let folderURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
        
        do
        {
            let songPath = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for song in songPath
            {
                var mySong = song.absoluteString
                
                if mySong.contains(".mp3")
                {
                    let findString = mySong.components(separatedBy: "/")
                    mySong = findString[findString.count - 1]
                    mySong = mySong.replacingOccurrences(of: "%20", with: " ")
                    mySong = mySong.replacingOccurrences(of: "%5B", with: "[")
                    mySong = mySong.replacingOccurrences(of: "%5D", with: "]")
                    mySong = mySong.replacingOccurrences(of: ".mp3", with: "")
                    songs.append(mySong)
                }
            }
            pickerView.reloadAllComponents()
        }
        catch
        {
            print("Error in loading songs")
        }
    }
    
    /*
        Listener functins
    */
    
    @IBAction func startButtonPress(_ sender: Any) {
        // Do calcs for pace
        if desiredDistanceTextField.text == "" || desiredTimeTextField.text == "" {
            // Switch to alert
            let alert = UIAlertController(title: "Error", message: "Not all fields are filled out.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else {
            if let desiredDistance = Double(desiredDistanceTextField.text!) {
                if let desiredTime = Double(desiredTimeTextField.text!) {
                    desiredSpeed = desiredDistance/desiredTime * 26.8224
                    paceLabel.text = String(round(100 * desiredSpeed)/100)
                    playSong()
                } else {
                    // Switch to alert
                    let alert = UIAlertController(title: "Error", message: "Time input is not a number.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "Distance input it not a number.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let speedValue: Double = manager.location?.speed else { return }
        audioPlayer.rate = Float(speedValue/desiredSpeed)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentSong = songs[row]
    }
    
    /*
    Additional functins
    */
    
    func playSong() {
        do
        {
            let audioPath = Bundle.main.path(forResource: currentSong, ofType: ".mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            audioPlayer.enableRate = true
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        }
        catch
        {
            print("Error in playing selected song")
        }
        locationManager.startUpdatingLocation()
    }

    
}

