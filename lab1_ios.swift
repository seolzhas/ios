
import Foundation

// LAB 1: Your Life Story in Swift

// Step 1: Personal Information

let firstName: String = "Olzhas"
let lastName: String = "Sengaliyev"
let age: Int = 23
let birthYear: Int = 2003
let isStudent: Bool = true
let height: Double = 1.78

// Additional personal detail
let city: String = "Almaty"

// Bonus: Calculate age
let currentYear = 2026
let calculatedAge = currentYear - birthYear

// Step 2: Hobbies and Interests

let hobby: String = "Sport Activities"
let numberOfHobbies: Int = 3
let favoriteNumber: Int = 7
let isHobbyCreative: Bool = true

// Additional hobby detail
let favoriteActivity: String = "Working"

// Bonus: Future Goals
let futureGoals: String = "Open an Educational Company"
let favoriteEmoji = "📸"

// Step 3: Create Life Story

let lifeStory = """
My name is \(firstName) \(lastName).
I am \(age) years old, born in \(birthYear).
I live in \(city).
I am currently a student: \(isStudent).
My height is \(height) meters.
My calculated age is \(calculatedAge).

My favorite hobby is \(hobby) \(favoriteEmoji).
I have \(numberOfHobbies) hobbies.
My favorite number is \(favoriteNumber).
Is my hobby creative? \(isHobbyCreative).
I enjoy \(favoriteActivity).

In the future, I want to \(futureGoals).
"""

// Step 4: Print Life Story

print(lifeStory)
