//
//  BWColorWheel.swift
//  Bellwether-iOS
//
//  Created by Iurii Mozharovskyi on 4/7/16.
//  Copyright © 2016 Bellwether. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Bean {
    var flavorWheel: BWColorWheel {        
        return BWColorWheel.init(circle1Values: circle1,
                                 circle2Values: circle2,
                                 circle3Values: circle3)
    }
    
    fileprivate var circle1:  [BWColorWheel.Circle1] {
        return self.cuppingNotes1?.asCuppingNotes.map({note in
            BWColorWheel.Circle1.init(rawValue: note)
        }).flatMap({$0}) ?? []
    }
    
    fileprivate var circle2: [BWColorWheel.Circle2] {
        return self.cuppingNotes2?.asCuppingNotes.map({note in
            BWColorWheel.Circle2.init(rawValue: note)
        }).flatMap({$0}) ?? []
    }

    fileprivate var circle3: [BWColorWheel.Circle3] {
        return self.cuppingNotes3?.asCuppingNotes.map({note in
            BWColorWheel.Circle3.init(rawValue: note)
        }).flatMap({$0}) ?? []
    }
}

extension String {
    var asCuppingNotes: [String] {
        return self.uppercased().components(separatedBy: ",").map {note in
            return note.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "_")
        }
    }
}

struct BWColorWheel {
    var circle1Values = [Circle1:Bool]()
    var circle2Values = [Circle2:Bool]()
    var circle3Values = [Circle3:Bool]()

    init(circle1Values: [Circle1],
         circle2Values: [Circle2],
         circle3Values: [Circle3]) {
        circle1Values.forEach{value in self.circle1Values[value] = true}
        circle2Values.forEach{value in self.circle2Values[value] = true}
        circle3Values.forEach{value in self.circle3Values[value] = true}
    }
    
    func match(other: BWColorWheel) -> Double {
        let match = Set(values).intersection(Set(other.values)).count
        return Double(match)/Double(self.values.count)
    }
    
    var values: [String] {
        var result = [String]()
        
        //get the exact matches
        result.append(contentsOf: circle1Values.keys.map{$0.rawValue})
        result.append(contentsOf: circle2Values.keys.map{$0.rawValue})
        result.append(contentsOf: circle3Values.keys.map{$0.rawValue})
        
        //get the categories of any levels 2 & 3 matches
        result.append(contentsOf: circle2Values.keys.flatMap{$0.category?.stringValue})
        result.append(contentsOf: circle3Values.keys.flatMap{$0.category?.stringValue})
        
        //get the categories of the categories of level 3 matches
        result.append(contentsOf: circle3Values.keys.flatMap{$0.category?.category?.stringValue})
        
        return result
    }
    
    var description: String {
        let one = circle1Values.keys.joinStringValuesWithSeparator(",")
        let two = circle2Values.keys.joinStringValuesWithSeparator(",")
        let three = circle3Values.keys.joinStringValuesWithSeparator(",")
        return "\(one)/\(two)/\(three)"
    }
    
    static let inner: [Circle2:Circle1] = [
        .PaperyMusty:.Other,
        .Chemical:.Other,
        
        .PipeTobacco:.Roasted,
        .Tobacco:.Roasted,
        .Burnt:.Roasted,
        .Cereal:.Roasted,
        
        .Pungent:.Spices,
        .Pepper:.Spices,
        .BrownSpice:.Spices,
        
        .Nutty:.NuttyCocoa,
        .Cocoa:.NuttyCocoa,
        
        .BrownSugar:.Sweet,
        .Vanilla:.Sweet,
        .Vanillin:.Sweet,
        .OverallSweet:.Sweet,
        .SweetAromatics:.Sweet,
        
        .BlackTea:.Floral,
        .Floral:.Floral,
        
        .Berry:.Fruity,
        .DriedFruit:.Fruity,
        .OtherFruit:.Fruity,
        .CitrusFruit:.Fruity,
        
        .Sour:.SourFermented,
        .AlcoholFermented:.SourFermented,
        
        .OliveOil:.GreenVegetative,
        .Raw:.GreenVegetative,
        .GreenVegetative:.GreenVegetative,
        .Beany:.GreenVegetative
    ]
    
    static let outer: [Circle3:Circle2] = [
        .Stale:.PaperyMusty,
        .Cardboard:.PaperyMusty,
        .Papery:.PaperyMusty,
        .Woody:.PaperyMusty,
        .MoldyDamp:.PaperyMusty,
        .MustyDusty:.PaperyMusty,
        .MustyEarthy:.PaperyMusty,
        .Animalic:.PaperyMusty,
        .MeatyBrothy:.PaperyMusty,
        .Phenolic:.PaperyMusty,
        
        .Bitter:.Chemical,
        .Salty:.Chemical,
        .Medicinal:.Chemical,
        .Petroleum:.Chemical,
        .Skunky:.Chemical,
        .Rubber:.Chemical,
        
        .Acrid:.Burnt,
        .Ashy:.Burnt,
        .Smoky:.Burnt,
        .BrownRoast:.Burnt,
        
        .Malt:.Cereal,
        .Grain:.Cereal,
        
        .Clove:.BrownSpice,
        .Cinnamon:.BrownSpice,
        .Nutmeg:.BrownSpice,
        .Anise:.BrownSpice,
        
        .Peanuts:.Nutty,
        .Hazelnut:.Nutty,
        .Almond:.Nutty,
        
        .DarkChocolate:.Cocoa,
        .Chocolate:.Cocoa,
        
        .Honey:.BrownSugar,
        .Caramelized:.BrownSugar,
        .MapleSyrup:.BrownSugar,
        .Molasses:.BrownSugar,
        
        .Chamomile:.Floral,
        .Rose:.Floral,
        .Jasmine:.Floral,
        
        .Blackberry:.Berry,
        .Raspberry:.Berry,
        .Blueberry:.Berry,
        .Strawberry:.Berry,
        
        .Raisin:.DriedFruit,
        .Prune:.DriedFruit,
        
        .Coconut:.OtherFruit,
        .Cherry:.OtherFruit,
        .Pomegranate:.OtherFruit,
        .Pineapple:.OtherFruit,
        .Grape:.OtherFruit,
        .Apple:.OtherFruit,
        .Peach:.OtherFruit,
        .Pear:.OtherFruit,
        
        .Grapefruit:.CitrusFruit,
        .Orange:.CitrusFruit,
        .Lemon:.CitrusFruit,
        .Lime:.CitrusFruit,
        
        .SourAromatics:.Sour,
        .AceticAcid:.Sour,
        .ButyricAcid:.Sour,
        .IsovalericAcid:.Sour,
        .CitricAcid:.Sour,
        .MalicAcid:.Sour,
        
        .Winey:.AlcoholFermented,
        .Whiskey:.AlcoholFermented,
        .Fermented:.AlcoholFermented,
        .Overripe:.AlcoholFermented,
        
        .Underripe:.GreenVegetative,
        .Peapod:.GreenVegetative,
        .Fresh:.GreenVegetative,
        .DarkGreen:.GreenVegetative,
        .Vegetative:.GreenVegetative,
        .Haylike:.GreenVegetative,
        .Herblike:.GreenVegetative,
        ]

    
}


extension BWColorWheel: Equatable {}
func == (lhs: BWColorWheel, rhs: BWColorWheel) -> Bool {
    return bw_isEqualArraysOrNil(lhs: Array(lhs.circle1Values.keys), rhs: Array(rhs.circle1Values.keys)) &&
           bw_isEqualArraysOrNil(lhs: Array(lhs.circle2Values.keys), rhs: Array(rhs.circle2Values.keys)) &&
           bw_isEqualArraysOrNil(lhs: Array(lhs.circle3Values.keys), rhs: Array(rhs.circle3Values.keys))
}


extension BWColorWheel: BWFromJSONMappable {
    
    struct JSONKeys {
        static let Circle1Values = "circle1"
        static let Circle2Values = "circle2"
        static let Circle3Values = "circle3"
    }
    
    static func mapFromJSON(_ json: Any) throws -> BWColorWheel {
        let swiftyJSON = JSON(json)
        
        guard let circle1ValuesJSON = swiftyJSON[JSONKeys.Circle1Values].arrayObject as? [String],
              let circle2ValuesJSON = swiftyJSON[JSONKeys.Circle2Values].arrayObject as? [String],
              let circle3ValuesJSON = swiftyJSON[JSONKeys.Circle3Values].arrayObject as? [String] else {
                throw BWJSONMappableError.incorrectJSON
        }
        
        let circle1Values = try BWEnumRawTransformer<Circle1>().transformArrayFromJSON(circle1ValuesJSON)
        let circle2Values = try BWEnumRawTransformer<Circle2>().transformArrayFromJSON(circle2ValuesJSON)
        let circle3Values = try BWEnumRawTransformer<Circle3>().transformArrayFromJSON(circle3ValuesJSON)
        
        return BWColorWheel(circle1Values: circle1Values,
                            circle2Values: circle2Values,
                            circle3Values: circle3Values)
    }
}

struct FlavorAngle<T: Circle> {
    let angle: CGFloat
    let circle: T
    
    init(_ angle: CGFloat, _ circle:T) {
        self.angle = angle
        self.circle = circle
    }
}

extension BWColorWheel {
    
    enum Circle1: String, Circle {
        case Roasted = "ROASTED"
        case Spices = "SPICES"
        case NuttyCocoa = "NUTTY_COCOA"
        case Sweet = "SWEET"
        case Floral = "FLORAL"
        case Fruity = "FRUITY"
        case SourFermented = "SOUR_FERMENTED"
        case GreenVegetative = "GREEN_VEGETATIVE"
        case Other = "OTHER"
        
        var category: Circle? {
            return nil
        }
        
        static let angles: [FlavorAngle<BWColorWheel.Circle1>] =
            [
                FlavorAngle(3.30, .SourFermented),
                FlavorAngle(77.36, .Fruity),
                FlavorAngle(95.19, .Floral),
                FlavorAngle(130.1, .Sweet),
                FlavorAngle(151.32, .NuttyCocoa),
                FlavorAngle(177.41, .Spices),
                FlavorAngle(212.7, .Roasted),
                FlavorAngle(278.26, .Other),
                FlavorAngle(321.19, .GreenVegetative),
                FlavorAngle(360, .SourFermented)
        ]
        
        //var angles: [FlavorAngle] {return Circle1.angles}

    }

    enum Circle2: String, Circle {
        case PipeTobacco = "PIPE_TOBACCO"
        case Tobacco = "TOBACCO"
        case Burnt = "BURNT"
        case Cereal = "CEREAL"
        case Pungent = "PUNGENT"
        case Pepper = "PEPPER"
        case BrownSpice = "BROWN_SPICE"
        case Nutty = "NUTTY"
        case Cocoa = "COCOA"
        case BrownSugar = "BROWN_SUGAR"
        case Vanilla = "VANILLA"
        case Vanillin = "VANILLIN"
        case OverallSweet = "OVERALL_SWEET"
        case SweetAromatics = "SWEET_AROMATICS"
        case BlackTea = "BLACK_TEA"
        case Floral = "FLORAL"
        case Berry = "BERRY"
        case DriedFruit = "DRIED_FRUIT"
        case OtherFruit = "OTHER_FRUIT"
        case CitrusFruit = "CITRUS_FRUIT"
        case Sour = "SOUR"
        case AlcoholFermented = "ALCOHOL_FERMENTED"
        case OliveOil = "OLIVE_OIL"
        case Raw = "RAW"
        case GreenVegetative = "GREEN_VEGETATIVE"
        case Beany = "BEANY"
        case PaperyMusty = "PAPERY_MUSTY"
        case Chemical = "CHEMICAL"
        
        var category: Circle? {
            return BWColorWheel.inner[self]
        }
        
        static let angles: [FlavorAngle<BWColorWheel.Circle2>] =
            [
                FlavorAngle(3.30, .Sour),
                FlavorAngle(20.28, .CitrusFruit),
                FlavorAngle(52.28, .OtherFruit),
                FlavorAngle(60.5, .DriedFruit),
                FlavorAngle(77.36, .Berry),
                FlavorAngle(90.45, .Floral),
                FlavorAngle(95.19, .BlackTea),
                FlavorAngle(100.00, .SweetAromatics),
                FlavorAngle(104.3, .OverallSweet),
                FlavorAngle(108.53, .Vanillin),
                FlavorAngle(112.57, .Vanilla),
                FlavorAngle(130.1, .BrownSugar),
                FlavorAngle(139.2, .Cocoa),
                FlavorAngle(151.32, .Nutty),
                FlavorAngle(168.45, .BrownSpice),
                FlavorAngle(173.2, .Pepper),
                FlavorAngle(177.41, .Pungent),
                FlavorAngle(186.32, .Cereal),
                FlavorAngle(203.5, .Burnt),
                FlavorAngle(207.42, .Tobacco),
                FlavorAngle(212.11, .PipeTobacco),
                FlavorAngle(236.39, .Chemical),
                FlavorAngle(278.26, .PaperyMusty),
                FlavorAngle(283.21, .Beany),
                FlavorAngle(312.20, .GreenVegetative),
                FlavorAngle(316.51, .Raw),
                FlavorAngle(321.19, .OliveOil),
                FlavorAngle(338.18, .AlcoholFermented),
                FlavorAngle(360, .Sour)
        ]

        //var angles: [FlavorAngle] {return Circle2.angles}

    }

    enum Circle3: String, Circle {
        
        case Acrid = "ACRID"
        case Ashy = "ASHY"
        case Smoky = "SMOKY"
        case BrownRoast = "BROWN_ROAST"
        case Grain = "GRAIN"
        case Malt = "MALT"
        case Anise = "ANISE"
        case Nutmeg = "NUTMEG"
        case Cinnamon = "CINNAMON"
        case Clove = "CLOVE"
        case Peanuts = "PEANUTS"
        case Hazelnut = "HAZELNUT"
        case Almond = "ALMOND"
        case Chocolate = "CHOCOLATE"
        case DarkChocolate = "DARK_CHOCOLATE"
        case Molasses = "MOLASSES"
        case MapleSyrup = "MAPLE_SYRUP"
        case Caramelized = "CARAMELIZED"
        case Honey = "HONEY"
        case Chamomile = "CHAMOMILE"
        case Rose = "ROSE"
        case Jasmine = "JASMINE"
        case Blackberry = "BLACKBERRY"
        case Raspberry = "RASPBERRY"
        case Blueberry = "BLUEBERRY"
        case Strawberry = "STRAWBERRY"
        case Raisin = "RAISIN"
        case Prune = "PRUNE"
        case Coconut = "COCONUT"
        case Cherry = "CHERRY"
        case Pomegranate = "POMEGRANATE"
        case Pineapple = "PINEAPPLE"
        case Grape = "GRAPE"
        case Apple = "APPLE"
        case Peach = "PEACH"
        case Pear = "PEAR"
        case Grapefruit = "GRAPEFRUIT"
        case Orange = "ORANGE"
        case Lemon = "LEMON"
        case Lime = "LIME"
        case SourAromatics = "SOUR_AROMATICS"
        case AceticAcid = "ACETIC_ACID"
        case ButyricAcid = "BUTYRIC_ACID"
        case IsovalericAcid = "ISOVALERIC_ACID"
        case CitricAcid = "CITRIC_ACID"
        case MalicAcid = "MALIC_ACID"
        case Winey = "WINEY"
        case Whiskey = "WHISKEY"
        case Fermented = "FERMENTED"
        case Overripe = "OVERRIPE"
        case Underripe = "UNDER_RIPE"
        case Peapod = "PEAPOD"
        case Fresh = "FRESH"
        case DarkGreen = "DARK_GREEN"
        case Vegetative = "VEGETATIVE"
        case Haylike = "HAY_LIKE"
        case Herblike = "HERB_LIKE"
        case Stale = "STALE"
        case Cardboard = "CARDBOARD"
        case Papery = "PAPERY"
        case Woody = "WOODY"
        case MoldyDamp = "MOLDY_DAMP"
        case MustyDusty = "MUSTY_DUSTY"
        case MustyEarthy = "MUSTY_EARTHY"
        case Animalic = "ANIMALIC"
        case MeatyBrothy = "MEATY_BROTHY"
        case Phenolic = "PHENOLIC"
        case Bitter = "BITTER"
        case Salty = "SALTY"
        case Medicinal = "MEDICINAL"
        case Petroleum = "PETROLEUM"
        case Skunky = "SKUNKY"
        case Rubber = "RUBBER"
        
        var category: Circle? {
            return BWColorWheel.outer[self]
        }
        
        static let angles: [FlavorAngle<BWColorWheel.Circle3>] =
            [
                FlavorAngle(3.30, .SourAromatics),
                FlavorAngle(8.14, .Lime),
                FlavorAngle(12.13, .Lemon),
                FlavorAngle(16.35, .Orange),
                FlavorAngle(20.28, .Grapefruit),
                FlavorAngle(24.58, .Pear),
                FlavorAngle(28.55, .Peach),
                FlavorAngle(32.5, .Apple),
                FlavorAngle(36.49, .Grape),
                FlavorAngle(40.45, .Pineapple),
                FlavorAngle(44.37, .Pomegranate),
                FlavorAngle(48.29, .Cherry),
                FlavorAngle(52.28, .Coconut),
                FlavorAngle(56.56, .Prune),
                FlavorAngle(60.5, .Raisin),
                FlavorAngle(65.11, .Strawberry),
                FlavorAngle(69.7, .Blueberry),
                FlavorAngle(73.34, .Raspberry),
                FlavorAngle(77.36, .Blackberry),
                FlavorAngle(82.33, .Jasmine),
                FlavorAngle(86.24, .Rose),
                FlavorAngle(90.45, .Chamomile),
                FlavorAngle(117.24, .Honey),
                FlavorAngle(121.44, .Caramelized),
                FlavorAngle(126.3, .MapleSyrup),
                FlavorAngle(130.1, .Molasses),
                FlavorAngle(134.53, .DarkChocolate),
                FlavorAngle(139.2, .Chocolate),
                FlavorAngle(143.12, .Almond),
                FlavorAngle(147.14, .Hazelnut),
                FlavorAngle(151.32, .Peanuts),
                FlavorAngle(156.27, .Clove),
                FlavorAngle(160.32, .Cinnamon),
                FlavorAngle(164.25, .Nutmeg),
                FlavorAngle(168.45, .Anise),
                FlavorAngle(182.36, .Malt),
                FlavorAngle(186.32, .Grain),
                FlavorAngle(190.56, .BrownRoast),
                FlavorAngle(195.21, .Smoky),
                FlavorAngle(199.13, .Ashy),
                FlavorAngle(203.5, .Acrid),
                FlavorAngle(216.56, .Rubber),
                FlavorAngle(220.53, .Skunky),
                FlavorAngle(224.5, .Petroleum),
                FlavorAngle(228.46, .Medicinal),
                FlavorAngle(232.51, .Salty),
                FlavorAngle(236.39, .Bitter),
                FlavorAngle(241.24, .Phenolic),
                FlavorAngle(245.3, .MeatyBrothy),
                FlavorAngle(249.25, .Animalic),
                FlavorAngle(253.47, .MustyEarthy),
                FlavorAngle(257.5, .MustyDusty),
                FlavorAngle(261.42, .MoldyDamp),
                FlavorAngle(266.1, .Woody),
                FlavorAngle(270.31, .Papery),
                FlavorAngle(274.27, .Cardboard),
                FlavorAngle(278.26, .Stale),
                FlavorAngle(287.45, .Herblike),
                FlavorAngle(291.41, .Haylike),
                FlavorAngle(296.8, .Vegetative),
                FlavorAngle(300.6, .DarkGreen),
                FlavorAngle(304.25, .Fresh),
                FlavorAngle(308.18, .Peapod),
                FlavorAngle(312.20, .Underripe),
                FlavorAngle(326.5, .Overripe),
                FlavorAngle(330.6, .Fermented),
                FlavorAngle(334.24, .Whiskey),
                FlavorAngle(338.22, .Winey),
                FlavorAngle(342.49, .MalicAcid),
                FlavorAngle(346.45, .CitricAcid),
                FlavorAngle(351.4, .IsovalericAcid),
                FlavorAngle(355, .ButyricAcid),
                FlavorAngle(359.2, .AceticAcid),
                FlavorAngle(360, .SourAromatics)
        ]
        
        //var angles: [FlavorAngle<T>] {return Circle3.angles}

    }
}

protocol Circle {
    var category: Circle? {get}
    var stringValue: String {get}
}

extension BWColorWheel {
    
    mutating func toggle(_ value: Circle) {
        if let circle1 = value as? BWColorWheel.Circle1 {
            circle1Values[circle1] == nil ? self.add(value) : self.remove(value)
        } else if let circle2 = value as? BWColorWheel.Circle2 {
            circle2Values[circle2] == nil ? self.add(value) : self.remove(value)
        } else if let circle3 = value as? BWColorWheel.Circle3 {
            circle3Values[circle3] == nil ? self.add(value) : self.remove(value)
        }
    }
    
    mutating func add(_ value: Circle) {
        if let circle1 = value as? BWColorWheel.Circle1 {
            circle1Values[circle1] = true
        } else if let circle2 = value as? BWColorWheel.Circle2 {
            circle2Values[circle2] = true
        } else if let circle3 = value as? BWColorWheel.Circle3 {
            circle3Values[circle3] = true
        }
    }
    
    mutating func remove(_ value: Circle) {
        if let circle1 = value as? BWColorWheel.Circle1 {
            circle1Values.removeValue(forKey: circle1)
        } else if let circle2 = value as? BWColorWheel.Circle2 {
            circle2Values.removeValue(forKey: circle2)
        } else if let circle3 = value as? BWColorWheel.Circle3 {
            circle3Values.removeValue(forKey: circle3)
        }
    }
}

extension BWColorWheel.Circle1: BWStringValueRepresentable {
    var stringValue: String {
        get {
            
            let key = "SCA_C1_" + self.rawValue
            return key.localized
        }
    }
}

extension BWColorWheel.Circle2: BWStringValueRepresentable {
    var stringValue: String {
        get {
            let key = "SCA_C2_" + self.rawValue
            return key.localized
        }
    }
}

extension BWColorWheel.Circle3: BWStringValueRepresentable {
    var stringValue: String {
        get {
            let key = "SCA_C3_" + self.rawValue
            return key.localized
        }
    }
}
