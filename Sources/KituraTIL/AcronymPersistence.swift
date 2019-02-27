/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import CouchDB
import LoggerAPI

extension Acronym {
    class Persistence {
        static func getAll(from database: Database, callback:
            @escaping (_ acronyms: [Acronym]?, _ error: Error?) -> Void) {
            database.retrieveAll(includeDocuments: true) { documents, error in
                guard let documents = documents else {
                    Log.error("Error retrieving all documents: \(String(describing: error))")
                    return callback(nil, error)
                }

                let acronyms = documents.decodeDocuments(ofType: Acronym.self)
                callback(acronyms, nil)
            }
        }

        static func save(_ acronym: Acronym, to database: Database, callback:
            @escaping (_ acronym: Acronym?, _ error: Error?) -> Void) {
            database.create(acronym) { document, error in
                guard let document = document else {
                    Log.error("Error creating new document: \(String(describing: error))")
                    return callback(nil, error)
                }

                database.retrieve(document.id, callback: callback)
            }
        }

        static func delete(_ acronymID: String, from database: Database, callback:
            @escaping (_ error: Error?) -> Void) {
            database.retrieve(acronymID) { (acronym: Acronym?, error: CouchDBError?) in
                guard let acronym = acronym, let acronymRev = acronym._rev else {
                    Log.error("Error retrieving document: \(String(describing:error))")
                    return callback(error)
                }

                database.delete(acronymID, rev: acronymRev, callback: callback)
            }
        }
    }
}
