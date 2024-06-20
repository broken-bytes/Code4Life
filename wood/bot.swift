import Foundation

public struct StderrOutputStream: TextOutputStream {
    public mutating func write(_ string: String) { fputs(string, stderr) }
}

public var errStream = StderrOutputStream()

enum Module: String {
    case start = "START_POS"
    case diagnosis = "DIAGNOSIS"
    case molecules = "MOLECULES"
    case laboratory = "LABORATORY"
}

struct Molecule {
    enum Kind: String {
        case a = "A"
        case b = "B"
        case c = "C"
        case d = "D"
        case e = "E"
    }

    var kind: Kind
}

struct SampleData {
    enum Location: Int8 {
        case me = 0
        case other = 1
        case cloud = -1
    }

    var id: Int
    var location: Location
    var healthPoints: Int
    var costA: Int
    var costB: Int
    var costC: Int
    var costD: Int
    var costE: Int
}

struct Inventory {
    enum InventoryError: Error {
        case inventoryFull
        case inventoryEmpty
    }

    var molecules: [Int] = [0, 0, 0, 0, 0]
    var samples: [SampleData] = []

    mutating func set(a: Int, b: Int, c: Int, d: Int, e: Int) {
        errStream.write("\(a) \(b) \(c) \(d) \(e)\n")
        molecules[0] = a
        molecules[1] = b
        molecules[2] = c
        molecules[3] = d
        molecules[4] = e
    }

    subscript(kind: Molecule.Kind) -> Int? {
        get {
            switch kind {
                case .a: return molecules[0]
                case .b: return molecules[1]
                case .c: return molecules[2]
                case .d: return molecules[3]
                case .e: return molecules[4]
            }
        }
        set {
            switch kind {
                case .a: molecules[0] += 1
                case .b: molecules[1] += 1
                case .c: molecules[2] += 1
                case .d: molecules[3] += 1
                case .e: molecules[4] += 1
            }
        }
    }
}

class Bot {
    var position: Module = .diagnosis
    var health: Int = 0
    var inventory = Inventory()

    init(
        module: Module,
        health: Int,
        a: Int, 
        b: Int, 
        c: Int, 
        d: Int, 
        e: Int
    ) {
        self.position = module
        self.health = health
        inventory.set(a: a, b: b, c: c, d: d, e: e)
    }

    func update(samples: [SampleData]) {
        // Check if we already have a sample, else we need to check if we are already at the diagnosis.
        // We have a sample
        if let sample = samples.first(where: { $0.location == .me }) {
            // Check if we still need to gather molecules

            if canProcessSample(sample: sample) {
                processSample(sample: sample)
            } else {
                collectMolecules(for: sample)
            }
        } else {
            collectSample(samples: samples)
        }
    }

    private func processSample(sample: SampleData) {
        if position != .laboratory {
            move(to: .laboratory)
        } else {
            connect(value: sample.id)
        }
    }

    private func canProcessSample(sample: SampleData) -> Bool {
        inventory[Molecule.Kind.a]! >= sample.costA &&
        inventory[Molecule.Kind.b]! >= sample.costB &&
        inventory[Molecule.Kind.c]! >= sample.costC &&
        inventory[Molecule.Kind.d]! >= sample.costD &&
        inventory[Molecule.Kind.e]! >= sample.costE
    } 

    private func collectSample(samples: [SampleData]) {
        if let sample = samples.last(where: { $0.location == .cloud }) {
            if position != .diagnosis {
                move(to: .diagnosis)
            } else {
                connect(value: sample.id)
            }
        } else {
            print("PANIC")
            // Do nothing?
        }
    }

    private func collectMolecules(for sample: SampleData) {
        if position != .molecules {
            move(to: .molecules)
        } else {
            if inventory[Molecule.Kind.a]! < sample.costA {
                connect(value: Molecule.Kind.a.rawValue)
            } else if inventory[Molecule.Kind.b]! < sample.costB {
                connect(value: Molecule.Kind.b.rawValue)
            } else if inventory[Molecule.Kind.c]! < sample.costC {
                connect(value: Molecule.Kind.c.rawValue)
            } else if inventory[Molecule.Kind.d]! < sample.costD {
                connect(value: Molecule.Kind.d.rawValue)
            } else {
                connect(value: Molecule.Kind.e.rawValue)
            }
        }
    }

    private func takeMolecule(kind: Molecule.Kind) {
        inventory[kind]! += 1
        connect(value: kind.rawValue)
    }

    private func connect(value: Int) {
        connect(value: "\(value)")
    }

    private func connect(value: String) {
        print("CONNECT \(value)")
    }

    private func move(to module: Module) {
        position = module
        print("GOTO \(module.rawValue)")
    }
}

func update(
    target: Module, 
    health: Int,
    storageA: Int,
    storageB: Int,
    storageC: Int,
    storageD: Int,
    storageE: Int,
    samples: [SampleData]
) {
    var bot = Bot(module: target, health: health, a: storageA, b: storageB, c: storageC, d: storageD, e: storageE)

    bot.update(samples: samples)
}

let projectCount = Int(readLine()!)!

if projectCount > 0 {
    for i in 0...(projectCount-1) {
        let inputs = (readLine()!).split(separator: " ").map(String.init)
        let a = Int(inputs[0])!
        let b = Int(inputs[1])!
        let c = Int(inputs[2])!
        let d = Int(inputs[3])!
        let e = Int(inputs[4])!
    }
}

// game loop
while true {
    var target: Module = .diagnosis
    var health: Int = 0
    var storageA: Int = 0
    var storageB: Int = 0
    var storageC: Int = 0
    var storageD: Int = 0
    var storageE: Int = 0
    var samples: [SampleData] = []

    for i in 0...1 {
        let inputs = (readLine()!).split(separator: " ").map(String.init)
        
        if i == 0 {
            target = Module(rawValue: inputs[0])!

            let eta = Int(inputs[1])!
            health = Int(inputs[2])!
            storageA = Int(inputs[3])!
            storageB = Int(inputs[4])!
            storageC = Int(inputs[5])!
            storageD = Int(inputs[6])!
            storageE = Int(inputs[7])!

            let expertiseA = Int(inputs[8])!
            let expertiseB = Int(inputs[9])!
            let expertiseC = Int(inputs[10])!
            let expertiseD = Int(inputs[11])!
            let expertiseE = Int(inputs[12])!
        }
    }
    let inputs = (readLine()!).split(separator: " ").map(String.init)
    let availableA = Int(inputs[0])!
    let availableB = Int(inputs[1])!
    let availableC = Int(inputs[2])!
    let availableD = Int(inputs[3])!
    let availableE = Int(inputs[4])!
    let sampleCount = Int(readLine()!)!
    
    if sampleCount > 0 {
        for i in 0...(sampleCount-1) {
            let inputs = (readLine()!).split(separator: " ").map(String.init)
            let sampleId = Int(inputs[0])!
            let carriedBy = Int8(inputs[1])!
            let rank = Int(inputs[2])!
            let expertiseGain = inputs[3]
            let health = Int(inputs[4])!
            let costA = Int(inputs[5])!
            let costB = Int(inputs[6])!
            let costC = Int(inputs[7])!
            let costD = Int(inputs[8])!
            let costE = Int(inputs[9])!

            var sample = SampleData(
                id: sampleId, 
                location: SampleData.Location(rawValue: carriedBy)!, 
                healthPoints: health, 
                costA: costA, 
                costB: costB, 
                costC: costC, 
                costD: costD, 
                costE: costE
            )

            samples.append(sample)
        }
    }

    update(target: target, health: health, storageA: storageA, storageB: storageB, storageC: storageC, storageD: storageD, storageE: storageE, samples: samples)
}
