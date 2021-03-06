// Sources/protoc-gen-swift/ReservedWords.swift - Reserved words database and sanitizing
//
// Copyright (c) 2014 - 2016 Apple Inc. and the project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE.txt for license information:
// https://github.com/apple/swift-protobuf/blob/master/LICENSE.txt
//
// -----------------------------------------------------------------------------
///
/// Reserved words that the Swift code generator will avoid using.
///
// -----------------------------------------------------------------------------

import PluginLibrary

///
/// We won't generate types (structs, enums) with these names:
///
private let reservedTypeNames: Set<String> = {
    () -> Set<String> in
    var names: Set<String> = [
        "anyTypeURL",
        "debugDescription",
        "decodeField",
        "description",
        "dynamicType",
        "hashValue",
        "isEmpty",
        "isEqual",
        "jsonFieldNames",
        "traverse",
        "unknownFields",
    ]

    // We don't need to protect all of these keywords, just the ones
    // that interfere with type expressions:
    // names = names.union(PluginLibrary.swiftKeywordsReservedInParticularContexts)
    names.insert("Type")
    names.insert("Protocol")

    names = names.union(PluginLibrary.swiftKeywordsUsedInDeclarations)
    names = names.union(PluginLibrary.swiftKeywordsUsedInStatements)
    names = names.union(PluginLibrary.swiftKeywordsUsedInExpressionsAndTypes)
    names = names.union(PluginLibrary.swiftCommonTypes)
    names = names.union(PluginLibrary.swiftSpecialVariables)
    return names
}()

func sanitizeMessageTypeName(_ s: String) -> String {
    if reservedTypeNames.contains(s) {
        return s + "Message"
    } else if isAllUnderscore(s) {
        return s + "Message"
    } else {
        return s
    }
}


func sanitizeEnumTypeName(_ s: String) -> String {
    if reservedTypeNames.contains(s) {
        return s + "Enum"
    } else if isAllUnderscore(s) {
        return s + "Enum"
    } else {
        return s
    }
}

func sanitizeOneofTypeName(_ s: String) -> String {
    if reservedTypeNames.contains(s) {
        return s + "Oneof"
    } else if isAllUnderscore(s) {
        return s + "Oneof"
    } else {
        return s
    }
}

private let reservedFieldNames: Set<String> =  {
    () -> Set<String> in
    var names: Set<String> = [
            "debugDescription",
            "description",
            "dynamicType",
            "hashValue",
            "isInitialized",
            "jsonFieldNames",
            "unknownFields",
    ]

    // We don't need to protect all of these keywords, just the ones
    // that interfere with type expressions:
    // names = names.union(PluginLibrary.swiftKeywordsReservedInParticularContexts)
    names.insert("Type")
    names.insert("Protocol")

    names = names.union(PluginLibrary.swiftKeywordsUsedInDeclarations)
    names = names.union(PluginLibrary.swiftKeywordsUsedInStatements)
    names = names.union(PluginLibrary.swiftKeywordsUsedInExpressionsAndTypes)
    names = names.union(PluginLibrary.swiftCommonTypes)
    names = names.union(PluginLibrary.swiftSpecialVariables)
    return names
}()

/// Struct and class field names go through
/// this before going into the source code.
/// It appends "_p" to any name that can't be
/// used as a field name in Swift source code.
func sanitizeFieldName(_ s: String, basedOn: String) -> String {
    if reservedFieldNames.contains(basedOn) {
        return s + "_p"
    } else if isAllUnderscore(basedOn) {
        return s + "__"
    } else {
        return s
    }
}

func sanitizeFieldName(_ s: String) -> String {
  return sanitizeFieldName(s, basedOn: s)
}


/*
 * Many Swift reserved words can be used as enum cases if we put
 * backticks around them:
 */
private let quotableEnumCases: Set<String> = {
    () -> Set<String> in
    var names: Set<String> = []

    // We don't need to protect all of these keywords, just the ones
    // that interfere with enum cases:
    // names = names.union(PluginLibrary.swiftKeywordsReservedInParticularContexts)
    names.insert("associativity")
    names.insert("dynamicType")
    names.insert("optional")
    names.insert("required")

    names = names.union(PluginLibrary.swiftKeywordsUsedInDeclarations)
    names = names.union(PluginLibrary.swiftKeywordsUsedInStatements)
    names = names.union(PluginLibrary.swiftKeywordsUsedInExpressionsAndTypes)
    // Common type and variable names don't cause problems as enum
    // cases, because enum case names only appear in special contexts:
    // names = names.union(PluginLibrary.swiftCommonTypes)
    // names = names.union(PluginLibrary.swiftSpecialVariables)
    return names
}()

/*
 * Some words cannot be used for enum cases, even if they
 * are quoted with backticks:
 */
private let reservedEnumCases: Set<String> = [
            "debugDescription",
            "hashValue",
            "init",
            "rawValue",
            "self",
        ]

/*
 * Many Swift reserved words can be used as Extension names if we put
 * backticks around them.
 *
 * Note: To avoid the duplicate list to maintain, currently just reusing the
 *       EnumCases one.
 */
private let quotableMessageScopedExtensionNames: Set<String> = quotableEnumCases

/// enum case names are sanitized by adding
/// backticks `` around them.
func isAllUnderscore(_ s: String) -> Bool {
    for c in s.characters {
        if c != "_" {return false}
    }
    return true
}

func sanitizeEnumCase(_ s: String) -> String {
    if reservedEnumCases.contains(s) {
        return "\(s)_"
    } else if quotableEnumCases.contains(s) {
        return "`\(s)`"
    } else if isAllUnderscore(s) {
        return s + "__"
    } else {
        return s
    }
}

func sanitizeMessageScopedExtensionName(_ s: String, skipBackticks: Bool = false) -> String {
  // Since thing else is added to the "struct Extensions" for scoped
  // extensions, there is no need to have a reserved list.
  if quotableMessageScopedExtensionNames.contains(s) {
    if skipBackticks {
      return s
    }
    return "`\(s)`"
  } else if isAllUnderscore(s) {
    return s + "__"
  } else {
    return s
  }
}
