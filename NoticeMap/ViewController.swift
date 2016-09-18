//
//  ViewController.swift
//  NoticeMap
//
//  Created by 新井　一希 on 2016/08/30.
//  Copyright © 2016年 arawi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var LocationManager: CLLocationManager!
    
    var pinCoordinate: CLLocationCoordinate2D!
    
    var pin: MKPointAnnotation!
    
    var locationRegion: MKCoordinateRegion!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //マネージャーのインスタンスを生成
        LocationManager = CLLocationManager()
        
        //delegateを生成
        LocationManager.delegate = self
        
        //GPSの更新間隔距離
        LocationManager.distanceFilter = 10.0
        
        //GPSの精度（10m以内）
        LocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        //GPS利用の許可を得ているかどうかのステータスを取得
        let status = CLLocationManager.authorizationStatus()
        
        //まだ許可を得ていない場合は、認証ダイアログを表示
        if (status == CLAuthorizationStatus.NotDetermined) {
            self.LocationManager.requestAlwaysAuthorization()
        }
        
        //位置情報更新開始
        LocationManager.startUpdatingLocation()
        
        //delegate生成
        mapView.delegate = self
        
        //とりあえず東京駅でも中心にしておく
        let lat: CLLocationDegrees = 35.681298
        let lon: CLLocationDegrees = 139.766247
        //この二つをまとめて2D座標データにする
        let firstCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lon)
        
        //縮尺
        let latDist: CLLocationDistance = 1000
        let lonDist: CLLocationDistance = 1000
        
        //これらの情報を全部まとめたRegionを作成
        locationRegion = MKCoordinateRegionMakeWithDistance(firstCoordinate, latDist, lonDist)
        
        //ピンの座標をとりあえず東京駅にしとく
        pinCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    //右下のボタンが置かれた時、現在地を中心にする。
    @IBAction func locationCenter(sender: AnyObject) {
        mapView.setRegion(locationRegion, animated: true)
    }
    
    
    //GPSから値を取得した時に呼び出されるメソッド
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        //取得した緯度・経度はこのプロパティに格納されてる
        let ido: CLLocationDegrees! = newLocation.coordinate.latitude
        let keido: CLLocationDegrees! = newLocation.coordinate.longitude
        //この二つをまとめて2D座標データにする
        let nowLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(ido, keido)
        
        //縮尺
        let latDist: CLLocationDistance = 1000
        let lonDist: CLLocationDistance = 1000
        
        //これらの情報を全部まとめたRegionを作成
        locationRegion = MKCoordinateRegionMakeWithDistance(nowLocation, latDist, lonDist)
        
        //現在地の緯度と経度（CLLocationDegrees）からCLLocation型を生成
        let nowLoc:CLLocation = CLLocation(latitude: ido, longitude: keido)
        
        //ピンの緯度と経度（CLLocationDegrees）からCLLocation型を生成
        let pinLoc:CLLocation = CLLocation(latitude: pinCoordinate.latitude, longitude: pinCoordinate.longitude)
        
        //現在地とピンとの距離を計算（単位はメートルっぽい）
        let dist = pinLoc.distanceFromLocation(nowLoc)
        
    }
    
    //長押しした時に、ピンを立てる
    @IBAction func MakePin(sender: UILongPressGestureRecognizer) {
        
        //長押し中に何度もピンを生成しないようにする。
        //UILongPressGestureRecognizerのstateがBegan以外だったら動作をしない。
        if sender.state != UIGestureRecognizerState.Began {
            return
        }
        
        //長押しした地点の座標を取得。
        let pinLocation:CGPoint = sender.locationInView(mapView)
        
        //ピンの座標をCGPointからCLLocationCoordinate2Dに変換
        pinCoordinate = mapView.convertPoint(pinLocation, toCoordinateFromView: mapView)
        
        //ピンを生成
        pin = MKPointAnnotation()
        
        //ピンの座標を指定
        pin.coordinate = pinCoordinate
        
        //タイトル
        pin.title = "指定された地点"
        
        //Mapに反映
        mapView.addAnnotation(pin)
        
    }
    
    /*
    目指す目標
    ・ピンを複数個登録できるようにする。
    ・登録したピンの座標を端末に保存する。
    ・ピンをタップしたら、名前とともにあと??ｍみたいなのを表示するようにする。
    ・ピンを登録する時に「タイトル」「ジャンル」みたいなのを決めれるようにする。
    ・ジャンルを管理する画面を作る。
    */
    
    //addAnnotation（ピンをMapに反映）したときに呼ばれるデリゲートメソッド
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        //addAnnotationが現在地についての動作だったとき
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinIdentifier = "PinAnnotationIdentifier"
        
        //ピンを生成
        let pinView: MKPinAnnotationView!
        
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdentifier)
            
        //アニメーションをつける
        pinView.animatesDrop = true
            
        //吹き出しを表示する
        pinView.canShowCallout = true
        
        //annotationを設定
        pinView.annotation = annotation
        return pinView
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

