//
//  ViewController.swift
//  iOS12
//
//  Created by CXY on 2019/5/5.
//  Copyright © 2019 cxy. All rights reserved.
//

import UIKit
import NaturalLanguage

class NaturalLanguageViewController: UIViewController {
    
    private let englishText = """
All human beings are born free and equal in dignity and rights.
They are endowed with reason and conscience and should act towards one another in a spirit of brotherhood.
"""
    
    private let pureChineseText = "美丽的西湖是杭州著名的风景名胜区。"
    
    private let chineseText = "这种格式可以通过短信、email发送、也可以放在网页上，在线浏览AR图像。"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Natural Language"
    }

    //MARK: 分词
    @IBAction func tokenizing() {
        let text = pureChineseText
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
//            print(text[tokenRange])
            print(text[tokenRange], separator: " ", terminator: " ")
            return true
        }
    }
    
    //MARK: 所属语言概率性识别
    @IBAction func languageRecognize() {
        // The most likely language for the processed text.
        let language = NLLanguageRecognizer.dominantLanguage(for: pureChineseText)
        print(language?.rawValue ?? "error")
        
        
        // Generates the probabilities of possible languages for the processed text
        let recg = NLLanguageRecognizer()
        recg.processString(chineseText)
        let ret = recg.languageHypotheses(withMaximum: 2)
        ret.forEach { (arg0) in
            
            let (key, value) = arg0
            print("\(key.rawValue) : \(value)")
        }
        
    }
    
    //MARK: 分类 nouns名词, verbs动词, adjectives形容词, 以及其他词
    @IBAction func linguisticTags() {
        
        let text = "The ripe taste of cheese improves with age."
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            if let tag = tag {
                print("\(text[tokenRange]): \(tag.rawValue)")
            }
            return true
        }
        
//        tagSpecificName()
    }
    
    
    //MARK: 分类人名、地名、组织名
    private func tagSpecificName() {
        let text = "The American Red Cross was established in Washington, D.C., by Clara Barton."
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let tags: [NLTag] = [.personalName, .placeName, .organizationName]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            if let tag = tag, tags.contains(tag) {
                print("\(text[tokenRange]): \(tag.rawValue)")
            }
            return true
        }
    }

    
}

