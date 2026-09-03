//
//  AnimalListFilter.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/9/3.
//

/// 類別傳送資料用
struct AnimalListFilter: Equatable {
    var kind: AnimalKind?
    var sex: AnimalSex?
    var age: AnimalAge?
    var bodyType: AnimalBodyType?
    var area: TaiwanArea?
    var variety: String?
}

