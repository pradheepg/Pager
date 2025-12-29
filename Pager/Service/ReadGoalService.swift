//
//  ReadGoalService.swift
//  Pager
//
//  Created by Pradheep G on 26/12/25.
//

import Foundation
import UIKit
import CoreData

class ReadGoalService {
    
    private let calendar = Calendar.current
    private let context = CoreDataManager.shared.context
    
    func getTodayReading() -> Int {
        guard let user = UserSession.shared.currentUser else {
            return 0
        }
        
        if let lastReset = user.lastProgressReset, !calendar.isDateInToday(lastReset) {
            return 0
        }
        
        return Int(user.todayReadingMinutes)
    }
    
    private func addMinutesToDailyTotal(_ minutesToAdd: Double) {
        guard let user = UserSession.shared.currentUser else { return }
        
        let now = Date()
        
        let lastReset = user.lastProgressReset ?? Date.distantPast
        let isNewDay = !calendar.isDateInToday(lastReset)
        
        if isNewDay {
            user.todayReadingMinutes = minutesToAdd
            user.lastProgressReset = now
        } else {
            user.todayReadingMinutes += minutesToAdd
            user.lastProgressReset = now
        }
        
        saveContext()
    }
    
    
    func updateTodayReading(startTime: Date, endTime: Date) {
        let differenceSeconds = endTime.timeIntervalSince(startTime)
        
        let minutesRead = differenceSeconds / 60.0
        
        guard minutesRead > 0 else { return }
        
        addMinutesToDailyTotal(minutesRead)
    }
    
    func updateDailyGoal(newGoal: Int) {
        guard let user = UserSession.shared.currentUser else { return }
        user.dailyReadingGoal = Int16(newGoal)
        saveContext()
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving ReadGoalService changes: \(error)")
            }
        }
    }
}

