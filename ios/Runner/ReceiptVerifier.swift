import Foundation
import StoreKit

@objc class ReceiptVerifier: NSObject {
    static let shared = ReceiptVerifier()
    private let sharedSecret = "cb836816822c4224af1a30ccccb930ff" // Thay bằng shared secret thực tế

    @objc func verifyReceipt(completion: @escaping (String) -> Void) {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptURL) else {
            completion("{\"status\":-1,\"message\":\"No receipt found\"}")
            return
        }
        let receiptString = receiptData.base64EncodedString(options: [])
        let requestContents: [String: Any] = [
            "receipt-data": receiptString,
            "password": sharedSecret,
            "exclude-old-transactions": true
        ]
        guard let requestData = try? JSONSerialization.data(withJSONObject: requestContents, options: []) else {
            completion("{\"status\":-2,\"message\":\"Invalid request\"}")
            return
        }
        let url = URL(string: "https://buy.itunes.apple.com/verifyReceipt")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = requestData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                completion("{\"status\":-3,\"message\":\"No response\"}")
                return
            }
            // Nếu status == 21007 thì chuyển sang sandbox
            if let status = json["status"] as? Int, status == 21007 {
                self.verifyReceiptSandbox(receiptString: receiptString, completion: completion)
                return
            }
            if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                completion(jsonString)
            } else {
                completion("{\"status\":-4,\"message\":\"Invalid JSON\"}")
            }
        }
        task.resume()
    }

    private func verifyReceiptSandbox(receiptString: String, completion: @escaping (String) -> Void) {
        let requestContents: [String: Any] = [
            "receipt-data": receiptString,
            "password": sharedSecret,
            "exclude-old-transactions": true
        ]
        guard let requestData = try? JSONSerialization.data(withJSONObject: requestContents, options: []) else {
            completion("{\"status\":-2,\"message\":\"Invalid request\"}")
            return
        }
        let url = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = requestData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                completion("{\"status\":-3,\"message\":\"No response\"}")
                return
            }
            if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                completion(jsonString)
            } else {
                completion("{\"status\":-4,\"message\":\"Invalid JSON\"}")
            }
        }
        task.resume()
    }
}
