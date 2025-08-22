import Foundation
import AVFoundation
import Photos

class VideoMetadataService {
    static let shared = VideoMetadataService()
    
    private init() {}
    
    /// Extracts the original creation date from a video file
    func getVideoCreationDate(from url: URL) -> Date {
        let asset = AVAsset(url: url)
        
        // Try to get creation date from metadata
        for format in asset.availableMetadataFormats {
            let metadata = asset.metadata(forFormat: format)
            for item in metadata {
                if item.commonKey?.rawValue == "creationDate" {
                    if let dateString = item.stringValue {
                        // Parse ISO 8601 date format
                        let formatter = ISO8601DateFormatter()
                        if let date = formatter.date(from: dateString) {
                            return date
                        }
                    } else if let date = item.dateValue {
                        return date
                    }
                }
            }
        }
        
        // Fallback to file creation date
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let creationDate = attributes[.creationDate] as? Date {
                return creationDate
            }
        } catch {
            print("Error getting file attributes: \(error)")
        }
        
        // Last resort: current date
        return Date()
    }
    
    /// Gets creation date from PHAsset (for photos library videos)
    func getVideoCreationDate(from asset: PHAsset) -> Date {
        return asset.creationDate ?? Date()
    }
    
    /// Extracts video duration
    func getVideoDuration(from url: URL) -> TimeInterval {
        let asset = AVAsset(url: url)
        return asset.duration.seconds
    }
    
    /// Gets video dimensions
    func getVideoDimensions(from url: URL) -> CGSize {
        let asset = AVAsset(url: url)
        guard let track = asset.tracks(withMediaType: .video).first else {
            return .zero
        }
        return track.naturalSize
    }
}