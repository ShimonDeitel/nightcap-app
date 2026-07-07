import XCTest
@testable import Nightcap

@MainActor
final class NightcapTests: XCTestCase {
    var store: Store!

    override func setUp() async throws {
        store = Store()
    }

    func testSeedDataLoadedOnFreshInstall() throws {
        XCTAssertFalse(store.entries.isEmpty)
    }

    func testSeedCountIsBelowFreeLimit() throws {
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func testAddEntryIncreasesCount() throws {
        let before = store.entries.count
        let added = store.add(name: "Test Entry", f1: "a", f2: "b", f3: "c")
        XCTAssertTrue(added)
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testAddEntryRespectsFreeLimit() throws {
        for i in 0..<(Store.freeLimit + 5) {
            _ = store.add(name: "Entry \(i)", f1: "a", f2: "b", f3: "c")
        }
        XCTAssertEqual(store.entries.count, Store.freeLimit)
    }

    func testCanAddMoreWhenUnderLimit() throws {
        store.entries = []
        XCTAssertTrue(store.canAddMore)
    }

    func testCanAddMoreFalseAtLimit() throws {
        store.entries = []
        for i in 0..<Store.freeLimit {
            _ = store.add(name: "Entry \(i)", f1: "a", f2: "b", f3: "c")
        }
        XCTAssertFalse(store.canAddMore)
    }

    func testDeleteEntryRemovesIt() throws {
        let before = store.entries.count
        guard let first = store.entries.first else { return XCTFail("no entries") }
        store.delete(first)
        XCTAssertEqual(store.entries.count, before - 1)
        XCTAssertFalse(store.entries.contains(where: { $0.id == first.id }))
    }

    func testProUnlocksUnlimitedAdds() throws {
        store.isPro = true
        store.entries = []
        for i in 0..<(Store.freeLimit + 10) {
            _ = store.add(name: "Entry \(i)", f1: "a", f2: "b", f3: "c")
        }
        XCTAssertEqual(store.entries.count, Store.freeLimit + 10)
    }
}
