//: Playground - noun: a place where people can play

import Olympia

struct Vehicle: Olympia.Decodable {
    let make: String
    let model: String
    let year: Int?
    
    init(json: JSON) throws {
        make  = try json.decode("make")
        model = try json.decode("model")
        year  = json.int("year")
    }
}

let json: JSON = [
    "make" : "BMW",
    "model" : "M5",
    "year" : 2016
]

// Throwing initialization
do {
    let vehicle = try Vehicle(json: json)
    print(vehicle)
} catch let error as JSON.Error {
    print(error)
} catch {
    print("Unknown error")
}

// Optional initialization
let optionalVehicle = Vehicle.decode(json)
