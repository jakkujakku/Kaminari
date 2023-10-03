import CoreLocation
import MapKit
import SnapKit
import UIKit
import WeatherKit

class RegionViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    let customImage = UIImage(named: "Image")
    // 이미지 추가
    var weather: Weather?
    var locationManager = CLLocationManager()
    var mapView: MKMapView!
//    var count = 0
    lazy var myLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(UIImage(systemName: "location"), for: .normal)
        button.addTarget(self, action: #selector(centerMapOnUserLocation), for: .touchUpInside)
        return button
    }()

    deinit {
        print("### ViewController deinitialized")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        locationManager.delegate = self

        mapView = MKMapView()

        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        view.addSubview(mapView)

        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(myLocationButton)
        view.bringSubviewToFront(myLocationButton)

        current()
        addCustomPins() // 마커 추가하기
        fetchData(latitude: 37.577535, longitude: 126.9779692)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        let reuseIdentifier = "customPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

        guard let targetCity = WeatherManager.shared.getCity(latitude: annotation.coordinate.latitude,
                                                             longitude: annotation.coordinate.longitude)
        else {
            print("NO Result")
            return nil
        }

        if annotationView == nil {
            let currentWeather = WeatherManager.shared.weathers[targetCity]?.currentWeather
            let symbolName = currentWeather?.symbolName

            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.image = UIImage(systemName: symbolName ?? "sun.max")
            annotationView?.frame.size = CGSize(width: 20, height: 20)
        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }

    func setUserTrackingMode(mode: MKUserTrackingMode, animated: Bool) {
        // Your code to set the user tracking mode goes here
    }

    private func addCustomPins() {
//        let pinCoordinates: [CLLocationCoordinate2D] = [
//            CLLocationCoordinate2D(latitude: 37.577535, longitude: 126.9779692),
//            // 서울
//            CLLocationCoordinate2D(latitude: 37.4562557, longitude: 126.7052062),
//            // 인천
//            CLLocationCoordinate2D(latitude: 36.3504119, longitude: 127.3845475),
//            // 대전
//            CLLocationCoordinate2D(latitude: 35.1795543, longitude: 129.0756416),
//            // 부산
//            CLLocationCoordinate2D(latitude: 35.8714354, longitude: 128.601445),
//            // 대구
//            CLLocationCoordinate2D(latitude: 35.1595454, longitude: 126.8526012),
//            // 광주
//            CLLocationCoordinate2D(latitude: 35.5383773, longitude: 129.31133596)
//            // 울산
//        ]

        let pinCoordinates = City.allCases.map { $0.pinCoordinates }

        pinCoordinates.forEach { pin in

//            let manager = WeatherManager.shared.weather?.currentWeather

            let pinAnnotation = MKPointAnnotation()

            pinAnnotation.coordinate.latitude = pin.latitude
            pinAnnotation.coordinate.longitude = pin.longitude

//            print("위도: \(index.latitude), 경도: \(index.longitude)")

//            count += 1

//            pinAnnotation.title = manager?.temperature.description

            mapView.addAnnotation(pinAnnotation)
        }

//        print(count)
//        for (index, coordinate) in pinCoordinates.enumerated() {
//            // 좌표, 제목 활용 반복문 사용한다.
//            let pinAnnotation = MKPointAnnotation()
//            // 객체를 생성한다.
//            pinAnnotation.coordinate = coordinate
//            // 객체의 좌표를 현재 좌표로 설정한다.
//            pinAnnotation.title = WeatherManager.shared.weather?.currentWeather.temperature.description
//            // 객체의 제목을 현재 좌표의 인덱스로 설정한다.
//            mapView.addAnnotation(pinAnnotation)
//            // 맵뷰에 객체를 추가하여 보이게 한다.
//        }
    }

    func fetchData(latitude: Double, longitude: Double) {
        City.allCases.forEach { city in
            Task {
                let pinCoordinates = city.pinCoordinates
                await WeatherManager.loadData(city: city) {
                    let manager = WeatherManager.shared

//                    let currentWeather = WeatherManager.shared.weather?.currentWeather
//                    manager.weather?.currentWeather.date = currentWeather?.date ?? Date()
//                    manager.weather?.currentWeather.symbolName = currentWeather?.symbolName ?? "sun.max"
                    //                print(currentWeather as Any) // 필요하면 주석처리
                    //                print(currentWeather?.symbolName) // 필요하면 주석처리
                    //                print("###", manager.weather?.currentWeather.symbolName)
                    DispatchQueue.main.async {}
                }
            }
        }
    }

    func current() {
        myLocationButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(-50)
            make.bottom.equalToSuperview().inset(20)
        }

        mapView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
    }

    @objc func centerMapOnUserLocation() {
        // 사용자의 현재 위치로 지도를 이동하는 함수
        if let userLocation = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
}
