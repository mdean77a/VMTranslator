//
//  CodeWriter.swift
//  VMTranslator
//
//  Created by J Michael Dean on 5/17/23.
//

import Foundation

struct CodeWriter{
    // API requesteed to include two functions
    
    func writeArithmetic(operand:String) -> String? {
        switch operand {
        case "add":
            return "Reached add assembly switch"
        case "sub":
            return "Reached sub assembly switch"
        case "neg":
            return "Reached neg assembly switch"
        case "eq":
            return "Reached eq assembly switch"
        case "gt":
            return "Reached gt assembly switch"
        case "lt":
            return "Reached lt assembly switch"
        case "and":
            return "Reached and assembly switch"
        case "or":
            return "Reached or assembly switch"
        case "not":
            return "Reached not assembly switch"
        default:
            return "ERROR - invalid operand"
        }

    }
    
    func writePushPop(command:CommandType, segment:String, value:String) -> String? {
        switch command {
        case .C_POP:
            return "Reached pop assembly switch"
        case .C_PUSH:
            return pushCommand(segment: segment, value: value)
        default:
            return nil
        }
    }
    
    func pushCommand(segment:String, value:String)-> String? {
        let commonPushString = "\nD=A\n@SP\nA=M\nM=D\n@SP\nM=M+1"
        switch segment {
        case "constant":
            return "@\(value)" + commonPushString
        default:
            return ""
        }

    }
}


