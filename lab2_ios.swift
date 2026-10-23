
import Foundation

// Lab 2
// Working with Collections

// Easy tasks

// 1
var fruits = ["apple", "banana", "orange", "grape", "mango"]
print(fruits[2])

// 2
var numbers: Set<Int> = [2, 5, 7, 10]
numbers.insert(15)
print(numbers)

// 3
var languages = [
    "Swift": 2014,
    "Python": 1991,
    "Java": 1995
]
print(languages["Swift"] ?? 0)

// 4
var colors = ["red", "blue", "green", "yellow"]
colors[1] = "black"
print(colors)


// Medium tasks

// 1
let set1: Set<Int> = [1, 2, 3, 4]
let set2: Set<Int> = [3, 4, 5, 6]

print(set1.intersection(set2))

// 2
var scores = [
    "Ali": 80,
    "John": 75,
    "Alex": 90
]

scores["Ali"] = 95
print(scores)

// 3
let arr1 = ["apple", "banana"]
let arr2 = ["cherry", "date"]

let arr3 = arr1 + arr2
print(arr3)


// Hard tasks

// 1
var countries = [
    "Kazakhstan": 20000000,
    "USA": 340000000,
    "Japan": 123000000
]

countries["Germany"] = 84000000
print(countries)

// 2
let animals1: Set<String> = ["cat", "dog"]
let animals2: Set<String> = ["dog", "mouse"]

let result1 = animals1.union(animals2)
let result2 = result1.subtracting(animals2)

print(result2)

// 3
var grades = [
    "Ali": [80, 85, 90],
    "John": [75, 88, 92],
    "Alex": [90, 95, 100]
]

print(grades["Ali"]?[1] ?? 0)
