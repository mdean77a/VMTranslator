//
//  Parser.swift
//  VMTranslator
//
//  Created by J Michael Dean on 5/17/23.
//

import Foundation
import RegexBuilder

struct Parser {
    // This parser is entirely based on regular expressions as recently implemented in Swift 5.7
    // and this greatly simplifies my thought process.  The special feature is the Capture(as:) command
    // that then allows passing parsed components by name to the calling routines.
    
    func pushInstruction(line:String) -> (CommandType, String, String)? {
        let segment = Reference(Substring.self)
        let value = Reference(Substring.self)
        let pushPattern = Regex {
            /^\s*push\s+/
            Capture(as:segment){
                /\S+/
            }
            /\s+/
            Capture(as:value){
                /\d+/
            }
        }
        if let match = try? pushPattern.firstMatch(in: line){
            return(CommandType.C_PUSH, String(match[segment]), String(match[value]))
        } else {
            return nil
        }
    }
    
    func popInstruction(line:String) -> (CommandType, String, String)? {
        let segment = Reference(Substring.self)
        let value = Reference(Substring.self)
        let popPattern = Regex {
            /^\s*pop\s+/
            Capture(as:segment){
                /\S+/
            }
            /\s+/
            Capture(as:value){
                /\d+/
            }
        }
        if let match = try? popPattern.firstMatch(in: line){
            return(CommandType.C_POP, String(match[segment]), String(match[value]))
        } else {
            return nil
        }
    }
    
    func arithmeticInstruction(line:String) -> String? {
        let operand = Reference(Substring.self)
        let arithmeticPattern = Regex {
            /^\s*/
            Capture(as:operand){
                /(a|s|n|e|g|l|o)/
                /\S+/
            }
        }
        if let match = try? arithmeticPattern.firstMatch(in: line){
            return String(match[operand])
        } else {
            return nil
        }
    }
}

