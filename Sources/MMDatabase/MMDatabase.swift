// The Swift Programming Language
// https://docs.swift.org/swift-book


import Foundation
import WCDBSwift

public struct MMDatabase{
    
    /// 初始化数据库(为避免多线程重复调用引起的初始化失败，请在主线程调用此方法，如初始化失败会在控制台打印相关错误信息)
    /// - Parameters:
    ///   - databaseFileURL: db所在的沙盒目录，要长这样的URL:file:///Users/Zhuanz/Library/Developer/CoreSimulator/Devices/695B4915-F0A3-48CB-BD63-A27F891C2B72/data/Library/PreferencePanes/mmdb.db
    ///   - databasePassword: `是否加密数据库，请注意，当你第一次没有加密数据库，同一个DB再也无法加密。请谨慎选择，建议早加密早安心. eg: "password".data(using: .ascii)`
    ///   - isTrace: `是否追踪错误信息，选择追踪错误信息后，会在控制台打印出来`
    /// - Returns: `初始化数据库` 是否成功
    @MainActor public static func setupDatabase(databaseFileURL: URL,
                                                databasePassword: Data?,
                                                isTrace: Bool) -> Bool
    {
        if isTrace {
            //全局监控
            if self.isTrace == false {
                Database.globalTraceError { print($0) }
                self.isTrace = true
            }
        }
        //如果已经初始化过了就返回
        if self.database != nil { return true }
        //根据传进来的DB路径创建DB
        let database = Database(at: databaseFileURL)
        //是否加密
        if let password = databasePassword {
            database.setCipher(key: password)
        }
        //强引用
        self.database = database
        //返回
        return self.database != nil
    }
    
    
    /// `获取数据库表`
    /// - Parameter type: `遵守了TableCodable的类型`
    /// - Returns: `对应模型的数据库表`
    public static func table<Root: TableCodable>(with type: Root.Type) -> Table<Root> {
        guard let database = self.database else { fatalError("哥们，你DB没初始化") }
        let tableName = self.tableName(with: type)
        try? database.create(table: tableName, of: type) //已经建的表不会重复建，底层有判断
        return database.getTable(named: tableName, of: type)
    }
    
    private init(){}
    static private var isTrace: Bool = false //标识是否已经监控错误信息
    static private var database: Database? //全局db (此字段也用于判断是否初始化过DB了)
    private static func tableName(with type: any TableCodable.Type) -> String {
        return String(describing: type)
    }
}

