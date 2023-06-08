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
    
    func labelInstruction(line:String) ->  String? {
        let labelSymbol = Reference(Substring.self)
        let labelPattern = Regex {
            /^\s*label\s+/
            Capture(as:labelSymbol){
                /\S+/
            }
        }
        if let match = try? labelPattern.firstMatch(in: line){
            return String(match[labelSymbol])
        } else {
            return nil
        }
    }
    
    func gotoInstruction(line:String) -> String?{
        let gotoDestination = Reference(Substring.self)
        let gotoPattern = Regex {
            /^\s*goto\s+/
            Capture(as:gotoDestination){
                /\S+/
            }
        }
        if let match = try? gotoPattern.firstMatch(in: line){
            return String(match[gotoDestination])
        } else {
            return nil
        }
    }
    
    func ifGotoInstruction(line:String) ->  String? {
        let gotoDestination = Reference(Substring.self)
        let ifGotoPattern = Regex {
            /^\s*if-goto\s+/
            Capture(as:gotoDestination){
                /\S+/
            }
        }
        if let match = try? ifGotoPattern.firstMatch(in: line){
            return(String(match[gotoDestination]))
        } else {
            return nil
        }
    }
    
    func functionInstruction(line:String) -> (String, String)? {
        let functionName = Reference(Substring.self)
        let nVars = Reference(Substring.self)
        let functionPattern = Regex {
            /^\s*function\s+/
            Capture(as:functionName){
                /\S+/
            }
            /\s+/
            Capture(as:nVars){
                /\d+/
            }
        }
        if let match = try? functionPattern.firstMatch(in: line) {
            return(String(match[functionName]),String(match[nVars]))
        } else {
            return nil
        }
    }
    
    func returnInstruction(line:String) -> String?{
        let returnCommand = Reference(Substring.self)
        let returnPattern = Regex {
            Capture(as:returnCommand){
                /^\s*return/
            }
        }
        if let match =  try? returnPattern.firstMatch(in: line) {
            return String(match[returnCommand])
        } else {
            return nil
        }
    }
    
    func callInstruction(line:String) -> (String, String)?{
        let functionName = Reference(Substring.self)
        let nArgs = Reference(Substring.self)
        let callPattern = Regex {
            /^\s*call\s+/
            Capture(as:functionName){
                /\S+/
            }
            /\s+/
            Capture(as:nArgs){
                /\d+/
            }
        }
        if let match =  try? callPattern.firstMatch(in: line) {
            return(String(match[functionName]),String(match[nArgs]))
        } else {
            return nil
        }
    }
}

