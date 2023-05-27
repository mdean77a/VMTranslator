//
//  main.swift
//  VMTranslator
//
//  Created by J Michael Dean on 5/17/23.
//
//  This is a console application that is NOT the same as a shell script containing Swift.
//  It is executable in any director, but has to be called as ./VMTranslator Filename.vm.
//  Many routines suggested in the text book are unnecessary because I utilized the stdio
//  conventions that make console applications attractive.

import Foundation

var parser = Parser()
var codeWriter = CodeWriter()

// This is used to assure unique labels in the code generated by the CodeWriter
// It is concatenated onto symbolic labels and iterated by an code generation that
// includes symbolic labels.  A cludge but it works.
var lineCounter = 0
var fileName = ""

enum CommandType {
    case C_ARITHMETIC, C_PUSH, C_POP, C_LABEL, C_GOTO, C_IF, C_FUNCTION, C_RETURN, C_CALL
}
// Do not need C_ARITHMETIC but here for completeness with textbook API.  For C_ARITHMETIC
// commands, the operand itself can be used as a selector in a switch statement.

func openFiles(){
    if CommandLine.arguments.dropFirst().count == 0 {
        print("USAGE: You need to provide a vm filename or a directory containing vm files.")
        return
    }
    
    // Process the single vm file situation
    if CommandLine.arguments[1].split(separator: ".").last == "vm" {
        fileName = String(CommandLine.arguments[1].split(separator: ".").first!)
        processFile(fileName:fileName)
    }
    
    // Argument was not VM file.  Check to see if it is a directory and process:
    let url = URL(fileURLWithPath: CommandLine.arguments[1])
    if url.hasDirectoryPath {
        let enumerator = FileManager.default.enumerator(atPath: url.lastPathComponent)
        let filePaths = enumerator?.allObjects as! [String]
        let vmFilePaths = filePaths.filter{$0.contains(".vm")}
        if vmFilePaths.isEmpty {
            print("ERROR: The directory contains no vm files.")
            return
        }
        for vmFile in vmFilePaths{
            fileName = url.lastPathComponent + "/" + vmFile.split(separator: ".").first!
            processFile(fileName: fileName)
        }
    }
}


func processFile(fileName:String) {
    print("Received filename in process files " + fileName)
    guard let sourceFile = freopen(fileName + ".vm", "r", stdin) else {
        print("ERROR: Could not open the source file.")
        return
    }
    
    guard let asmFile = freopen(fileName + ".asm", "w", stdout)
    else {
        print("ERROR: Could not create target file.")
        return}
    
    defer {
        fclose(sourceFile)
        fclose(asmFile)
    }
    
    print("//  Assembly translation of \(fileName).vm")
    print("//  J. Michael Dean VMTranslator, execution time: \(Date().addingTimeInterval(-21600))")
    print("//")
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
    print("//  End of assembly translation of \(fileName).vm")
    print("//  J. Michael Dean VMTranslator, completion time: \(Date().addingTimeInterval(-21600))")
    return
}


openFiles()
