


// MARK: 記得詢問權限
/// info.plist -> Privacy - Camera Usage Description

import UIKit
import AVFoundation

class ScanViewController: UIViewController {
    
    // 預覽時管理擷取影像的物件
    private var captureSession: AVCaptureSession!
    // 預覽畫面
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    // 偵測到QR code時需要加框
    private var qrCodeFrameView: UIView!
    // 支援的掃描類別
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.qr]
    
    // 建立QR code掃描框
    private func createQRFrame() {
        qrCodeFrameView = UIView()
        qrCodeFrameView.layer.borderColor = UIColor.yellow.cgColor
        qrCodeFrameView.layer.borderWidth = 3
        view.addSubview(qrCodeFrameView)
        view.bringSubviewToFront(qrCodeFrameView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = .clear
        
        view.backgroundColor = .clear
        
        startPreViewAndScan()
    }
    
    private func startPreViewAndScan(){
        
        captureSession = AVCaptureSession()
        
        // 設置照相機，記得設定info.plist
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device!")
            return
        }
        
        // init 輸入物件
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        if captureSession.canAddInput(input) {
            // 設定擷取期間的輸入
            captureSession.addInput(input)
        } else {
            failedAlert()
            return
        }
        
        // init & set output device
        let captureMetadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(captureMetadataOutput) {
            // add device
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // 欲處理的類型為QR code -> [.qr] or other
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
        } else {
            failedAlert()
            return
        }
        
        // 建立擷取期間所需顯示的預覽圖層
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture
        captureSession.startRunning()
        
        // Move the message label and top bar to the front
//        view.bringSubviewToFront(<#T##view: UIView##UIView#>)
        
        createQRFrame()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}
extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    

    // 取得資料
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // 判斷是否有讀到東西
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        // 將取得的資訊轉成條碼資訊
        let metadataObject = metadataObjects.first as! AVMetadataMachineReadableCodeObject
        
        // 是否有找到數據
        if supportedCodeTypes.contains(metadataObject.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject)
            
            // 成功解析就將QR code圖片框起來
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            // qrCode 資訊
            guard let qrString = metadataObject.stringValue else { return }
            
            successAlert(qrString: qrString)
            captureSession.stopRunning()
        }
        
    }
    
    private func failedAlert() {
        let alert = UIAlertController(title: "Scanning not supported", message: "Please use a device with a camera.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func successAlert(qrString: String) {
        let alert = UIAlertController(title: "QRCode info: \(qrString)", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            // 存值
            UserDefaults.standard.set(qrString, forKey: UserKeys.scanStr.rawValue)
            
            // 返回上一頁
            self.navigationController?.popViewController(animated: false)
//            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.qrCodeFrameView.frame = CGRect.zero
            self.startPreViewAndScan()
        }))
        
        present(alert, animated: true)
    }
}
