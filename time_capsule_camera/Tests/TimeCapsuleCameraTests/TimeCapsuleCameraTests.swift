import XCTest
@testable import TimeCapsuleCamera

final class TimeCapsuleCameraTests: XCTestCase {
    
    func testCapsuleInitialization() {
        let sampleData: [String: Any] = [
            "name": "Test Capsule",
            "creatorId": "user123",
            "memberIds": ["user123", "user456"],
            "isUnsealed": false
        ]
        
        let capsule = Capsule(id: "capsule123", data: sampleData)
        
        XCTAssertEqual(capsule.id, "capsule123")
        XCTAssertEqual(capsule.name, "Test Capsule")
        XCTAssertEqual(capsule.creatorId, "user123")
        XCTAssertEqual(capsule.memberIds.count, 2)
    }
    
    func testClipInitialization() {
        let sampleData: [String: Any] = [
            "uploaderId": "user123",
            "uploaderName": "John Doe",
            "storagePath": "/videos/clip123.mp4"
        ]
        
        let clip = Clip(id: "clip123", data: sampleData)
        
        XCTAssertEqual(clip.id, "clip123")
        XCTAssertEqual(clip.uploaderId, "user123")
        XCTAssertEqual(clip.uploaderName, "John Doe")
        XCTAssertEqual(clip.storagePath, "/videos/clip123.mp4")
    }
}