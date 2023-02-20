//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 10.04.2021.
//

import Foundation
import WordNet
import MorphologicalAnalysis
import AnnotatedSentence
import Dictionary

public class MostFrequentSentenceAutoSemantic : SentenceAutoSemantic{
    
    private var turkishWordNet : WordNet
    private var fsm : FsmMorphologicalAnalyzer
    
    /**
     * Constructor for the {@link MostFrequentSentenceAutoSemantic} class. Gets the Turkish wordnet and Turkish fst based
     * morphological analyzer from the user and sets the corresponding attributes.
     - Parameters:
        - turkishWordNet: Turkish wordnet
        - fsm: Turkish morphological analyzer
     */
    public init(turkishWordNet: WordNet, fsm: FsmMorphologicalAnalyzer){
        self.turkishWordNet = turkishWordNet
        self.fsm = fsm
    }

    private func mostFrequent(literals: [Literal]) -> SynSet?{
        if literals.count == 1 {
            return self.turkishWordNet.getSynSetWithId(synSetId: literals[0].getSynSetId())
        }
        var minSense : Int = 50
        var best : SynSet? = nil
        for literal in literals {
            if literal.getSense() < minSense {
                minSense = literal.getSense()
                best = self.turkishWordNet.getSynSetWithId(synSetId: literal.getSynSetId())
            }
        }
        return best
    }
    
    public override func autoLabelSingleSemantics(sentence: AnnotatedSentence) -> Bool{
        var done : Bool = false
        var twoPrevious : AnnotatedWord? = nil
        var previous : AnnotatedWord? = nil
        var twoNext : AnnotatedWord? = nil
        var next : AnnotatedWord? = nil
        for i in 0..<sentence.wordCount() {
            let current = sentence.getWord(index: i) as? AnnotatedWord
            if i > 1 {
                twoPrevious = sentence.getWord(index: i - 2) as? AnnotatedWord
            }
            if i > 0 {
                previous = sentence.getWord(index: i - 1) as? AnnotatedWord
            }
            if i != sentence.wordCount() - 1 {
                next = sentence.getWord(index: i + 1) as? AnnotatedWord
            }
            if i < sentence.wordCount() - 2 {
                twoNext = sentence.getWord(index: i + 2) as? AnnotatedWord
            }
            if current!.getSemantic() == nil && current!.getParse() != nil {
                if twoPrevious != nil && twoPrevious!.getParse() != nil && previous!.getParse() != nil {
                    let literals : [Literal] = turkishWordNet.constructIdiomLiterals(morphologicalParse1: twoPrevious!.getParse()!, morphologicalParse2: previous!.getParse()!, morphologicalParse3: current!.getParse()!, metaParse1: twoPrevious!.getMetamorphicParse()!, metaParse2: previous!.getMetamorphicParse()!, metaParse3: current!.getMetamorphicParse()!, fsm: fsm)
                    if literals.count > 0 {
                        let bestSynSet = mostFrequent(literals: literals)
                        if bestSynSet != nil{
                            current!.setSemantic(semantic: (bestSynSet?.getId())!)
                            done = true
                            continue
                        }
                    }
                }
                if previous != nil && previous!.getParse() != nil && next != nil && next!.getParse() != nil {
                    let literals : [Literal] = turkishWordNet.constructIdiomLiterals(morphologicalParse1: previous!.getParse()!, morphologicalParse2: current!.getParse()!, morphologicalParse3: next!.getParse()!, metaParse1: previous!.getMetamorphicParse()!, metaParse2: current!.getMetamorphicParse()!, metaParse3: next!.getMetamorphicParse()!, fsm: fsm)
                    if literals.count > 0 {
                        let bestSynSet = mostFrequent(literals: literals)
                        if bestSynSet != nil{
                            current!.setSemantic(semantic: (bestSynSet?.getId())!)
                            done = true
                            continue
                        }
                    }
                }
                if next != nil && next!.getParse() != nil && twoNext != nil && twoNext!.getParse() != nil {
                    let literals : [Literal] = turkishWordNet.constructIdiomLiterals(morphologicalParse1: current!.getParse()!, morphologicalParse2: next!.getParse()!, morphologicalParse3: twoNext!.getParse()!, metaParse1: current!.getMetamorphicParse()!, metaParse2: next!.getMetamorphicParse()!, metaParse3: twoNext!.getMetamorphicParse()!, fsm: fsm)
                    if literals.count > 0 {
                        let bestSynSet = mostFrequent(literals: literals)
                        if bestSynSet != nil{
                            current!.setSemantic(semantic: (bestSynSet?.getId())!)
                            done = true
                            continue
                        }
                    }
                }
                if previous != nil && previous!.getParse() != nil {
                    let literals : [Literal] = turkishWordNet.constructIdiomLiterals(morphologicalParse1: previous!.getParse()!, morphologicalParse2: current!.getParse()!, metaParse1: previous!.getMetamorphicParse()!, metaParse2: current!.getMetamorphicParse()!, fsm: fsm)
                    if literals.count > 0 {
                        let bestSynSet = mostFrequent(literals: literals)
                        if bestSynSet != nil{
                            current!.setSemantic(semantic: (bestSynSet?.getId())!)
                            done = true
                            continue
                        }
                    }
                }
                if current!.getSemantic() == nil && next != nil && next!.getParse() != nil {
                    let literals : [Literal] = turkishWordNet.constructIdiomLiterals(morphologicalParse1: current!.getParse()!, morphologicalParse2: next!.getParse()!, metaParse1: current!.getMetamorphicParse()!, metaParse2: next!.getMetamorphicParse()!, fsm: fsm)
                    if literals.count > 0 {
                        let bestSynSet = mostFrequent(literals: literals)
                        if bestSynSet != nil{
                            current!.setSemantic(semantic: (bestSynSet?.getId())!)
                            done = true
                            continue
                        }
                    }
                }
                let literals : [Literal] = turkishWordNet.constructLiterals(word: current!.getParse()!.getWord().getName(), parse: current!.getParse()!, metaParse: current!.getMetamorphicParse()!, fsm: fsm)
                if current!.getSemantic() == nil && literals.count > 0 {
                    let bestSynSet = mostFrequent(literals: literals)
                    if bestSynSet != nil{
                        current!.setSemantic(semantic: (bestSynSet?.getId())!)
                        done = true
                        continue
                    }
                }
            }
        }
        return done
    }

}
