//
//  CodeWriter.swift
//  VMTranslator
//
//  Created by J Michael Dean on 5/17/23.
//

import Foundation

struct CodeWriter{
    
    // Reusable assembly strings
    let decrementSP = "@SP\nM=M-1\n"
    let incrementSP = "@SP\nM=M+1\n"
    let putValueOnStack = "D=A\n@SP\nA=M\nM=D\n"
    let assignD = "A=M\nD=M\n"
    let assignA = "A=M\n"
    let comparison = "@R13\nD=D-M\n"
    let comparisonFailed = "@SP\nM=M\nA=M\nM=0\n"       // Pushes false onto stack (0)
    let comparisonSucceeded = "@SP\nM=M\nA=M\nM=-1\n"   // Pushes true onto stack (-1)
    let pushSegmentValueToStack1 =  "D=M\n@R13\nM=D\n" //\(value)\nD=A\n@R13\nD=D+M\n@R14\nM=D\nA=D\nD=M\n"
    let pushSegmentValueToStack2 =  "\nD=A\n@R13\nD=D+M\n@R14\nM=D\nA=D\nD=M\n"
    // I KNOW that I should clean this code up to be more succinct.  I started out writing
    // assembly and after the first few, came up with some strings (shown above) to make it
    // easier.  But I clearly don't have the best patterns captured.  May revisit this
    // when we get to assignment 8.
    
    func writeArithmetic(operand:String) -> String? {
        switch operand {
        case "add":
            return "\(decrementSP)\(assignD)\(decrementSP)\(assignA)M=M+D\n\(incrementSP)"
        case "sub":
            return "\(decrementSP)\(assignD)\(decrementSP)\(assignA)M=M-D\n\(incrementSP)"
        case "neg":
            return "\(decrementSP)\(assignD)M=-D\n\(incrementSP)"
        case "eq":
            lineCounter += 1
            return
                """
                \(decrementSP)\(assignD)
                @R13
                M=D
                \(decrementSP)\(assignD)\(comparison)
                @EQUAL.\(lineCounter)
                D;JEQ
                \(comparisonFailed)
                @END.\(lineCounter)
                0;JMP
                (EQUAL.\(lineCounter))
                \(comparisonSucceeded)
                (END.\(lineCounter))
                \(incrementSP)
                """
        case "gt":
            lineCounter += 1
            return
                """
                \(decrementSP)\(assignD)
                @R13
                M=D
                \(decrementSP)\(assignD)\(comparison)
                @GREATERTHAN.\(lineCounter)
                D;JGT
                \(comparisonFailed)
                @END.\(lineCounter)
                0;JMP
                (GREATERTHAN.\(lineCounter))
                \(comparisonSucceeded)
                (END.\(lineCounter))
                \(incrementSP)
                """
        case "lt":
            lineCounter += 1
            return
                """
                \(decrementSP)\(assignD)
                @R13
                M=D
                \(decrementSP)\(assignD)\(comparison)
                @LESSTHAN.\(lineCounter)
                D;JLT
                \(comparisonFailed)
                @END.\(lineCounter)
                0;JMP
                (LESSTHAN.\(lineCounter))
                \(comparisonSucceeded)
                (END.\(lineCounter))
                \(incrementSP)
                """
        case "and":
            return "\(decrementSP)\(assignD)\(decrementSP)\(assignA)M=M&D\n\(incrementSP)"
        case "or":
            return "\(decrementSP)\(assignD)\(decrementSP)\(assignA)M=M|D\n\(incrementSP)"
        case "not":
            return "\(decrementSP)\(assignA)M=!M\n\(incrementSP)"
        default:
            return "//  ERROR - invalid operand"
        }
    }
    
    func writePushPop(command:CommandType, segment:String, value:String) -> String? {
        switch command {
        case .C_POP:
            return popCommand(segment:segment, value:value)
        case .C_PUSH:
            return pushCommand(segment: segment, value: value)
        default:
            return nil
        }
    }
    
    func pushCommand(segment:String, value:String)-> String? {
        //print("In push command segment value \(segment)")
        switch segment {
        case "constant":
            return "@\(value)\n\(putValueOnStack)\(incrementSP)"
        case "local":
            return
                """
                @LCL
                D=M
                @R13
                M=D
                @\(value)
                D=A
                @R13
                D=D+M
                @R14
                M=D
                A=D
                D=M
                @SP
                A=M
                M=D
                @SP
                M=M+1
                """
        case "argument":
            return
                """
                @ARG
                D=M
                @R13
                M=D
                @\(value)
                D=A
                @R13
                D=D+M
                @R14
                M=D
                A=D
                D=M
                @SP
                A=M
                M=D
                @SP
                M=M+1
                """
        case "this":
            return
                """
                @THIS
                D=M
                @R13
                M=D
                @\(value)
                D=A
                @R13
                D=D+M
                @R14
                M=D
                A=D
                D=M
                @SP
                A=M
                M=D
                @SP
                M=M+1
                """
        case "that":
            return
                """
                @THAT
                D=M
                @R13
                M=D
                @\(value)
                D=A
                @R13
                D=D+M
                @R14
                M=D
                A=D
                D=M
                @SP
                A=M
                M=D
                @SP
                M=M+1
                """
        case "temp":
            return
                """
                @5
                D=A
                @R13
                M=D
                @\(value)
                D=A
                @R13
                D=D+M
                @R14
                M=D
                A=D
                D=M
                @SP
                A=M
                M=D
                @SP
                M=M+1
                """
        case "pointer":
            if value == "0" {
                return
                    """
                    @THIS
                    D=M
                    @SP
                    A=M
                    M=D
                    @SP
                    M=M+1
                    """
                } else
                {
                return
                    """
                    @THAT
                    D=M
                    @SP
                    A=M
                    M=D
                    @SP
                    M=M+1
                    """
                }
        case "static":
            return
                """
                    @\(fileName).\(value)
                    D=M
                    @SP
                    A=M
                    M=D
                    @SP
                    M=M+1
                """
        default:
            return ""
        }

    }
}

func popCommand(segment:String, value:String)-> String? {
    switch segment {
    case "local":
        return
            """
            @LCL
            D=M
            @R13
            M=D
            @\(value)
            D=A
            @R13
            D=D+M
            M=D
            @SP
            M=M-1
            A=M
            D=M
            @R13
            A=M
            M=D
            """
    case "argument":
        return
            """
            @ARG
            D=M
            @R13
            M=D
            @\(value)
            D=A
            @R13
            D=D+M
            M=D
            @SP
            M=M-1
            A=M
            D=M
            @R13
            A=M
            M=D
            """
    case "this":
        return
            """
            @THIS
            D=M
            @R13
            M=D
            @\(value)
            D=A
            @R13
            D=D+M
            M=D
            @SP
            M=M-1
            A=M
            D=M
            @R13
            A=M
            M=D
            """
    case "that":
        return
            """
            @THAT
            D=M
            @R13
            M=D
            @\(value)
            D=A
            @R13
            D=D+M
            M=D
            @SP
            M=M-1
            A=M
            D=M
            @R13
            A=M
            M=D
            """
    case "temp":
        return
            """
            @5
            D=A
            @R13
            M=D
            @\(value)
            D=A
            @R13
            D=D+M
            M=D
            @SP
            M=M-1
            A=M
            D=M
            @R13
            A=M
            M=D
            """
    case "pointer":
        if value == "0" {
            return
                """
                @SP
                M=M-1
                A=M
                D=M
                @THIS
                M=D
                """
            } else
            {
            return
                """
                @SP
                M=M-1
                A=M
                D=M
                @THAT
                M=D
                """
            }
    case "static":
        return
            """
               @SP
               M=M-1
               A=M
               D=M
               @\(fileName).\(value)
               M=D
            """
    default:
        return ""
    
    }
}

