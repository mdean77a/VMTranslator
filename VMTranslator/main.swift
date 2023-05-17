//
//  main.swift
//  VMTranslator
//
//  Created by J Michael Dean on 5/17/23.
//

import Foundation

var parser = Parser()
var codeWriter = CodeWriter()

enum CommandType {
    case C_ARITHMETIC, C_PUSH, C_POP, C_LABEL, C_GOTO, C_IF, C_FUNCTION, C_RETURN, C_CALL
}
// Do not need C_ARITHMETIC but here for completeness with textbook API.

func processFiles(){
    // Make sure that there is a file name or abort program
    if CommandLine.arguments.dropFirst().count == 0 {
        return
    }
    
    guard let sourceFile = freopen(CommandLine.arguments[1], "r", stdin) else {
        return
    }
    
    guard let asmFile = freopen(CommandLine.arguments[1].split(separator: ".").first! + ".asm", "w", stdout) else {
        return
    }
    defer {
        fclose(sourceFile)
        fclose(asmFile)
    }
    
    while let line = readLine(){
        if let (commandType, segment, value) = parser.pushInstruction(line: line){
            // call Codewriter routine to handle push instruction
            print("// push \(segment) \(value) " )  // My comment line
            print(codeWriter.writePushPop(command:commandType, segment: segment, value: value) ?? "")
        }
        
        if let (commandType, segment, value) = parser.popInstruction(line: line){
            // call Codewriter routine to handle pop instruction
            print("// pop  " + segment + " " + value )  // My comment line
            print(codeWriter.writePushPop(command:commandType, segment: segment, value: value) ?? "")
        }
        
        if let (operand) = parser.arithmeticInstruction(line: line){
            // call Codewriter routine to handle arithmetic instruction
            print("// " + operand)  // My comment line
            print(codeWriter.writeArithmetic(operand: operand) ?? "")
        }
    }
}
processFiles()
