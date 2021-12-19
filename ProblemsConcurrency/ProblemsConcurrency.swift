//
//  ViewController.swift
//  ProblemsConcurrency
//
//  Created by user on 19.12.2021.
//

import UIKit

//Решение проблемы - RaceCondition
//Мы сделали последовательную очеред, но все равно происходит RaceCondition
//т.е даже Serial Queue не гарантирует нам, что поток будет безопасным

class RaceCondition{
    //Serial Queue
    
    private let threadSafeCountQueue = DispatchQueue(label: "serialQueue")
    private var _count = 0
    
    public var count: Int {
        
        get {
            return threadSafeCountQueue.sync {
                _count
            }
        }
        set {
            threadSafeCountQueue.sync {
                _count = newValue
            }
        }
    }
}

//использование барьера
class RaceConditionBarrier {
    
    private let threadSafeCountQueue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
    
    private var _conunt = 0
    
    public var count: Int {
        get {
            return threadSafeCountQueue.sync {
                _conunt
            }
        }
        set {
            threadSafeCountQueue.async(flags: .barrier) { [unowned self] in
                self._conunt = newValue
            }
        }
    }
}


class ProblemsConcurrency: UIViewController {
    
    
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        //        raceCondition()
        raceConditionWithBarrier()
    }
    
    func raceCondition() {
        
        let raceCondition = RaceConditionBarrier()
        //+ lock - устаревший способ синхр, но раб
        let lock = NSLock()
        
        //100 url фото по 10 грузить одновременно в 10 потоках
        //value - кол-во потоков который можно впускать
        //semaphore более современный чем lock
        
        let semaphore = DispatchSemaphore(value: 1)
        
        DispatchQueue.global().async(flags: .barrier) {
            //            lock.lock()
            semaphore.wait() //один вошле. Дверь закрыта
            raceCondition.count += 1
            print (raceCondition.count)
            print (Thread.current)
            
            //            lock.unlock()
            //semaphore.signal() //одтн вышел. Дверь открыта
        }
        
        DispatchQueue.global().async {
            //            lock.lock()
            semaphore.wait()
            raceCondition.count += 1
            print (raceCondition.count)
            print (Thread.current)
            //            lock.unlock()
            //semaphore.signal()
            
        }
        
        DispatchQueue.global().async(flags: .barrier) {
            //            lock.lock()
            //semaphore.wait()
            raceCondition.count += 1
            print (raceCondition.count)
            print (Thread.current)
            //            lock.unlock()
            //semaphore.signal()
        }
        
        
        
        DispatchQueue.global(qos: .background).async {
            
            print (raceCondition.count)
            print (Thread.current)
            
            DispatchQueue.main.async {
                self.label.text = String (raceCondition.count)
            }
            
        }
    }
    
    //использование барьеров
    func raceConditionWithBarrier() {
        
        let raceCondition = RaceConditionBarrier()
        
        let barrierQueue = DispatchQueue.global() //так не пойдет, требуется сделать кастомный dispatchQueue
        
        //кастом
        let castomBarrierQueue = DispatchQueue(label: "barrierQueue")
        
        castomBarrierQueue.async(flags: .barrier) {
            raceCondition.count += 1
            print (raceCondition.count)
            print (Thread.current)
        }
        
        castomBarrierQueue.async(flags: .barrier) {
            raceCondition.count += 1
            print (raceCondition.count)
            print (Thread.current)
        }
        
        castomBarrierQueue.async(flags: .barrier) {
            raceCondition.count += 1
            print (raceCondition.count)
            print (Thread.current)
        }
        
        castomBarrierQueue.async(flags: .barrier) {
            
            print (raceCondition.count)
            print (Thread.current)
            
            DispatchQueue.main.async {
                self.label.text = String (raceCondition.count)
            }
            
        }
    }
    
}

