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
    private var recurrentTimer: Timer?
    
    var saveAction: (T) async ->Void = {_ in }
    
    init(waitTime: TimeInterval = 0.2, saveInterval: TimeInterval = 2) {
        self.waitTime = waitTime
        self.saveInterval = saveInterval
    }
    
    func attempt(_ item: T, force: Bool = false) async {
        if self.lastItem == nil {
            // Al inicio de una nueva edición, activar el backup
            DispatchQueue.main.async { self.enableBackupTimer() }
        }
        
        self.lastItem = item
        shortTimer?.invalidate()
        if force {
            await doSave(item)
            return
        }
        
        DispatchQueue.main.async { self.enableShorttermTimer(item) }
    }
    
    func enableBackupTimer() {
        // En caso de que el usuario no pare de editar por bastante tiempo
        self.recurrentTimer = Timer.scheduledTimer(withTimeInterval: self.saveInterval, repeats: false) {[weak self] _ in
            if let lastItem = self?.lastItem {
                Task {[weak self] in
                    await self?.doSave(lastItem)
                }
            }
        }
    }
    
    func enableShorttermTimer(_ item: T) {
        self.shortTimer = Timer.scheduledTimer(withTimeInterval: self.waitTime, repeats: false) {[weak self] _ in
            Task {[weak self] in
                await self?.doSave(item)
            }
        }
    }
    
    private func doSave(_ item: T) async {
        recurrentTimer?.invalidate()
        recurrentTimer = nil
        
        await saveAction(item)
        lastItem = nil
    }
}
