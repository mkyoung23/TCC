import SwiftUI
import AVFoundation
import CoreLocation
import Photos

struct EnhancedCameraView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var firebase = FirebaseManager.shared
    @State private var isRecording = false
    @State private var recordingTime = 0
    @State private var timer: Timer?
    @State private var showingPermissionAlert = false
    @State private var permissionMessage = ""
    @State private var currentLocation = "Loading location..."

    let capsuleId: String
    let maxRecordingTime = 60

    // Camera session
    @StateObject private var cameraModel = CameraModel()

    var body: some View {
        ZStack {
            // Camera preview
            CameraPreview(session: cameraModel.session)
                .ignoresSafeArea()

            // Video overlay (always visible during recording)
            if isRecording {
                VideoOverlay(
                    userName: firebase.userName,
                    location: currentLocation,
                    recordingTime: recordingTime,
                    isRecording: isRecording
                )
            }

            VStack {
                // Top bar
                HStack {
                    Button(action: {
                        if isRecording {
                            stopRecording()
                        }
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding()

                    Spacer()
                }

                Spacer()

                // Bottom controls
                VStack(spacing: 20) {
                    // Time remaining
                    if isRecording {
                        Text("\(maxRecordingTime - recordingTime) seconds remaining")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(20)
                    }

                    // Record button
                    Button(action: {
                        if isRecording {
                            stopRecording()
                        } else {
                            startRecording()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 80, height: 80)

                            if isRecording {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red)
                                    .frame(width: 35, height: 35)
                            } else {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 70, height: 70)
                            }
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            cameraModel.checkPermissions()
            updateLocation()
        }
        .alert("Permission Required", isPresented: $showingPermissionAlert) {
            Button("Open Settings", role: .none) {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(permissionMessage)
        }
    }

    private func startRecording() {
        isRecording = true
        recordingTime = 0
        cameraModel.startRecording()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            recordingTime += 1
            if recordingTime >= maxRecordingTime {
                stopRecording()
            }
        }
    }

    private func stopRecording() {
        isRecording = false
        timer?.invalidate()
        timer = nil

        cameraModel.stopRecording { url in
            if let url = url {
                uploadVideo(url: url)
            }
        }
    }

    private func uploadVideo(url: URL) {
        Task {
            do {
                _ = try await firebase.uploadVideo(to: capsuleId, videoUrl: url)
                await MainActor.run {
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                print("Upload failed: \(error)")
            }
        }
    }

    private func updateLocation() {
        LocationManager.shared.requestLocation { location in
            if let location = location {
                // Get city, state from coordinates
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(location) { placemarks, error in
                    if let placemark = placemarks?.first {
                        let city = placemark.locality ?? ""
                        let state = placemark.administrativeArea ?? ""
                        currentLocation = "\(city), \(state)"
                    }
                }
            }
        }
    }
}

// Video overlay showing metadata
struct VideoOverlay: View {
    let userName: String
    let location: String
    let recordingTime: Int
    let isRecording: Bool

    var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: Date())
    }

    var formattedTime: String {
        let hours = recordingTime / 3600
        let minutes = (recordingTime % 3600) / 60
        let seconds = recordingTime % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    var body: some View {
        VStack {
            HStack {
                // Top left - User name
                Text(userName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(8)

                Spacer()

                // Top right - Recording indicator
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .opacity(isRecording ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).repeatForever())

                    Text("REC")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.red)
                }
                .padding(10)
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
            }
            .padding()

            Spacer()

            HStack {
                // Bottom left - Location
                HStack(spacing: 5) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 14))
                    Text(location)
                        .font(.system(size: 14))
                }
                .foregroundColor(.white)
                .padding(10)
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)

                Spacer()

                // Bottom right - Time and date
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formattedTime)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                    Text(currentDate)
                        .font(.system(size: 12))
                }
                .foregroundColor(.white)
                .padding(10)
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
            }
            .padding()
        }
    }
}

// Camera model for recording
class CameraModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var isAuthorized = false

    private var movieOutput = AVCaptureMovieFileOutput()
    private var currentVideoURL: URL?

    override init() {
        super.init()
        setupSession()
    }

    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                }
            }
        default:
            isAuthorized = false
        }
    }

    private func setupSession() {
        session.beginConfiguration()

        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoInput) else { return }

        session.addInput(videoInput)

        // Add audio input
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
              session.canAddInput(audioInput) else { return }

        session.addInput(audioInput)

        // Add movie output
        if session.canAddOutput(movieOutput) {
            session.addOutput(movieOutput)
        }

        session.commitConfiguration()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    func startRecording() {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mov")
        currentVideoURL = tempURL

        movieOutput.startRecording(to: tempURL, recordingDelegate: self)
    }

    func stopRecording(completion: @escaping (URL?) -> Void) {
        movieOutput.stopRecording()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            completion(self?.currentVideoURL)
        }
    }
}

extension CameraModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Recording error: \(error)")
        }
    }
}

// Camera preview
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

// Location manager
class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let manager = CLLocationManager()
    private var completion: ((CLLocation?) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
    }

    func requestLocation(completion: @escaping (CLLocation?) -> Void) {
        self.completion = completion
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        completion?(locations.first)
        completion = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion?(nil)
        completion = nil
    }
}