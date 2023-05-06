//
//  MapViewController.swift
//  FindCVS
//
//  Created by 이주상 on 2023/04/25.
//

import UIKit
import CoreLocation
import SnapKit
import Combine

class MapViewController: UIViewController {
    private let viewModel = MapViewModel()
    private var subscriptions = Set<AnyCancellable>()
    private let locationManager = CLLocationManager()
    private lazy var searchBar = SearchBarView()
    private let mapView: MTMapView = {
        let mapView = MTMapView()
        mapView.setZoomLevel(0, animated: true)
        return mapView
    }()
    private lazy var cafeRediscoverButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "repeat"), for: .normal)
        button.tintColor = .brown
        button.setTitle("현 위치에서 검색", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12.0, weight: .bold)
        button.layer.borderColor = UIColor.brown.cgColor
        button.layer.borderWidth = 2.0
        button.setTitleColor(.brown, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20.0
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOpacity = 1.0
        button.layer.shadowOffset = CGSize.zero
        button.layer.shadowRadius = 6
        button.addTarget(self, action: #selector(didTappedCafeRediscoverButton), for: .touchUpInside)
        return button
    }()
    private lazy var currentLocationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.tintColor = .brown
        button.backgroundColor = .white
        button.layer.cornerRadius = 30.0
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOpacity = 1.0
        button.layer.shadowOffset = CGSize.zero
        button.layer.shadowRadius = 6
        button.addTarget(self, action: #selector(didTappedCurrentLocationButton), for: .touchUpInside)
        return button
    }()
    private var searchedCafe: Cafe? = nil
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    // searchViewController에서 검색한 카페를 지도 위에 표시하기 위한 생성자
    init(cafe: Cafe) {
        super.init(nibName: nil, bundle: nil)
        searchedCafe = cafe
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        setupLocation()
        setupViews()
        bind()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentSearchedCafe()
    }
}

extension MapViewController {
    private func setupDelegates() {
        mapView.delegate = self
        locationManager.delegate = self
        searchBar.delegate = self
    }
    private func setupLocation() {
        checkUserDeviceLocationServiceAuthorization()
    }
    private func setupNavigation() {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    private func setupViews() {
        [searchBar, mapView, cafeRediscoverButton, currentLocationButton].forEach {
            view.addSubview($0)
        }
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(16.0)
            $0.height.equalTo(40.0)
        }
        mapView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(16.0)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        cafeRediscoverButton.snp.makeConstraints {
            $0.top.equalTo(mapView.snp.top).offset(20.0)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(120.0)
            $0.height.equalTo(40.0)
        }
        currentLocationButton.snp.makeConstraints {
            $0.bottom.equalTo(mapView.snp.bottom).inset(40.0)
            $0.trailing.equalToSuperview().inset(40.0)
            $0.width.height.equalTo(60.0)
        }
    }
    private func bind() {
        viewModel.didTappedCurrentLocationButton
            .receive(on: RunLoop.main)
            .sink { [unowned self] _ in
                guard let currentPoint = viewModel.currentPoint.value else { return }
                self.mapView.setMapCenter(currentPoint, zoomLevel: 0, animated: true)
                let currentLocationitem = self.currentToMTMapPOIItem(currentPoint)
                self.mapView.addPOIItems([currentLocationitem])
            }.store(in: &subscriptions)
        
        viewModel.fetchedCafes
            .receive(on: RunLoop.main)
            .sink { [unowned self] result in
                if let result = result {
                    let items = result.map(cafeToMTMapPOIItem)
                    self.mapView.removeAllPOIItems()
                    self.mapView.addPOIItems(items)
                }
            }.store(in: &subscriptions)
    }
    // searchViewController에서 검색한 카페를 지도 위에 표시하기
    private func presentSearchedCafe() {
        guard let searchedCafe = searchedCafe, let latitude = Double(searchedCafe.y), let longitude = Double(searchedCafe.x) else { return }
        let mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude, longitude: longitude))
        mapView.setMapCenter(mapPoint, animated: true)
        presentDetailView(cafe: searchedCafe)
    }
    //MARK: - 위치 권한설정 관련
    private func checkUserDeviceLocationServiceAuthorization() {
        let authorizationStatus: CLAuthorizationStatus
        
        // 앱의 권한 상태 가져오는 코드 (iOS 버전에 따라 분기처리)
        if #available(iOS 14.0, *) {
            authorizationStatus = locationManager.authorizationStatus
        }else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        // 권한 상태값에 따라 분기처리를 수행하는 메서드 실행
        checkUserCurrentLocationAuthorization(authorizationStatus)
    }
    
    private func showRequestLocationServiceAlert() {
        let requestLocationServiceAlert = UIAlertController(title: "위치 정보 이용", message: "위치 서비스를 사용할 수 없습니다.\n디바이스의 '설정 > 개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)
        let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSetting)
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .default)
        requestLocationServiceAlert.addAction(cancel)
        requestLocationServiceAlert.addAction(goSetting)
        present(requestLocationServiceAlert, animated: true)
    }
    
    private func checkUserCurrentLocationAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // 사용자가 권한에 대한 설정을 선택하지 않은 상태
            // 권한 요청을 보내기 전에 desiredAccuracy 설정 필요
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            // 권한 요청을 보낸다.
            locationManager.requestWhenInUseAuthorization()
            
        case .denied, .restricted:
            // 사용자가 명시적으로 권한을 거부했거나, 위치 서비스 활성화가 제한된 상태
            // 시스템 설정에서 설정값을 변경하도록 유도한다.
            // 시스템 설정으로 유도하는 커스텀 얼럿
            showRequestLocationServiceAlert()

        case .authorizedWhenInUse:
            // 앱을 사용중일 때, 위치 서비스를 이용할 수 있는 상태
            // manager 인스턴스를 사용하여 사용자의 위치를 가져온다.
            locationManager.startUpdatingLocation()
        default:
            print("Default")
            break
        }
    }
    private func currentToMTMapPOIItem(_ currentPoint: MTMapPoint) -> MTMapPOIItem {
        let mapPOIItem = MTMapPOIItem()
        mapPOIItem.mapPoint = currentPoint
        mapPOIItem.markerType = .redPin
        mapPOIItem.showAnimationType = .springFromGround
        return mapPOIItem
    }
    private func cafeToMTMapPOIItem(_ cafe: Cafe) -> MTMapPOIItem {
        let longitude = Double(cafe.x) ?? .zero
        let latitude = Double(cafe.y) ?? .zero
        let point = MTMapPoint(geoCoord: MTMapPointGeo(latitude: latitude, longitude: longitude))
        let mapPOIItem = MTMapPOIItem()
        mapPOIItem.mapPoint = point
        mapPOIItem.markerType = .customImage
        mapPOIItem.markerSelectedType = .customImage
        mapPOIItem.customImageName = "cafe_marker.png"
        mapPOIItem.customSelectedImageName = "selected_cafe_marker.png"
        mapPOIItem.showAnimationType = .springFromGround
        mapPOIItem.tag = Int(cafe.id)!
        return mapPOIItem
    }
    // 카페 마커찍기
    private func addMarkers(_ mapPoint: MTMapPoint) {
        viewModel.fetchCafes(mapPoint: mapPoint)
    }
    private func presentDetailView(cafe: Cafe) {
        let detailViewController = DetailViewController(cafe: cafe)
        detailViewController.delegate = self
        if #available(iOS 15.0, *) {
            detailViewController.modalPresentationStyle = .pageSheet
            if let sheet = detailViewController.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
        } else {
            detailViewController.modalPresentationStyle = .fullScreen
        }
        present(detailViewController, animated: true)
    }
    private func presentDetailView(tag: Int) {
        guard let fetchedCafes = viewModel.fetchedCafes.value else { return }
        let selectedCafe = fetchedCafes.first { $0.id == String(tag) }
        
        if let selectedCafe = selectedCafe {
            let detailViewController = DetailViewController(cafe: selectedCafe)
            detailViewController.delegate = self
            if #available(iOS 15.0, *) {
                detailViewController.modalPresentationStyle = .pageSheet
                if let sheet = detailViewController.sheetPresentationController {
                    sheet.detents = [.medium()]
                    sheet.prefersGrabberVisible = true
                }
            } else {
                detailViewController.modalPresentationStyle = .fullScreen
            }
            present(detailViewController, animated: true)
        } else {
            errMessageAlert(message: "카페정보가 존재하지 않습니다.")
        }
    }
    @objc private func didTappedCafeRediscoverButton() {
        viewModel.fetchCafes(mapPoint: mapView.mapCenterPoint)
    }
    @objc private func didTappedCurrentLocationButton() {
        viewModel.didTappedCurrentLocationButton.send()
    }
}

extension MapViewController: CLLocationManagerDelegate {
    // 사용자의 위치를 성공적으로 가져왔을 때 호출
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//         위치 정보를 배열로 입력받는데, 마지막 index값이 가장 정확하다고 한다. ⭐️ 사용자 위치 정보 사용
                if let coordinate = locations.last?.coordinate {
                    let currentPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: coordinate.latitude, longitude: coordinate.longitude))!
                    let currentLocationitem = currentToMTMapPOIItem(currentPoint)
                    mapView.addPOIItems([currentLocationitem])
                    mapView.setMapCenter(currentPoint, zoomLevel: 0, animated: true)
                    // 사용자 위치 정보 -> Subject에 저장
                    viewModel.currentPoint.send(currentPoint)
                    // 사용자 위치 정보 -> UserDefaults에 저장
                    let latLong = LatLong(lat: coordinate.latitude, long: coordinate.longitude)
                    UserDefaultsManager.setCurrentLatLong(latLong: latLong)
                }
        // startUpdatingLocation()을 사용하여 사용자 위치를 가져왔다면
        // 불필요한 업데이트를 방지하기 위해 stopUpdatingLocation을 호출
        locationManager.stopUpdatingLocation()
    }
    // 사용자가 GPS 사용이 불가한 지역에 있는 등 위치 정보를 가져오지 못했을 때 호출
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errMessageAlert(message: "위치정보를 얻는데 실패하였습니다.")
    }
    // 앱에 대한 권한 설정이 변경되면 호출 (iOS 14 이상)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // 사용자 디바이스의 위치 서비스가 활성화 상태인지 확인하는 메서드 호출
        checkUserDeviceLocationServiceAuthorization()
    }
    
    // 앱에 대한 권한 설정이 변경되면 호출 (iOS 14 미만)
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 사용자 디바이스의 위치 서비스가 활성화 상태인지 확인하는 메서드 호출
        checkUserDeviceLocationServiceAuthorization()
    }
}

extension MapViewController: MTMapViewDelegate {
    // 지도 화면의 이동이 끝난 뒤 호출
    func mapView(_ mapView: MTMapView!, finishedMapMoveAnimation mapCenterPoint: MTMapPoint!) {
        addMarkers(mapCenterPoint)
    }
    // 마커를 터치하면 호출
    func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
        mapView.setMapCenter(poiItem.mapPoint, animated: true)
        presentDetailView(tag: poiItem.tag)
        return false
    }
    // 현위치 얻는것을 실패할때 호출
    func mapView(_ mapView: MTMapView!, failedUpdatingCurrentLocationWithError error: Error!) {
        errMessageAlert(message: "위치정보를 얻는데 실패하였습니다.")
    }
}

extension MapViewController: DetailViewControllerDelegate {
    func pushToWebView(urlString: String) {
        dismiss(animated: true)
        // 웹뷰에서는 뒤로가기 버튼이 있는 네비게이션바를 다시 보이게 하기 위함.
        navigationController?.setNavigationBarHidden(false, animated: true)
        let webViewController = WebViewController(urlString: urlString)
        navigationController?.pushViewController(webViewController, animated: true)
    }
}

extension MapViewController: SearchBarViewDelegate {
    func didTapSearchBarView() {
        let searchViewController = SearchViewController()
        navigationController?.pushViewController(searchViewController, animated: true)
    }
}
