//
//  main.swift
//  DirectoryGenerator
//
//  Created by Bradley Hilton on 1/5/20.
//  Copyright © 2020 Brad Hilton. All rights reserved.
//

import Foundation
import Plot

let directory = (try? String(contentsOf: URL(fileURLWithPath: "directory.txt"))) ?? ""

struct Member {
    let name: String
    let phoneNumber: String
}

struct Apartment {
    let number: Int
    var members: [Member]
}

func parseApartments(from content: String) -> [Apartment] {
    var apartments: [Apartment] = []
    var apartment: Apartment? = nil
    var memberName: String? = nil
    for line in content.split(separator: "\n").filter({ !$0.isEmpty }).map(String.init) {
        if line.hasPrefix("Apartment") {
            if let apartment = apartment {
                apartments.append(apartment)
            }
            apartment = Apartment(number: Int(line.components(separatedBy: "Apartment ")[1])!, members: [])
        } else if let name = memberName {
            apartment?.members.append(
                Member(
                    name: name,
                    phoneNumber: line
                )
            )
            memberName = nil
        } else {
            memberName = line
        }
    }
    if let apartment = apartment {
        apartments.append(apartment)
    }
    return apartments
}

let apartments = parseApartments(from: directory)

let style = """
        
        main {
          margin: 0 auto;
          width: 8.5in;
        }

        h2 {
          text-align: center;
        }

        .grid {
          display: grid;
          grid-template-columns: 50% 50%;
          grid-template-rows: 33% 33% 33%;
          height: 9.5in;
        }

        .gridItem {
          text-align: center;
          display: flex;
          flex-direction: row;
          justify-content: center;
        }

        .gridItemColumn {
          display: flex;
          flex-direction: column;
          justify-content: center;
        }

        .memberImage {
          width: 2in;
          height: 2.6in;
          object-fit: cover;
          margin-bottom: 6px;
        }

        .pageBreak {
          page-break-before: always;
        }
    
"""

let html = HTML(
    .head(
        .title("Provo YSA 248th Ward Directory"),
        .meta(.charset(.utf8)),
        .style(style)
    ),
    .body(
        .main(
            .forEach(apartments) { apartment in
                .group([
                    .h2("Apartment \(apartment.number)"),
                    .div(
                        .class("grid"),
                        .forEach(apartment.members) { (member: Member) in
                            .div(
                                .class("gridItem"),
                                .div(
                                    .class("gridItemColumn"),
                                    .img(.class("memberImage"), .src("\(member.name).JPG")),
                                    .div("\(member.name)"),
                                    .div("\(member.phoneNumber)")
                                )
                            )
                        }
                    ),
                    .p(.class("pageBreak"))
                ])
            }
        )
    )
)

try! html.render(indentedBy: .spaces(2))
    .write(to: URL(fileURLWithPath: "index.html"), atomically: true, encoding: .utf8)

