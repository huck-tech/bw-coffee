//
//  MarketMapView.swift
//  Bellwether Coffee
//
//  Created by Gabriel Pierannunzi on 1/24/18.
//  Copyright © 2018 Bellwether Coffee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

enum MarketMapViewStyle {
    case standard
    case skinned
}

class MarketMapView: ComponentView {
    
//    var location: Location? {
//        didSet { updateLocation() }
//    }
    
    var style: MarketMapViewStyle? {
        didSet { updateStyle() }
    }
    
    var map: MKMapView = {
        let mapView = MKMapView(frame: .zero)
        mapView.mapType = .mutedStandard
        mapView.isUserInteractionEnabled = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    override func setupViews() {
        setupAppearance()
        setupLayout()
    }
    
    func setupAppearance() {
        layer.masksToBounds = true
        layer.cornerRadius = 6
    }
    
    func setupLayout() {
        addSubview(map)
        
        map.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        map.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        map.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        map.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
//    func updateLocation() {
//        guard let lat = location?.latitude else { return }
//        guard let lon = location?.longitude else { return }
//        
//        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
//        let zoomSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
//        map.region = MKCoordinateRegion(center: coordinate, span: zoomSpan)
//        
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = coordinate
//        map.addAnnotation(annotation)
//    }
    
    func updateStyle() {
        guard let mapStyle = style else { return }
        
        // set style
print("\(#function).\(mapStyle)")    }
    
}
