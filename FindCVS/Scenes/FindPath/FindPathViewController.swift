//
//  FindPathViewController.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/07.
//

import UIKit
import MapKit
import SnapKit
import CoreLocation

final class FindPathViewController: UIViewController {

    private let map = MKMapView()
    private let currentCoordi: CLLocationCoordinate2D
    private let destinationCoordi: CLLocationCoordinate2D
    private let cafeTitle: String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupViews()
        setupDelegates()
        setupAnnotations()
        setupMKDirections()
    }
    
    init(currentCoordi: CLLocationCoordinate2D, destinationCoordi: CLLocationCoordinate2D, cafeTitle: String) {
        self.currentCoordi = currentCoordi
        self.destinationCoordi = destinationCoordi
        self.cafeTitle = cafeTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FindPathViewController {
    private func setupNavigation() {
        navigationItem.title = "길찾기"
    }
    private func setupViews() {
        view.addSubview(map)
        map.snp.makeConstraints {
            $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
    }
    private func setupDelegates() {
        map.delegate = self
    }
    private func setupAnnotations() {
        let starting = MKPointAnnotation()
        starting.coordinate = currentCoordi
        starting.title = "내위치"
        let destination = MKPointAnnotation()
        destination.coordinate = destinationCoordi
        destination.title = cafeTitle
        [ starting, destination ].forEach {
            map.addAnnotation($0)
        }
    }
    private func setupMKDirections() {
        let request = MKDirections.Request()
        request.transportType = .walking
        let startingPlaceMark = MKPlacemark(coordinate: currentCoordi)
        request.source = MKMapItem(placemark: startingPlaceMark)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationCoordi)
        request.destination = MKMapItem(placemark: destinationPlaceMark)
        request.requestsAlternateRoutes = false
        let directions = MKDirections(request: request)
        directions.calculate(completionHandler: { [weak self] res, err in
            guard let self = self, let res = res else { return }
            if err != nil {
                print("Error getting MKDirections")
            } else {
                self.showRoute(res)
            }
        })
    }
    private func showRoute(_ response: MKDirections.Response) {
        for route in response.routes {
            map.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
        }
        map.setRegion(MKCoordinateRegion(center: currentCoordi, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)), animated: true)
    }
}

extension FindPathViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .green
        renderer.lineWidth = 8.0
        return renderer
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }
        var annotationView = map.dequeueReusableAnnotationView(withIdentifier: "Custom")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Custom")
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        switch annotation.title {
        case "내위치":
            annotationView?.image = UIImage(named: "icon_person")
        case cafeTitle:
            annotationView?.image = UIImage(named: "cafe_marker")
        default:
            break
        }
        return annotationView
    }
}

