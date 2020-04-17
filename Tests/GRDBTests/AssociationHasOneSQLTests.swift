import XCTest
import GRDB

/// Test SQL generation
class AssociationHasOneSQLTests: GRDBTestCase {

    func testSingleColumnNoForeignKeyNoPrimaryKey() throws {
        struct Child : TableRecord {
            static let databaseTableName = "children"
        }
        
        struct Parent : TableRecord, EncodableRecord {
            static let databaseTableName = "parents"
            func encode(to container: inout PersistenceContainer) {
                container["id"] = 1
                container["rowid"] = 2
            }
        }
        
        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.create(table: "parents") { t in
                t.column("id", .integer)
            }
            try db.create(table: "children") { t in
                t.column("parentId", .integer)
            }
        }
        
        try dbQueue.inDatabase { db in
            do {
                let association = Parent.hasOne(Child.self, using: ForeignKey([Column("parentId")]))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parentId" = "parents"."rowid"
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parentId" = "parents"."rowid"
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parentId" = "parents"."rowid"
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parentId" = "parents"."rowid"
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE \"parentId\" = 2")
            }
            do {
                let association = Parent.hasOne(Child.self, using: ForeignKey([Column("parentId")], to: [Column("id")]))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE \"parentId\" = 1")
            }
        }
    }
    
    func testSingleColumnNoForeignKey() throws {
        struct Child : TableRecord {
            static let databaseTableName = "children"
        }
        
        struct Parent : TableRecord, EncodableRecord {
            static let databaseTableName = "parents"
            func encode(to container: inout PersistenceContainer) {
                container["id"] = 1
            }
        }
        
        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.create(table: "parents") { t in
                t.column("id", .integer).primaryKey()
            }
            try db.create(table: "children") { t in
                t.column("parentId", .integer)
            }
        }
        
        try dbQueue.inDatabase { db in
            do {
                let association = Parent.hasOne(Child.self, using: ForeignKey([Column("parentId")]))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE \"parentId\" = 1")
            }
            do {
                let association = Parent.hasOne(Child.self, using: ForeignKey([Column("parentId")], to: [Column("id")]))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE \"parentId\" = 1")
            }
        }
    }
    
    func testSingleColumnSingleForeignKey() throws {
        struct Child : TableRecord {
            static let databaseTableName = "children"
        }
        
        struct Parent : TableRecord, EncodableRecord {
            static let databaseTableName = "parents"
            func encode(to container: inout PersistenceContainer) {
                container["id"] = 1
            }
        }
        
        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.create(table: "parents") { t in
                t.column("id", .integer).primaryKey()
            }
            try db.create(table: "children") { t in
                t.column("parentId", .integer).references("parents")
            }
        }
        
        try dbQueue.inDatabase { db in
            do {
                let association = Parent.hasOne(Child.self)
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE \"parentId\" = 1")
            }
            do {
                let association = Parent.hasOne(Child.self, using: ForeignKey([Column("parentId")]))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE \"parentId\" = 1")
            }
            do {
                let association = Parent.hasOne(Child.self, using: ForeignKey([Column("parentId")], to: [Column("id")]))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parentId" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE \"parentId\" = 1")
            }
        }
    }
    
    func testSingleColumnSeveralForeignKeys() throws {
        struct Child : TableRecord {
            static let databaseTableName = "children"
        }
        
        struct Parent : TableRecord, EncodableRecord {
            static let databaseTableName = "parents"
            func encode(to container: inout PersistenceContainer) {
                container["id"] = 1
            }
        }
        
        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.create(table: "parents") { t in
                t.column("id", .integer).primaryKey()
            }
            try db.create(table: "children") { t in
                t.column("parent1Id", .integer).references("parents")
                t.column("parent2Id", .integer).references("parents")
            }
        }
        
        try dbQueue.inDatabase { db in
            do {
                let association = Parent.hasOne(Child.self, using: ForeignKey([Column("parent1Id")]))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parent1Id" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parent1Id" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parent1Id" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parent1Id" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE \"parent1Id\" = 1")
            }
            do {
                let association = Parent.hasOne(Child.self, using: ForeignKey([Column("parent1Id")], to: [Column("id")]))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parent1Id" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parent1Id" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parent1Id" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parent1Id" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE \"parent1Id\" = 1")
            }
            do {
                let association = Parent.hasOne(Child.self, using: ForeignKey([Column("parent2Id")]))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parent2Id" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parent2Id" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parent2Id" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parent2Id" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE \"parent2Id\" = 1")
            }
            do {
                let association = Parent.hasOne(Child.self, using: ForeignKey([Column("parent2Id")], to: [Column("id")]))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parent2Id" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parent2Id" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON "children"."parent2Id" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON "children"."parent2Id" = "parents"."id"
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE \"parent2Id\" = 1")
            }
        }
    }
    
    func testCompoundColumnNoForeignKeyNoPrimaryKey() throws {
        struct Child : TableRecord {
            static let databaseTableName = "children"
        }
        
        struct Parent : TableRecord, EncodableRecord {
            static let databaseTableName = "parents"
            func encode(to container: inout PersistenceContainer) {
                container["a"] = 1
                container["b"] = 2
            }
        }
        
        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.create(table: "parents") { t in
                t.column("a", .integer)
                t.column("b", .integer)
            }
            try db.create(table: "children") { t in
                t.column("parentA", .integer)
                t.column("parentB", .integer)
            }
        }
        
        try dbQueue.inDatabase { db in
            do {
                let association = Parent.hasOne(Child.self, using: ForeignKey([Column("parentA"), Column("parentB")], to: [Column("a"), Column("b")]))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE (\"parentA\" = 1) AND (\"parentB\" = 2)")
            }
        }
    }
    
    func testCompoundColumnNoForeignKey() throws {
        struct Child : TableRecord {
            static let databaseTableName = "children"
        }
        
        struct Parent : TableRecord, EncodableRecord {
            static let databaseTableName = "parents"
            func encode(to container: inout PersistenceContainer) {
                container["a"] = 1
                container["b"] = 2
            }
        }
        
        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.create(table: "parents") { t in
                t.column("a", .integer)
                t.column("b", .integer)
                t.primaryKey(["a", "b"])
            }
            try db.create(table: "children") { t in
                t.column("parentA", .integer)
                t.column("parentB", .integer)
            }
        }
        
        try dbQueue.inDatabase { db in
            do {
                let association = Parent.hasOne(Child.self, using: ForeignKey([Column("parentA"), Column("parentB")]))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE (\"parentA\" = 1) AND (\"parentB\" = 2)")
            }
            do {
                let association = Parent.hasOne(Child.self, using: ForeignKey([Column("parentA"), Column("parentB")], to: [Column("a"), Column("b")]))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE (\"parentA\" = 1) AND (\"parentB\" = 2)")
            }
        }
    }
    
    func testCompoundColumnSingleForeignKey() throws {
        struct Child : TableRecord {
            static let databaseTableName = "children"
        }
        
        struct Parent : TableRecord, EncodableRecord {
            static let databaseTableName = "parents"
            func encode(to container: inout PersistenceContainer) {
                container["a"] = 1
                container["b"] = 2
            }
        }
        
        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.create(table: "parents") { t in
                t.column("a", .integer)
                t.column("b", .integer)
                t.primaryKey(["a", "b"])
            }
            try db.create(table: "children") { t in
                t.column("parentA", .integer)
                t.column("parentB", .integer)
                t.foreignKey(["parentA", "parentB"], references: "parents")
            }
        }
        
        try dbQueue.inDatabase { db in
            do {
                let association = Parent.hasOne(Child.self)
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE (\"parentA\" = 1) AND (\"parentB\" = 2)")
            }
            do {
                let association = Parent.hasOne(Child.self, using: ForeignKey([Column("parentA"), Column("parentB")]))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE (\"parentA\" = 1) AND (\"parentB\" = 2)")
            }
            do {
                let association = Parent.hasOne(Child.self, using: ForeignKey([Column("parentA"), Column("parentB")], to: [Column("a"), Column("b")]))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parentA" = "parents"."a") AND ("children"."parentB" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE (\"parentA\" = 1) AND (\"parentB\" = 2)")
            }
        }
    }
    
    func testCompoundColumnSeveralForeignKeys() throws {
        struct Child : TableRecord {
            static let databaseTableName = "children"
        }
        
        struct Parent : TableRecord, EncodableRecord {
            static let databaseTableName = "parents"
            func encode(to container: inout PersistenceContainer) {
                container["a"] = 1
                container["b"] = 2
            }
        }
        
        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.create(table: "parents") { t in
                t.column("a", .integer)
                t.column("b", .integer)
                t.primaryKey(["a", "b"])
            }
            try db.create(table: "children") { t in
                t.column("parent1A", .integer)
                t.column("parent1B", .integer)
                t.column("parent2A", .integer)
                t.column("parent2B", .integer)
                t.foreignKey(["parent1A", "parent1B"], references: "parents")
                t.foreignKey(["parent2A", "parent2B"], references: "parents")
            }
        }
        
        try dbQueue.inDatabase { db in
            do {
                let association = Parent.hasOne(Child.self, using: ForeignKey([Column("parent1A"), Column("parent1B")]))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parent1A" = "parents"."a") AND ("children"."parent1B" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parent1A" = "parents"."a") AND ("children"."parent1B" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parent1A" = "parents"."a") AND ("children"."parent1B" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parent1A" = "parents"."a") AND ("children"."parent1B" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE (\"parent1A\" = 1) AND (\"parent1B\" = 2)")
            }
            do {
                let association = Parent.hasOne(Child.self, using: ForeignKey([Column("parent1A"), Column("parent1B")], to: [Column("a"), Column("b")]))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parent1A" = "parents"."a") AND ("children"."parent1B" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parent1A" = "parents"."a") AND ("children"."parent1B" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parent1A" = "parents"."a") AND ("children"."parent1B" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parent1A" = "parents"."a") AND ("children"."parent1B" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE (\"parent1A\" = 1) AND (\"parent1B\" = 2)")
            }
            do {
                let association = Parent.hasOne(Child.self, using: ForeignKey([Column("parent2A"), Column("parent2B")]))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parent2A" = "parents"."a") AND ("children"."parent2B" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parent2A" = "parents"."a") AND ("children"."parent2B" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parent2A" = "parents"."a") AND ("children"."parent2B" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parent2A" = "parents"."a") AND ("children"."parent2B" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE (\"parent2A\" = 1) AND (\"parent2B\" = 2)")
            }
            do {
                let association = Parent.hasOne(Child.self, using: ForeignKey([Column("parent2A"), Column("parent2B")], to: [Column("a"), Column("b")]))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parent2A" = "parents"."a") AND ("children"."parent2B" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parents".*, "children".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parent2A" = "parents"."a") AND ("children"."parent2B" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    JOIN "children" ON ("children"."parent2A" = "parents"."a") AND ("children"."parent2B" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parents".* \
                    FROM "parents" \
                    LEFT JOIN "children" ON ("children"."parent2A" = "parents"."a") AND ("children"."parent2B" = "parents"."b")
                    """)
                try assertEqualSQL(db, Parent().request(for: association), "SELECT * FROM \"children\" WHERE (\"parent2A\" = 1) AND (\"parent2B\" = 2)")
            }
        }
    }
    
    func testForeignKeyDefinitionFromColumn() {
        // This test pass if code compiles
        struct Parent : TableRecord {
            static let databaseTableName = "parents"
            enum Columns {
                static let id = Column("id")
            }
            static let child1 = hasOne(Child.self, using: Child.ForeignKeys.parent1)
            static let child2 = hasOne(Child.self, using: Child.ForeignKeys.parent2)
        }
        
        struct Child : TableRecord {
            static let databaseTableName = "children"
            enum Columns {
                static let parentId = Column("parentId")
            }
            enum ForeignKeys {
                static let parent1 = ForeignKey([Columns.parentId])
                static let parent2 = ForeignKey([Columns.parentId], to: [Parent.Columns.id])
            }
        }
    }
    
    func testHasManyFirst() throws {
        struct Child: TableRecord { }
        struct Parent: TableRecord, EncodableRecord {
            func encode(to container: inout PersistenceContainer) {
                container["id"] = 1
                container["rowid"] = 2
            }
        }

        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.create(table: "parent") { t in
                t.autoIncrementedPrimaryKey("id")
            }
            try db.create(table: "child") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("parentId", .integer).references("parent")
            }
            
            do {
                let association = Parent
                    .hasMany(Child.self)
                    .orderByPrimaryKey()
                    .first
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parent".*, "child".* \
                    FROM "parent" \
                    JOIN "child" ON "child"."rowid" = (\
                    SELECT "child"."rowid" \
                    FROM "child" \
                    WHERE "child"."parentId" = "parent"."id" \
                    ORDER BY "child"."id" \
                    LIMIT 1)
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parent".*, "child".* \
                    FROM "parent" \
                    LEFT JOIN "child" ON "child"."rowid" = (\
                    SELECT "child"."rowid" \
                    FROM "child" \
                    WHERE "child"."parentId" = "parent"."id" \
                    ORDER BY "child"."id" \
                    LIMIT 1)
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parent".* \
                    FROM "parent" \
                    JOIN "child" ON "child"."rowid" = (\
                    SELECT "child"."rowid" \
                    FROM "child" \
                    WHERE "child"."parentId" = "parent"."id" \
                    ORDER BY "child"."id" \
                    LIMIT 1)
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parent".* \
                    FROM "parent" \
                    LEFT JOIN "child" ON "child"."rowid" = (\
                    SELECT "child"."rowid" \
                    FROM "child" \
                    WHERE "child"."parentId" = "parent"."id" \
                    ORDER BY "child"."id" \
                    LIMIT 1)
                    """)
                try assertEqualSQL(db, Parent().request(for: association), """
                    SELECT * FROM "child" \
                    WHERE "parentId" = 1 \
                    ORDER BY "id" \
                    LIMIT 1
                    """)
            }
        }
    }
    
    func testHasManyFirstWithDeeperAssociation() throws {
        struct Toy: TableRecord { }
        struct Child: TableRecord { }
        struct Parent: TableRecord, EncodableRecord {
            func encode(to container: inout PersistenceContainer) {
                container["id"] = 1
                container["rowid"] = 2
            }
        }

        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.create(table: "parent") { t in
                t.autoIncrementedPrimaryKey("id")
            }
            try db.create(table: "child") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("parentId", .integer).references("parent")
            }
            try db.create(table: "toy") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("childId", .integer).references("child")
            }

            do {
                let association = Parent
                    .hasMany(Child.self)
                    .orderByPrimaryKey()
                    .first
                    .joining(required: Child.hasOne(Toy.self))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parent".*, "child".* \
                    FROM "parent" \
                    JOIN "child" ON "child"."rowid" = (\
                    SELECT "child"."rowid" \
                    FROM "child" \
                    JOIN "toy" ON "toy"."childId" = "child"."id" \
                    WHERE "child"."parentId" = "parent"."id" \
                    ORDER BY "child"."id" \
                    LIMIT 1)
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parent".*, "child".* \
                    FROM "parent" \
                    LEFT JOIN "child" ON "child"."rowid" = (\
                    SELECT "child"."rowid" \
                    FROM "child" \
                    JOIN "toy" ON "toy"."childId" = "child"."id" \
                    WHERE "child"."parentId" = "parent"."id" \
                    ORDER BY "child"."id" \
                    LIMIT 1)
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parent".* \
                    FROM "parent" \
                    JOIN "child" ON "child"."rowid" = (\
                    SELECT "child"."rowid" \
                    FROM "child" \
                    JOIN "toy" ON "toy"."childId" = "child"."id" \
                    WHERE "child"."parentId" = "parent"."id" \
                    ORDER BY "child"."id" \
                    LIMIT 1)
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parent".* \
                    FROM "parent" \
                    LEFT JOIN "child" ON "child"."rowid" = (\
                    SELECT "child"."rowid" \
                    FROM "child" \
                    JOIN "toy" ON "toy"."childId" = "child"."id" \
                    WHERE "child"."parentId" = "parent"."id" \
                    ORDER BY "child"."id" \
                    LIMIT 1)
                    """)
                try assertEqualSQL(db, Parent().request(for: association), """
                    SELECT "child".* \
                    FROM "child" \
                    JOIN "toy" ON "toy"."childId" = "child"."id" \
                    WHERE "child"."parentId" = 1 \
                    ORDER BY "child"."id" \
                    LIMIT 1
                    """)
            }
            
            do {
                let association = Parent
                    .hasMany(Child.self)
                    .orderByPrimaryKey()
                    .first
                    .including(required: Child.hasOne(Toy.self))
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parent".*, "child".*, "toy".* \
                    FROM "parent" \
                    JOIN "child" ON "child"."rowid" = (\
                    SELECT "child"."rowid" \
                    FROM "child" \
                    JOIN "toy" ON "toy"."childId" = "child"."id" \
                    WHERE "child"."parentId" = "parent"."id" \
                    ORDER BY "child"."id" LIMIT 1) \
                    JOIN "toy" ON "toy"."childId" = "child"."id"
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parent".*, "toy".* \
                    FROM "parent" \
                    JOIN "child" ON "child"."rowid" = (\
                    SELECT "child"."rowid" \
                    FROM "child" \
                    JOIN "toy" ON "toy"."childId" = "child"."id" \
                    WHERE "child"."parentId" = "parent"."id" \
                    ORDER BY "child"."id" LIMIT 1) \
                    JOIN "toy" ON "toy"."childId" = "child"."id"
                    """)
                try assertEqualSQL(db, Parent().request(for: association), """
                    SELECT "child".*, "toy".* \
                    FROM "child" \
                    JOIN "toy" \
                    ON "toy"."childId" = "child"."id" \
                    WHERE "child"."parentId" = 1 \
                    ORDER BY "child"."id" \
                    LIMIT 1
                    """)
            }
            
            do {
                let alias = TableAlias()
                let association = Parent
                    .hasMany(Child.self)
                    .orderByPrimaryKey()
                    .filter(Column("id") == alias[Column("id")] + 1)
                    .first
                    .joining(required: Child.hasOne(Toy.self).filter(Column("id") == alias[Column("id")] * 2))
                try assertEqualSQL(db, Parent.all().aliased(alias).including(required: association), """
                    SELECT "parent".*, "child".* \
                    FROM "parent" \
                    JOIN "child" \
                    ON "child"."rowid" = (\
                    SELECT "child"."rowid" \
                    FROM "child" \
                    JOIN "toy" ON ("toy"."childId" = "child"."id") AND ("toy"."id" = ("parent"."id" * 2)) \
                    WHERE ("child"."parentId" = "parent"."id") AND ("child"."id" = ("parent"."id" + 1)) \
                    ORDER BY "child"."id" \
                    LIMIT 1)
                    """)
                try assertEqualSQL(db, Parent.all().aliased(alias).joining(required: association), """
                    SELECT "parent".* \
                    FROM "parent" \
                    JOIN "child" \
                    ON "child"."rowid" = (\
                    SELECT "child"."rowid" \
                    FROM "child" \
                    JOIN "toy" ON ("toy"."childId" = "child"."id") AND ("toy"."id" = ("parent"."id" * 2)) \
                    WHERE ("child"."parentId" = "parent"."id") AND ("child"."id" = ("parent"."id" + 1)) \
                    ORDER BY "child"."id" \
                    LIMIT 1)
                    """)
            }

            do {
                let alias = TableAlias()
                let association = Parent
                    .hasMany(Child.self)
                    .orderByPrimaryKey()
                    .filter(Column("id") == alias[Column("id")] + 1)
                    .first
                    .including(required: Child.hasOne(Toy.self).filter(Column("id") == alias[Column("id")] * 2))
                try assertEqualSQL(db, Parent.all().aliased(alias).including(required: association), """
                    SELECT "parent".*, "child".*, "toy".* \
                    FROM "parent" \
                    JOIN "child" \
                    ON "child"."rowid" = (\
                    SELECT "child"."rowid" \
                    FROM "child" \
                    JOIN "toy" ON ("toy"."childId" = "child"."id") AND ("toy"."id" = ("parent"."id" * 2)) \
                    WHERE ("child"."parentId" = "parent"."id") AND ("child"."id" = ("parent"."id" + 1)) \
                    ORDER BY "child"."id" \
                    LIMIT 1) \
                    JOIN "toy" \
                    ON ("toy"."childId" = "child"."id") AND ("toy"."id" = ("parent"."id" * 2))
                    """)
                try assertEqualSQL(db, Parent.all().aliased(alias).joining(required: association), """
                    SELECT "parent".*, "toy".* \
                    FROM "parent" \
                    JOIN "child" \
                    ON "child"."rowid" = (\
                    SELECT "child"."rowid" \
                    FROM "child" \
                    JOIN "toy" ON ("toy"."childId" = "child"."id") AND ("toy"."id" = ("parent"."id" * 2)) \
                    WHERE ("child"."parentId" = "parent"."id") AND ("child"."id" = ("parent"."id" + 1)) \
                    ORDER BY "child"."id" \
                    LIMIT 1) \
                    JOIN "toy" \
                    ON ("toy"."childId" = "child"."id") AND ("toy"."id" = ("parent"."id" * 2))
                    """)
            }
        }
    }

    func testHasManyLast() throws {
        struct Child: TableRecord { }
        struct Parent: TableRecord, EncodableRecord {
            func encode(to container: inout PersistenceContainer) {
                container["id"] = 1
                container["rowid"] = 2
            }
        }

        let dbQueue = try makeDatabaseQueue()
        try dbQueue.inDatabase { db in
            try db.create(table: "parent") { t in
                t.autoIncrementedPrimaryKey("id")
            }
            try db.create(table: "child") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("parentId", .integer).references("parent")
            }
            
            do {
                let association = Parent
                    .hasMany(Child.self)
                    .orderByPrimaryKey()
                    .last
                try assertEqualSQL(db, Parent.all().including(required: association), """
                    SELECT "parent".*, "child".* \
                    FROM "parent" \
                    JOIN "child" ON "child"."rowid" = (\
                    SELECT "child"."rowid" \
                    FROM "child" \
                    WHERE "child"."parentId" = "parent"."id" \
                    ORDER BY "child"."id" DESC \
                    LIMIT 1)
                    """)
                try assertEqualSQL(db, Parent.all().including(optional: association), """
                    SELECT "parent".*, "child".* \
                    FROM "parent" \
                    LEFT JOIN "child" ON "child"."rowid" = (\
                    SELECT "child"."rowid" \
                    FROM "child" \
                    WHERE "child"."parentId" = "parent"."id" \
                    ORDER BY "child"."id" DESC \
                    LIMIT 1)
                    """)
                try assertEqualSQL(db, Parent.all().joining(required: association), """
                    SELECT "parent".* \
                    FROM "parent" \
                    JOIN "child" ON "child"."rowid" = (\
                    SELECT "child"."rowid" \
                    FROM "child" \
                    WHERE "child"."parentId" = "parent"."id" \
                    ORDER BY "child"."id" DESC \
                    LIMIT 1)
                    """)
                try assertEqualSQL(db, Parent.all().joining(optional: association), """
                    SELECT "parent".* \
                    FROM "parent" \
                    LEFT JOIN "child" ON "child"."rowid" = (\
                    SELECT "child"."rowid" \
                    FROM "child" \
                    WHERE "child"."parentId" = "parent"."id" \
                    ORDER BY "child"."id" DESC \
                    LIMIT 1)
                    """)
                try assertEqualSQL(db, Parent().request(for: association), """
                    SELECT * FROM "child" \
                    WHERE "parentId" = 1 \
                    ORDER BY "id" DESC \
                    LIMIT 1
                    """)
            }
        }
    }
}
