
// MARK: - =================== STARTER CODE ===================

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================

// Level 1
func parseReading(_ raw: String) -> Reading? {
    guard let parts = splitOnce(raw, by: ":"),
          !parts.0.isEmpty,
          let number = Int(parts.1),
          number >= 0 || parts.0 == "TEMP" else { return nil }
    return (sensor: parts.0, value: number)
}

func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    for line in lines {
        if let reading = parseReading(line) { valid.append(reading) }
        else { invalidCount += 1 }
    }
    return (valid, invalidCount)
}
print("parseReading tests:", parseReading("O2:87") as Any, parseReading("RAD:-1") as Any)
print("parseLog tests:", parseLog(["O2:20", "bad"]).invalidCount, parseLog(["TEMP:-2", "O2:3"]).valid.count)
let parsed = parseLog(rawLog)
let A = parsed.invalidCount

// Level 2
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) { result.append(reading) }
    }
    return result
}
func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings { result.append(reading.value) }
    return result
}
let o2 = select(parsed.valid) { $0.sensor == "O2" }
print("select tests:", select(parsed.valid) { $0.sensor == "RAD" }.count, o2.count)
print("values tests:", values(of: o2), values(of: []))

func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }
    var low = first
    var high = first
    var sum = 0
    for number in values {
        if number < low { low = number }
        if number > high { high = number }
        sum += number
    }
    return (low, high, Double(sum) / Double(values.count))
}
func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}
print("stats array tests:", stats(of: [4, 8, 2]) as Any, stats(of: []) as Any)
print("stats variadic tests:", stats(3, 8, 1) as Any, stats() as Any)
let B = Int(stats(of: values(of: o2))?.average ?? 0)

// Closure ladder: five equivalent ways to sort
let sorted1 = parsed.valid.sorted(by: { (a: Reading, b: Reading) -> Bool in return a.value > b.value })
let sorted2 = parsed.valid.sorted(by: { a, b in return a.value > b.value })
let sorted3 = parsed.valid.sorted(by: { a, b in a.value > b.value })
let sorted4 = parsed.valid.sorted(by: { $0.value > $1.value })
let sorted5 = parsed.valid.sorted { $0.value > $1.value }
// Comparing the values verifies that the sort order is the same.
let sameSorts = values(of: sorted1) == values(of: sorted2) &&
    values(of: sorted2) == values(of: sorted3) &&
    values(of: sorted3) == values(of: sorted4) &&
    values(of: sorted4) == values(of: sorted5)
print("All five sorts match:", sameSorts)
print("Sort test 2 (first and last):", sorted5.first as Any, sorted5.last as Any)

// Level 3
func heatUp(_ t: Int) -> Int { t + 5 }
func coolDown(_ t: Int) -> Int { t - 3 }
func hold(_ t: Int) -> Int { t }
func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 { return heatUp }
    if temp > 24 { return coolDown }
    return hold
}
print("heatUp tests:", heatUp(10), heatUp(20))
print("coolDown tests:", coolDown(30), coolDown(20))
print("hold tests:", hold(20), hold(10))
print("chooseProtocol tests:", chooseProtocol(for: 10)(10), chooseProtocol(for: 30)(30))

func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temp = start
    var steps = 0
    while (temp < 18 || temp > 24) && steps < maxSteps {
        temp = chooseProtocol(for: temp)(temp)
        steps += 1
    }
    return (temp, steps, temp >= 18 && temp <= 24)
}
print("stabilization tests:", runUntilStable(from: 31), runUntilStable(from: -100, maxSteps: 5))
let temperatures = select(parsed.valid) { $0.sensor == "TEMP" }
let lowestTemp = stats(of: values(of: temperatures))?.min ?? 0
let C = runUntilStable(from: lowestTemp).steps

// Level 4
func oxygenLevel(of member: CrewMember) -> Int? { member.module?.oxygenTank?.level }
func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data (\(member.module?.name ?? "open space"))"
    }
    return "\(member.name): \(level)% \(level < 20 ? "CRITICAL" : "OK")"
}
print("oxygenLevel tests:", oxygenLevel(of: crew[0]) as Any, oxygenLevel(of: crew[1]) as Any)
print("status tests:", status(of: crew[0]), status(of: crew[1]))
for member in crew { print(status(of: member)) }

@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    if amount <= 0 { return 0 }
    let moved = min(amount, source, max(0, 100 - target))
    source -= moved
    target += moved
    return moved
}
var testSource = 30
var testTarget = 90
print("transfer test 1:", transferOxygen(from: &testSource, to: &testTarget, amount: 20), testSource, testTarget)
print("transfer test 2:", transferOxygen(from: &testSource, to: &testTarget, amount: -2), testSource, testTarget)
if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    let moved = transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
    print("Transferred:", moved)
}
let D = hab.oxygenTank?.level ?? 0

func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }
    let ordered = found.sorted { $0.priority < $1.priority }
    var result: [String] = []
    for member in ordered { result.append(member.name) }
    return result
}
print("evacuation tests:", evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))
print(evacuationOrder("Nurlan", "Timur", roster: roster))

// Level 5: The original broken code stays in the starter file above.
// reportOxygen: member.module can be nil (Nurlan), causing a crash.
// reportOxygen: oxygenTank can be nil (Dana), also causing a crash.
// firstCritical: oxygenLevel can be nil, causing a crash for Dana/Nurlan.
// firstCritical: result can stay nil when nobody is critical, causing a crash.
// firstCritical: overwriting result finds the LAST critical person, not the FIRST.
func reportOxygen(for member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no oxygen data"
    }
    return "\(member.name): \(level)%"
}
func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}
print("reportOxygen tests:", reportOxygen(for: crew[0]), reportOxygen(for: crew[1]))
print("firstCritical tests:", firstCritical(in: crew) as Any, firstCritical(in: []) as Any)
let firstRoom = Module(name: "A", oxygenTank: Tank(level: 5))
let secondRoom = Module(name: "B", oxygenTank: Tank(level: 10))
let firstPerson = CrewMember(name: "First", role: "Test", priority: 1, module: firstRoom)
let secondPerson = CrewMember(name: "Second", role: "Test", priority: 2, module: secondRoom)
print("First critical (must be First):", firstCritical(in: [firstPerson, secondPerson]) as Any)

// Finale
let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")

// Bonus: a closure remembers its own counter
func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var count = 0
    return { level in
        if level < threshold {
            count += 1
            print("Alarm #\(count)")
            return true
        }
        return false
    }
}
let alarm = makeAlarm(threshold: 20)
print("alarm tests:", alarm(12), alarm(40), alarm(5))

/*
 DEFENSE QUESTIONS
 1. guard let makes us exit early when data is missing. With if let, a long
    function can become deeply nested. For example, checking a module and
    then a tank with nested if let is harder to read than guard let.
 2. stats(1, 2, 3) takes separate Int arguments. An [Int] is one array,
    so we must use stats(of: someArray) instead.
 3. inout needs exclusive access to a variable while changing it. Passing
    &x twice would make two mutable accesses overlap, which is unsafe.
 4. oxygenLevel returns Int?, but "no data" is a String. Both sides of ??
    must produce compatible types. Use oxygenLevel(of: dana)?.description
    ?? "no data" if a string is needed.
 5. chooseProtocol has type (Int) -> ((Int) -> Int). It takes a temperature
    and returns another function that takes an Int and returns an Int.
 Bonus: count is captured by the returned closure. Swift keeps the captured
    variable alive as long as the closure needs it, even after makeAlarm ends.
*/
