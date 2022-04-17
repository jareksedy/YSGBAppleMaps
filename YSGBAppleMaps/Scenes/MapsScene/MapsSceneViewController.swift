//
//  MapsSceneViewController.swift
//  YSGBAppleMaps
//
//  Created by Ярослав on 19.03.2022.
//

import UIKit
import MapKit
import CoreLocation
import RealmSwift
import SwiftUI

// MARK: - Protocol
protocol MapsSceneViewDelegate: NSObjectProtocol {
    func removeAllOverlays()
    func showRoute(_ routesArray: [UserPersistedRoute], index: Int)
    func showNoPersistedRoutesMessage()
    func showStartTrackingMessage()
    func showStopTrackingMessage()
}

// MARK: - Implementation
extension MapsSceneViewController: MapsSceneViewDelegate {
    func removeAllOverlays() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
    }
    
    func showRoute(_ routesArray: [UserPersistedRoute], index: Int = 0) {
        guard index < presenter.persistedRoutesCount else { return }
        let currentRoute = routesArray[index]
        
        removeAllOverlays()
        
        var coordinatesArray: [CLLocationCoordinate2D] = []
        currentRoute.coordinates.forEach { coordinate in
            coordinatesArray.append(coordinate.coordinate)
        }
        
        isTracking = false
        
        let myRoutePolyLine = MKPolyline(coordinates: coordinatesArray, count: coordinatesArray.count)
        mapView.addOverlay(myRoutePolyLine)
        
        if let middle = coordinatesArray.middle {
            lastLocation = CLLocation(latitude: middle.latitude, longitude: middle.longitude)
            mapView.zoomToLocation(lastLocation!, regionRadius: zoomValue)
        }
        
        let distance = MKPointAnnotation()
        distance.title = "Расстояние: \(presenter.calculateDistance(coordinatesArray)) м."
        distance.coordinate = coordinatesArray.middle!
        mapView.addAnnotation(distance)
        
        //quickAlert(message: "Расстояние: \(presenter.calculateDistance(coordinatesArray)) м.")
    }
    
    func showNoPersistedRoutesMessage() {
        quickAlert(message: "Нет сохраненных маршрутов.") { self.isShowingPreviousRoute = false }
    }
    
    func showStartTrackingMessage() {
        quickAlert(message: "Началась запись маршрута.")
    }
    
    func showStopTrackingMessage() {
        quickAlert(message: "Запись маршрута остановлена.")
    }
}

// MARK: - Additional extensions
extension MapsSceneViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = extractImage(from: info) { self.avatarImage = image }
        if let avatarImage = avatarImage { print(avatarImage) }
        picker.dismiss(animated: true)
    }
    
    private func extractImage(from info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage { return image } else
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage { return image } else { return nil }
    }
}

extension MapsSceneViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            if isShowingPreviousRoute == false {
                mapView.zoomToLocation(location, regionRadius: zoomValue)
                lastLocation = location
            }
            
            if isTracking {
                presenter.addCoordinate(location.coordinate)
                let myRoutePolyLine = MKPolyline(coordinates: presenter.coordinates, count: presenter.coordinates.count)
                mapView.addOverlay(myRoutePolyLine)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension MapsSceneViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyLineRenderer = MKPolylineRenderer(overlay: overlay)
        
        polyLineRenderer.strokeColor = isShowingPreviousRoute ? .systemRed : .tintColor
        polyLineRenderer.lineWidth = 10
        
        return polyLineRenderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKPointAnnotation) else { return nil }
        //guard let avatarImage = avatarImage else { return nil }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        let pinImage = avatarImage ?? UIImage(named: "uni_avatar")!
        annotationView!.image = pinImage.imageResize(sizeChange: CGSize(width: 50.0, height: 50.0)).makeRounded()
        
        return annotationView
    }
}

// MARK: - View controller
class MapsSceneViewController: UIViewController {
    lazy var presenter = MapsScenePresenter(locationManager: locationManager, realm: realm)
    
    // MARK: - Services
    let locationManager = CLLocationManager()
    let realm = try! Realm()
    
    // MARK: - Properties
    var avatarImage: UIImage?
    var zoomValue: Double = 300
    var lastLocation: CLLocation?
    var currentRouteIndex: Int = 0 {
        didSet {
            if currentRouteIndex == 0 && presenter.persistedRoutesCount == 2 {
                previousRouteButton.isEnabled = false
                nextRouteButton.isEnabled = true
                return
            }
            
            if currentRouteIndex == presenter.persistedRoutesCount - 1 && presenter.persistedRoutesCount == 2 {
                previousRouteButton.isEnabled = true
                nextRouteButton.isEnabled = false
            }
            
            if currentRouteIndex == 0 {
                previousRouteButton.isEnabled = false
                return
            }
            
            if currentRouteIndex == presenter.persistedRoutesCount - 1 {
                nextRouteButton.isEnabled = false
                return
            }
            
            previousRouteButton.isEnabled = true
            nextRouteButton.isEnabled = true
        }
    }
    
    var isTracking: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.25) {
                if self.isTracking {
                    self.startStopTrackingButton.transform = CGAffineTransform(rotationAngle: .pi / 4 * 3)
                    self.startStopTrackingButton.tintColor = UIColor.systemRed
                } else {
                    self.startStopTrackingButton.transform = .identity
                    self.startStopTrackingButton.tintColor = UIColor.tintColor
                }
            }
        }
    }
    
    var isShowingPreviousRoute: Bool = false {
        didSet {
            mapView.isScrollEnabled = isShowingPreviousRoute
            mapView.showsUserLocation = !isShowingPreviousRoute
            
            if isShowingPreviousRoute {
                previousButtonConstraint.constant = 10
                nextButtonConstraint.constant = 10
            } else {
                previousButtonConstraint.constant = -10
                nextButtonConstraint.constant = -10
            }
            
            UIView.animate(withDuration: 0.25) {
                if self.isShowingPreviousRoute {
                    self.showPreviousRouteButton.transform = CGAffineTransform(rotationAngle: .pi / 4 * 3)
                    self.showPreviousRouteButton.tintColor = UIColor.systemRed
                    
                    if self.presenter.persistedRoutesCount > 1 {
                        self.nextRouteButton.alpha = 1
                        self.previousRouteButton.alpha = 1
                    }
                    
                    self.view.layoutIfNeeded()
                } else {
                    self.showPreviousRouteButton.transform = .identity
                    self.showPreviousRouteButton.tintColor = UIColor.tintColor
                    self.nextRouteButton.alpha = 0
                    self.previousRouteButton.alpha = 0
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    // MARK: - Methods
    private func setupScene() {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        presenter.configureLocationManager()
        mapView.delegate = self
        
        previousRouteButton.alpha = 0
        nextRouteButton.alpha = 0
        zoomInButton.alpha = 0
        zoomOutButton.alpha = 0
        
        zoomInButtonConstraint.constant = 25
        zoomOutButtonConstraint.constant = 25
        
        UIView.animate(withDuration: 0.25) {
            self.zoomInButton.alpha = 1
            self.zoomOutButton.alpha = 1
            self.view.layoutIfNeeded()
        }
        
        if presenter.persistedRoutesCount == 0 {
            showPreviousRouteButton.alpha = 0
            deletePersistedRoutesButton.alpha = 0
        }
    }
    
    private func presentImagePicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.cameraDevice = .front
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        self.present(imagePickerController, animated: true)
    }
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startStopTrackingButton: CircularButton!
    @IBOutlet weak var showPreviousRouteButton: CircularButton!
    @IBOutlet weak var zoomInButton: CircularButton!
    @IBOutlet weak var zoomOutButton: CircularButton!
    @IBOutlet weak var previousRouteButton: CircularButton!
    @IBOutlet weak var nextRouteButton: CircularButton!
    @IBOutlet weak var deletePersistedRoutesButton: CircularButton!
    @IBOutlet weak var selfieButton: CircularButton!
    
    // MARK: - Constraint outlets
    @IBOutlet weak var previousButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var zoomInButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var zoomOutButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var showRouteButtonConstraint: NSLayoutConstraint!
    
    
    // MARK: - Actions
    @IBAction func startStopTrackingButtonTapped(_ sender: Any) {
        isTracking.toggle()
        isShowingPreviousRoute = false
        removeAllOverlays()
        
        if isTracking { presenter.startTracking() } else { presenter.stopTracking() }
        
        if !isTracking && presenter.persistedRoutesCount > 0 {
            
            deleteButtonConstraint.constant = 25
            showRouteButtonConstraint.constant = 25
            
            UIView.animate(withDuration: 0.25) {
                self.deletePersistedRoutesButton.alpha = 1
                self.showPreviousRouteButton.alpha = 1
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func showPreviousRouteButtonTapped(_ sender: Any) {
        currentRouteIndex = presenter.persistedRoutesCount - 1
        previousRouteButton.isEnabled = true
        
        if isTracking {
            self.yesNoAlert(title: "Прервать запись?", message: "Для отображения сохраненных маршрутов необходимо прервать запись текущего маршрута.") { _ in
                self.removeAllOverlays()
                self.isTracking = false
                self.isShowingPreviousRoute = true
                self.showRoute(self.presenter.getPersistedRoutes(), index: self.currentRouteIndex)
            }
        } else {
            isShowingPreviousRoute.toggle()
        }
        
        if isShowingPreviousRoute { presenter.loadRoutes() } else { removeAllOverlays() }
    }
    
    @IBAction func zoomInButtonTapped(_ sender: Any) {
        guard zoomValue > 200 else { return }
        zoomValue -= 200
        
        if let lastLocation = lastLocation {
            mapView.zoomToLocation(lastLocation, regionRadius: zoomValue)
        }
    }
    
    @IBAction func zoomOutButtonTapped(_ sender: Any) {
        guard zoomValue < 100_000 else { return }
        zoomValue += 300
        
        if let lastLocation = lastLocation {
            mapView.zoomToLocation(lastLocation, regionRadius: zoomValue)
        }
    }
    
    @IBAction func previousRouteButtonTapped(_ sender: Any) {
        guard currentRouteIndex > 0, isShowingPreviousRoute else { return }
        currentRouteIndex -= 1
        showRoute(presenter.getPersistedRoutes(), index: currentRouteIndex)
    }
    
    @IBAction func nextRouteButtonTapped(_ sender: Any) {
        guard currentRouteIndex < presenter.persistedRoutesCount - 1, isShowingPreviousRoute else { return }
        currentRouteIndex += 1
        showRoute(presenter.getPersistedRoutes(), index: currentRouteIndex)
    }
    
    @IBAction func deletePersistedRoutesButtonTapped(_ sender: Any) {
        self.yesNoAlert(title: "Удалить все маршруты?", message: "Вы действительно желаете удалить все сохраненные маршруты?") { _ in
            self.isTracking = false
            self.isShowingPreviousRoute = false
            self.removeAllOverlays()
            self.presenter.deleteAllPersistedRoutes()
            self.deleteButtonConstraint.constant = 0
            self.showRouteButtonConstraint.constant = 0
            UIView.animate(withDuration: 0.25) {
                self.deletePersistedRoutesButton.alpha = 0
                self.showPreviousRouteButton.alpha = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func selfieButtonTapped(_ sender: Any) {
        presentImagePicker()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewDelegate = self
        setupScene()
    }
}
