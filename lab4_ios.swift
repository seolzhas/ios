// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================

// MARK: Level 1 - Deck Register

enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab: return 3
        case .engine: return 4
        case .cargo: return 5
        }
    }
}

for deck in Deck.allCases {
    print("Deck: \(deck.rawValue), priority: \(deck.evacuationPriority)")
}

enum AlarmLevel: Int {
    case green = 0, yellow, orange, red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let step = max(0, min(3, mass / 500))
        return AlarmLevel(rawValue: step) ?? .green
    }
}
print("Alarm tests:", AlarmLevel.level(forTotalMass: 0), AlarmLevel.level(forTotalMass: 940))
print("Alarm large mass:", AlarmLevel.level(forTotalMass: 4000))

// MARK: Level 2 - Manifest

enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

func parseEntry(_ line: String) -> ManifestEntry {
    let pieces = fields(line)
    if pieces.count == 3 && pieces[0] == "crate" {
        if let id = Int(pieces[1]), let kg = Int(pieces[2]) {
            return .crate(id: id, massKg: kg)
        }
    }
    if pieces.count == 3 && pieces[0] == "container" {
        if let kg = Int(pieces[2]) {
            return .container(code: pieces[1], massKg: kg)
        }
    }
    if pieces.count == 4 && pieces[0] == "livestock" {
        if let count = Int(pieces[2]), let kg = Int(pieces[3]) {
            return .livestock(species: pieces[1], count: count, massPerUnitKg: kg)
        }
    }
    return .unknown(raw: line)
}

func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(let id, let massKg):
        _ = id
        return massKg
    case .container(let code, let massKg):
        _ = code
        return massKg
    case .livestock(let species, let count, let massPerUnitKg):
        _ = species
        return count * massPerUnitKg
    case .unknown(let raw):
        _ = raw
        return 0
    }
}
print("Manifest tests:", parseEntry("crate:101:120"), parseEntry("broken"))
print("Mass tests:", mass(of: parseEntry("crate:101:120")), mass(of: parseEntry("bad")))

var A = 0
var unknownCount = 0
for line in rawManifest {
    let entry = parseEntry(line)
    A += mass(of: entry)
    if case .unknown = entry {
        unknownCount += 1
    }
}
print("Total mass:", A, "unknown lines:", unknownCount)

// MARK: Level 3 - Crew Snapshots

struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        if amount > 0 {
            oxygen = max(0, oxygen - amount)
        }
    }
    mutating func move(to deck: Deck) {
        self.deck = deck
    }
    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }
    static func rookie(named name: String) -> CrewSnapshot {
        return CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

var crewRoster: [CrewSnapshot] = []
for item in crewData {
    if let deck = Deck(rawValue: item.deck) {
        crewRoster.append(CrewSnapshot(name: item.name, deck: deck, oxygen: item.oxygen))
    } else {
        print("Skipping invalid crew deck:", item.name)
    }
}
print("Crew roster size:", crewRoster.count)
var rookie = CrewSnapshot.rookie(named: "Test")
print("Rookie before:", rookie)
rookie.breathe(12)
rookie.move(to: .lab)
print("Rookie after breathing and moving:", rookie)
rookie.reviveInMedbay()
print("Rookie revived:", rookie)

var original = crewRoster[0]
print("Copy example before - original:", original.oxygen)
var copy = original
copy.breathe(10)
print("Copy example after - copy:", copy.oxygen, "original:", original.oxygen)

func breatheCopy(_ member: CrewSnapshot) -> CrewSnapshot {
    var changed = member
    changed.breathe(10)
    return changed
}
func breatheOriginal(_ member: inout CrewSnapshot) {
    member.breathe(10)
}
print("Plain parameter before:", original.oxygen)
let changedCopy = breatheCopy(original)
print("Plain parameter after - result:", changedCopy.oxygen, "original:", original.oxygen)
print("Inout before:", original.oxygen)
breatheOriginal(&original)
print("Inout after - original:", original.oxygen)

// MARK: Level 4 - Teleport Pod

final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    // Classes do not receive the same memberwise initializer as structs.
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        if occupant != nil || chargeLevel < 20 { return false }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let passenger = occupant else { return nil }
        guard chargeLevel >= 20 else { return nil }
        chargeLevel -= 20
        occupant = nil
        return passenger
    }

    deinit {
        print("Pod deinit:", id)
    }
}

let pod = TeleportPod(id: "P-1", chargeLevel: 100)
for name in ["Timur", "Dana", "Nurlan"] {
    if let member = crewRoster.first(where: { $0.name == name }) {
        print("Load", name, pod.load(member))
        print("Fired:", pod.fire()?.name ?? "none", "charge:", pod.chargeLevel)
    }
}
print("Empty fire:", pod.fire()?.name ?? "none", "charge:", pod.chargeLevel)
let C = pod.chargeLevel

let samePod = pod
print("Pod reference before:", pod.chargeLevel, samePod.chargeLevel)
samePod.chargeLevel = 35
print("Pod reference after:", pod.chargeLevel, samePod.chargeLevel)
var crewOne = CrewSnapshot.rookie(named: "Aigerim")
var crewTwo = crewOne
print("Crew values before:", crewOne.oxygen, crewTwo.oxygen)
crewTwo.oxygen = 25
print("Crew values after:", crewOne.oxygen, crewTwo.oxygen)
// Classes share references; structs make independent copies.

// MARK: Level 5 - Station Systems

final class Station {
    let callSign: String
    var oxygenByDeck: [Deck: Int]

    var hullIntegrity: Int {
        willSet { print("Hull changing from \(hullIntegrity) to \(newValue)") }
        didSet { hullIntegrity = max(0, min(100, hullIntegrity)) }
    }

    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        return "Station \(callSign): \(oxygenByDeck.count) decks, hull \(hullIntegrity)%"
    }()

    var totalOxygen: Int {
        var total = 0
        for value in oxygenByDeck.values { total += value }
        return total
    }

    var averageOxygen: Int {
        get {
            if oxygenByDeck.isEmpty { return 0 }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in oxygenByDeck.keys { oxygenByDeck[deck] = newValue }
        }
    }

    init(callSign: String, readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        self.hullIntegrity = 100
        self.oxygenByDeck = [:]
        for reading in readings {
            if let deck = Deck(rawValue: reading.deck) {
                oxygenByDeck[deck] = reading.oxygen
            } else {
                print("Skipping invalid deck:", reading.deck)
            }
        }
    }
}

let station = Station(callSign: "ALMA-7", readings: deckReadings)
let B = station.averageOxygen
print("Station total oxygen:", station.totalOxygen)
print("Station starting average:", B)
print("Diagnostics first:", station.fullDiagnostics)
print("Diagnostics second:", station.fullDiagnostics)
station.averageOxygen = 60
print("Average after setter:", station.averageOxygen)
station.hullIntegrity = 130
print("Hull after 130:", station.hullIntegrity)
station.hullIntegrity = -40
print("Hull after -40:", station.hullIntegrity)
station.hullIntegrity = 55
print("Hull after 55:", station.hullIntegrity)
// didSet does not recursively run when it assigns to the same property.

// MARK: Level 6 - Incident Reports

// Report 1: The author expected the roster to change. The loop edits copies
// because CrewSnapshot is a value type. Fix: edit by index.
var reportRoster = crewRoster
print("Report 1 before:", reportRoster[0].oxygen)
for index in reportRoster.indices { reportRoster[index].oxygen -= 10 }
print("Report 1 fixed after:", reportRoster[0].oxygen)

// Report 2: The author expected independent pods, but class assignments
// share a reference. Fix: create a separate pod.
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = TeleportPod(id: podA.id, chargeLevel: podA.chargeLevel)
print("Report 2 before:", podA.chargeLevel, podB.chargeLevel)
podB.chargeLevel = 0
print("Report 2 fixed after:", podA.chargeLevel, podB.chargeLevel)

// Report 3: A struct's nonmutating method cannot change its stored array.
// Fix: mark add as mutating.
struct Logbook {
    var entries: [String] = []
    mutating func add(_ entry: String) { entries.append(entry) }
}
var logbook = Logbook()
print("Report 3 before:", logbook.entries)
logbook.add("Crew checked")
print("Report 3 after:", logbook.entries)

// Report 4: let freezes the whole struct value, so changing oxygen fails.
// A let class reference cannot be reassigned, but its var properties can change.
var snapshot = CrewSnapshot.rookie(named: "Dana")
print("Report 4 snapshot before:", snapshot.oxygen)
snapshot.oxygen = 40
print("Report 4 snapshot after:", snapshot.oxygen)
let reportPod = TeleportPod(id: "B", chargeLevel: 50)
print("Report 4 pod before:", reportPod.chargeLevel)
reportPod.chargeLevel = 10
print("Report 4 pod after:", reportPod.chargeLevel)

// MARK: Level 7 - Sealing the Black Box

final class FlightRecorder {
    // private blocks access to the entries array outside this type.
    private var entries: [String] = []
    // private(set) blocks outsiders from changing the seal.
    private(set) var isSealed = false

    var count: Int { entries.count }
    var transcript: String { entries.joined(separator: "\n") }

    func add(_ entry: String) {
        if !isSealed { entries.append(entry) }
    }
    func seal() { isSealed = true }

    // fileprivate allows a free function in this file to read this helper.
    fileprivate func auditLine() -> String {
        return "Audit: \(entries.count) entries, sealed: \(isSealed)"
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    return recorder.auditLine() + "\n" + recorder.transcript
}

let recorder = FlightRecorder()
print("Recorder initial count:", recorder.count)
recorder.add("Engine inspected")
recorder.add("Teleporter checked")
print("Recorder before seal:\n" + auditTranscript(of: recorder))
recorder.seal()
recorder.add("This must be ignored")
print("Recorder after seal:\n" + auditTranscript(of: recorder))
// recorder.entries = []  // error: 'entries' is inaccessible due to 'private' protection level
// recorder.isSealed = false // error: setter is inaccessible

// MARK: Finale - Integrity Code
let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")

// MARK: Bonus - Reference lifetime and identity
func samePodReference(_ first: TeleportPod, _ second: TeleportPod) -> Bool {
    return first === second
}
let equalContentsPod = TeleportPod(id: pod.id, chargeLevel: pod.chargeLevel)
print("Same reference:", samePodReference(pod, samePod))
print("Equal contents, different references:", samePodReference(pod, equalContentsPod))
var keptPod: TeleportPod?
do {
    let temporary = TeleportPod(id: "BONUS", chargeLevel: 30)
    keptPod = temporary
    print("Inside do block:", temporary.id)
}
print("After do block: kept reference still exists")
keptPod = nil
print("After clearing kept reference: deinit has fired")

// MARK: - ================= DEFENSE QUESTIONS =================
/*
1. CrewSnapshot is a struct with stored properties, so Swift generates a
   memberwise initializer. Classes like TeleportPod need their own initializer.

2. mutating lets a struct method change its stored properties or replace self.
   Class methods can change var properties through a reference without mutating.

3. let on a struct prevents changing its stored properties. let on a class
   instance prevents changing which object the reference points to, but
   properties declared var on that object can still change.

4. A lazy property needs var because it gets its first value after init.
   It can change behavior: our fullDiagnostics does not print "Running full
   scan..." until somebody first reads it, and it only runs once.

5. private works for the entry array because only FlightRecorder uses it.
   fileprivate is needed for auditLine(), because the free function
   auditTranscript(of:) calls it from outside the type but in this file.

Bonus: The BONUS pod does not deinitialize when the do block ends because
keptPod still holds a reference. It deinitializes when keptPod becomes nil.
=== compares class object identity. CrewSnapshot is a struct, not a class
reference, so === cannot compare CrewSnapshot values.
*/
