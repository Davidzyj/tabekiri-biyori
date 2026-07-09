import UIKit
import Vision

enum DateRecognitionError: Error {
    case unreadable
}

enum DateRecognitionService {
    static func recognizeDate(in image: UIImage) async throws -> Date {
        guard let cgImage = image.cgImage else { throw DateRecognitionError.unreadable }
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let text = (request.results as? [VNRecognizedTextObservation])?
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: " ") ?? ""
                if let date = firstDate(in: text) {
                    continuation.resume(returning: date)
                } else {
                    continuation.resume(throwing: DateRecognitionError.unreadable)
                }
            }
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["ja-JP", "en-US", "zh-Hans"]
            request.usesLanguageCorrection = false
            do {
                try VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private static func firstDate(in text: String) -> Date? {
        let normalized = text
            .replacingOccurrences(of: "年", with: "/")
            .replacingOccurrences(of: "月", with: "/")
            .replacingOccurrences(of: "日", with: "")
            .replacingOccurrences(of: ".", with: "/")
            .replacingOccurrences(of: "-", with: "/")
        let patterns = [
            #"\b(20\d{2})/(\d{1,2})/(\d{1,2})\b"#,
            #"\b(\d{2})/(\d{1,2})/(\d{1,2})\b"#
        ]
        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: normalized, range: NSRange(normalized.startIndex..., in: normalized)) else { continue }
            let parts = (1...3).compactMap { index -> Int? in
                guard let range = Range(match.range(at: index), in: normalized) else { return nil }
                return Int(normalized[range])
            }
            guard parts.count == 3 else { continue }
            let year = parts[0] < 100 ? 2000 + parts[0] : parts[0]
            if let date = Calendar.current.date(from: DateComponents(year: year, month: parts[1], day: parts[2])) {
                return date
            }
        }
        return nil
    }
}

