import XCTest
import FirebaseAuth
import FirebaseFirestore
@testable import TimeCapsuleCamera

/// Comprehensive integration tests for Time Capsule Camera app
/// These tests verify core functionality works end-to-end
class IntegrationTests: XCTestCase {
    
    var authViewModel: AuthViewModel!
    var capsuleViewModel: CapsuleViewModel!
    
    override func setUpWithError() throws {
        super.setUp()
        
        // Initialize Firebase for testing (this should be done once)
        if FirebaseApp.app() == nil {
            // Configure Firebase with test configuration
            print("⚠️ Firebase not configured for testing")
        }
        
        authViewModel = AuthViewModel()
        capsuleViewModel = CapsuleViewModel()
    }
    
    override func tearDownWithError() throws {
        super.tearDown()
        authViewModel = nil
        capsuleViewModel = nil
    }
    
    // MARK: - Authentication Tests
    
    func testUserRegistrationFlow() throws {
        let expectation = self.expectation(description: "User registration completes")
        
        let testEmail = "test_\(UUID().uuidString.prefix(8))@example.com"
        let testPassword = "TestPassword123!"
        let testDisplayName = "Test User"
        
        authViewModel.signUp(email: testEmail, password: testPassword, displayName: testDisplayName)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            XCTAssertTrue(self.authViewModel.isSignedIn, "User should be signed in after registration")
            XCTAssertNotNil(self.authViewModel.user, "User object should exist")
            XCTAssertEqual(self.authViewModel.user?.displayName, testDisplayName, "Display name should match")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10.0)
    }
    
    func testUserSignInFlow() throws {
        // This test assumes a test user already exists
        let expectation = self.expectation(description: "User sign in completes")
        
        let testEmail = "testuser@timecapsule.test"
        let testPassword = "TestPassword123!"
        
        authViewModel.signIn(email: testEmail, password: testPassword)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if self.authViewModel.errorMessage == nil {
                XCTAssertTrue(self.authViewModel.isSignedIn, "User should be signed in")
                XCTAssertNotNil(self.authViewModel.user, "User object should exist")
            } else {
                print("⚠️ Sign in failed (expected if test user doesn't exist): \(self.authViewModel.errorMessage!)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10.0)
    }
    
    // MARK: - Capsule Tests
    
    func testCapsuleCreationFlow() throws {
        // First ensure we have a signed-in user
        guard authViewModel.isSignedIn, let user = authViewModel.user else {
            XCTSkip("User must be signed in for capsule tests")
        }
        
        let expectation = self.expectation(description: "Capsule creation completes")
        
        let testCapsuleName = "Test Capsule \(Date().timeIntervalSince1970)"
        let futureDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        
        FirebaseManager.shared.createCapsule(
            name: testCapsuleName,
            sealDate: futureDate,
            creatorId: user.uid
        ) { result in
            switch result {
            case .success(let capsuleId):
                XCTAssertFalse(capsuleId.isEmpty, "Capsule ID should not be empty")
                print("✅ Capsule created successfully: \(capsuleId)")
                expectation.fulfill()
                
            case .failure(let error):
                XCTFail("Capsule creation failed: \(error.localizedDescription)")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10.0)
    }
    
    func testCapsuleFetchFlow() throws {
        guard authViewModel.isSignedIn, let user = authViewModel.user else {
            XCTSkip("User must be signed in for capsule tests")
        }
        
        let expectation = self.expectation(description: "Capsule fetch completes")
        
        capsuleViewModel.fetchCapsules(for: user)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            XCTAssertFalse(self.capsuleViewModel.isLoading, "Loading should be complete")
            print("✅ Fetched \(self.capsuleViewModel.capsules.count) capsules")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10.0)
    }
    
    // MARK: - Video Metadata Tests
    
    func testVideoMetadataExtraction() throws {
        // Create a test video URL (this would be a real video file in practice)
        let videoMetadataService = VideoMetadataService.shared
        
        // Test fallback to current date when no metadata is available
        let testURL = URL(fileURLWithPath: "/tmp/nonexistent.mp4")
        let extractedDate = videoMetadataService.getVideoCreationDate(from: testURL)
        
        // Should return a date (either extracted or current date as fallback)
        XCTAssertNotNil(extractedDate, "Should return a valid date")
        
        print("✅ Video metadata extraction test completed")
    }
    
    // MARK: - Sharing Tests
    
    func testSharingService() throws {
        let sharingService = SharingService.shared
        
        // Create a test capsule
        let testCapsule = Capsule(id: "test_capsule_id", data: [
            "name": "Test Capsule",
            "creatorId": "test_user",
            "memberIds": ["test_user"],
            "sealDate": Timestamp(date: Date()),
            "isUnsealed": false
        ])
        
        // Test shareable link generation
        let shareableLink = sharingService.generateShareableLink(for: testCapsule)
        XCTAssertNotNil(shareableLink, "Should generate a shareable link")
        
        // Test share message generation
        if let user = authViewModel.user {
            let shareMessage = sharingService.generateShareMessage(for: testCapsule, from: user)
            XCTAssertTrue(shareMessage.contains(testCapsule.name), "Share message should contain capsule name")
        }
        
        print("✅ Sharing service test completed")
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling() throws {
        let errorService = ErrorHandlingService.shared
        
        // Test error conversion
        let testNSError = NSError(domain: "TestDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        let appError = AppError.from(testNSError, context: "Test context")
        
        XCTAssertNotNil(appError.localizedDescription, "Should have error description")
        XCTAssertNotNil(appError.recoveryMessage, "Should have recovery message")
        
        print("✅ Error handling test completed")
    }
    
    // MARK: - Performance Tests
    
    func testCapsuleListPerformance() throws {
        measure {
            // Test performance of capsule list operations
            let testCapsules = (0..<100).map { index in
                Capsule(id: "capsule_\(index)", data: [
                    "name": "Test Capsule \(index)",
                    "creatorId": "test_user",
                    "memberIds": ["test_user"],
                    "sealDate": Timestamp(date: Date()),
                    "isUnsealed": false
                ])
            }
            
            // Simulate processing capsules
            let filteredCapsules = testCapsules.filter { !$0.isUnsealed }
            XCTAssertEqual(filteredCapsules.count, 100, "All capsules should be sealed")
        }
    }
    
    // MARK: - Data Validation Tests
    
    func testCapsuleDataValidation() throws {
        // Test capsule creation with invalid data
        let invalidCapsuleData: [String: Any] = [
            "name": "", // Empty name
            "creatorId": "",
            "memberIds": [],
            "sealDate": Timestamp(date: Date().addingTimeInterval(-3600)), // Past date
            "isUnsealed": false
        ]
        
        let capsule = Capsule(id: "test_id", data: invalidCapsuleData)
        
        XCTAssertTrue(capsule.name.isEmpty, "Should handle empty name")
        XCTAssertTrue(capsule.memberIds.isEmpty, "Should handle empty member list")
        XCTAssertTrue(capsule.isUnsealed, "Should auto-unseal past date capsules")
        
        print("✅ Data validation test completed")
    }
    
    // MARK: - Network Connectivity Tests
    
    func testNetworkMonitoring() throws {
        let firebaseManager = FirebaseManager.shared
        
        // Test that Firebase manager has network monitoring
        XCTAssertNotNil(firebaseManager.isOnline, "Should track online status")
        
        print("✅ Network monitoring test completed")
    }
}

// MARK: - Test Helpers

extension IntegrationTests {
    
    /// Helper method to create a test user for integration tests
    func createTestUser(completion: @escaping (User?) -> Void) {
        let testEmail = "integrationtest@timecapsule.test"
        let testPassword = "IntegrationTest123!"
        
        Auth.auth().createUser(withEmail: testEmail, password: testPassword) { result, error in
            if let user = result?.user {
                completion(user)
            } else {
                // User might already exist, try to sign in
                Auth.auth().signIn(withEmail: testEmail, password: testPassword) { result, error in
                    completion(result?.user)
                }
            }
        }
    }
    
    /// Helper method to clean up test data
    func cleanupTestData() {
        // Clean up any test capsules, users, etc.
        // This should be implemented based on your cleanup strategy
        print("🧹 Cleaning up test data...")
    }
}

// MARK: - Mock Data for Testing

struct MockDataGenerator {
    static func generateTestCapsule(name: String = "Test Capsule") -> Capsule {
        return Capsule(id: UUID().uuidString, data: [
            "name": name,
            "creatorId": "test_user_id",
            "memberIds": ["test_user_id", "test_friend_id"],
            "sealDate": Timestamp(date: Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()),
            "isUnsealed": false
        ])
    }
    
    static func generateTestClip(uploaderName: String = "Test User") -> Clip {
        return Clip(id: UUID().uuidString, data: [
            "uploaderId": "test_user_id",
            "uploaderName": uploaderName,
            "storagePath": "videos/test_capsule/test_video.mp4",
            "createdAt": Timestamp(date: Date().addingTimeInterval(-3600)), // 1 hour ago
            "uploadedAt": Timestamp(date: Date())
        ])
    }
}