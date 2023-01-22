//
//  DelayedSave.swift
//  simple-notes
//
//  Created by Luis Gonzalez on 22/1/23.
//

import Foundation

/// by @louis1001
/// In cases where you recieve a costant stream of changes, but you'd like to
/// avoid updating something expensive for every single change.
class DelayedSave<T>: ObservableObject {
    private let waitTime: TimeInterval
    private let saveInterval: TimeInterval
    
    private var lastItem: T?
    
    private var shortTimer: Timer?
    private var recurrentTimer: Timer!
    
    var saveAction: (T) async ->Void = {_ in }
    
    init(waitTime: TimeInterval = 0.2, saveInterval: TimeInterval = 5) {
        self.waitTime = waitTime
        self.saveInterval = saveInterval
        
        // En caso de que el usuario no pare de editar por bastante tiempo
        recurrentTimer = Timer.scheduledTimer(withTimeInterval: saveInterval, repeats: true) {[weak self] _ in
            if let lastItem = self?.lastItem {
                self?.doSave(lastItem)
            }
        }
    }
    
    func attempt(_ item: T) {
        self.lastItem = item
        shortTimer?.invalidate()
        shortTimer = Timer.scheduledTimer(withTimeInterval: self.waitTime, repeats: false) {[weak self] _ in
            self?.doSave(item)
        }
    }
    
    private func doSave(_ item: T) {
        Task {
            await saveAction(item)
        }
        lastItem = nil
    }
}
