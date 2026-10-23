// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================

// MARK: Level 1 - The Power Cell
// A class lets drones share the same PowerCell object when needed.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = max(0, min(100, charge))
    }

    func level() -> Int { return charge }

    func spend(_ amount: Int) -> Bool {
        if amount <= 0 || amount > charge { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        if amount <= 0 { return }
        charge = min(100, charge + amount)
    }
}

let testCell = PowerCell(charge: 120)
print("PowerCell test:", testCell.level(), testCell.spend(25), testCell.level())
// testCell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level

// MARK: Level 2 - The Fleet
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { return 10 }
    var statusLine: String { return "\(id): \(cell.level())% \(cell.level().powerBar)" }
    func performTask() -> Int { return 0 }

    // final stops subclasses from skipping the power check.
    final func runOnce() -> Int {
        if !cell.spend(powerCost) { return 0 }
        return performTask()
    }
}

final class WelderDrone: Drone {
    override var powerCost: Int { return 25 }
    override func performTask() -> Int { return 40 }
    func weldSeam() -> String { return "\(id) welded a seam" }
}

class ScannerDrone: Drone {
    override var powerCost: Int { return 10 }
    override func performTask() -> Int { return 15 }
    override var statusLine: String { return super.statusLine + " [scanner]" }
}

final class CargoDrone: Drone {
    override var powerCost: Int { return 20 }
    override func performTask() -> Int { return 25 }
}

func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder": return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo": return CargoDrone(id: id, cell: cell)
    default: return nil
    }
}

var fleet: [Drone] = []
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("Skipping unknown drone:", record.kind, record.id)
    }
}

// MARK: Level 3 - The Shift
func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    if rounds <= 0 { return 0 }
    for _ in 1...rounds {
        for drone in fleet { total += drone.runOnce() }
    }
    return total
}

let A = runShift(fleet, rounds: 3)
var B = 0
var C = 0
for drone in fleet {
    print(drone.statusLine)
    B += drone.cell.level()
    if drone.cell.level() >= drone.powerCost { C += 1 }
}
print("Shift total:", A, "remaining charge:", B, "ready drones:", C)

// MARK: Level 4 - Diagnostics
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// The shared thresholds appear only here.
extension Diagnosable {
    func healthCode(for charge: Int) -> Int {
        if charge < 20 { return 2 }
        if charge < 50 { return 1 }
        return 0
    }

    func diagnose() -> String { return "\(componentID): code \(statusCode)" }
}

extension Drone: Diagnosable, Rechargeable {
    var componentID: String { return id }
    var statusCode: Int { return healthCode(for: cell.level()) }
    // A class is a reference type; changing its stored object does not require mutating.
    func recharge(by amount: Int) { cell.recharge(by: amount) }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int
    var componentID: String { return id }
    var statusCode: Int { return healthCode(for: chargeLevel) }
    mutating func recharge(by amount: Int) {
        if amount > 0 { chargeLevel = min(100, chargeLevel + amount) }
    }
}

func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var lines = ""
    for component in components { lines += component.diagnose() + "\n" }
    return lines
}

var sensors: [SensorModule] = []
for data in sensorData { sensors.append(SensorModule(id: data.id, chargeLevel: data.charge)) }

// [Drone] cannot store SensorModule because a struct is not a Drone subclass.
var components: [Diagnosable] = []
for drone in fleet { components.append(drone) }
for sensor in sensors { components.append(sensor) }
print("Diagnostics before beacon:\n" + diagnosticsReport(components))

// MARK: Level 5 - Shared Behaviour
extension LegacyBeacon: Diagnosable {
    var componentID: String { return name }
    var statusCode: Int { return healthCode(for: signalStrength) }
    func diagnose() -> String { return "LEGACY BEACON \(componentID): code \(statusCode)" }
}

extension Int {
    var powerBar: String {
        let bars = Swift.max(0, Swift.min(10, self / 10))
        return String(repeating: "#", count: bars) + String(repeating: ".", count: 10 - bars)
    }
}

components.append(beacon)
print("Diagnostics with beacon:\n" + diagnosticsReport(components))
var D = 0
for component in components { D += component.statusCode }
print("Power bar tests:", 42.powerBar, (-5).powerBar, 250.powerBar)

// MARK: Level 6 - Incident Reports
/*
Report 1: The author expects 30 work units from PatchDrone. It will not compile
because performTask() overrides a superclass method but is missing override.
Fix: override func performTask() -> Int { return 30 }

Report 2: The author expects HeavyWelder to bypass the shift and return 999.
It will not compile: WelderDrone is final and runOnce() is final.
Fix: create a different Drone subclass and override performTask(), not runOnce().

Report 3: The author expects weldSeam() to work on first. It will not compile
because first has static type Drone, which has no weldSeam() method.
Fix: conditionally cast to WelderDrone. as? returns an optional because
not every Drone is a WelderDrone.

Report 4: The author expects "thruster T-1" but gets "generic component".
label() is only in the protocol extension, not a protocol requirement, so
calling it through Labelled uses the extension implementation.
Fix: add func label() -> String to the Labelled protocol declaration.
*/
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
if let welder = first as? WelderDrone { print("Report 3 fixed:", welder.weldSeam()) }

protocol Labelled {
    var componentID: String { get }
    func label() -> String
}
extension Labelled {
    func label() -> String { return "generic component" }
}
struct Thruster: Labelled {
    let componentID: String
    func label() -> String { return "thruster \(componentID)" }
}
let parts: [Labelled] = [Thruster(componentID: "T-1")]
print("Report 4 fixed:", parts[0].label())

// MARK: Finale - Mission Code
let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")

// MARK: Defense Questions
/*
1. A class is a reference type, so its methods can change shared state without
   mutating. A struct is a value type, so a method changing its properties
   must be marked mutating.
2. A base class can inherit stored properties and initializers. A protocol
   can be adopted by both classes and structs, unlike class inheritance.
3. final prevents overriding a method or subclassing a final class.
   On runOnce(), it protects the rule that a drone must spend power first.
4. In Report 4, label() was not a protocol requirement. Calls through a
   Labelled value therefore used the protocol extension's implementation.
   Adding label() to the protocol enables the Thruster implementation.
*/

// MARK: Bonus (discussion)
/*
Runtime restriction: a base Drone initializer could trap if type(of: self)
were exactly Drone.self. Compile-time approach: hide the concrete base class
and expose a protocol plus only concrete implementations to clients.
A protocol-based fleet could use structs for drones and a protocol extension
for shared operations. I'd keep classes here because the station models
individual drones with shared PowerCell references. With mutable shared state,
reference types make identity and shared changes easier to represent.
*/
