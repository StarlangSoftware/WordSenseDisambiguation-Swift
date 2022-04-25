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

public class TurkishSentenceAutoSemantic : SentenceAutoSemantic{
    
    private var turkishWordNet : WordNet
    private var fsm : FsmMorphologicalAnalyzer
    
    /**
     * Constructor for the {@link TurkishSentenceAutoSemantic} class. Gets the Turkish wordnet and Turkish fst based
     * morphological analyzer from the user and sets the corresponding attributes.
     - Parameters:
        - turkishWordNet: Turkish wordnet
        - fsm: Turkish morphological analyzer
     */
    public init(turkishWordNet: WordNet, fsm: FsmMorphologicalAnalyzer){
        self.turkishWordNet = turkishWordNet
        self.fsm = fsm
    }
    
    /**
     * The method checks
     * 1. the previous two words and the current word; the previous, current and next word, current and the next
     * two words for a three word multiword expression that occurs in the Turkish wordnet.
     * 2. the previous word and current word; current word and the next word for a two word multiword expression that
     * occurs in the Turkish wordnet.
     * 3. the current word
     * if it has only one sense. If there is only one sense for that multiword expression or word; it sets that sense.
     - Parameters:
        - sentence: The sentence for which word sense disambiguation will be determined automatically.
     */
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
                    let idioms : [SynSet] = turkishWordNet.constructIdiomSynSets(morphologicalParse1: twoPrevious!.getParse()!, morphologicalParse2: previous!.getParse()!, morphologicalParse3: current!.getParse()!, metaParse1: twoPrevious!.getMetamorphicParse()!, metaParse2: previous!.getMetamorphicParse()!, metaParse3: current!.getMetamorphicParse()!, fsm: fsm)
                    if idioms.count == 1 {
                        current!.setSemantic(semantic: idioms[0].getId())
                        done = true
                        continue
                    }
                }
                if previous != nil && previous!.getParse() != nil && next != nil && next!.getParse() != nil {
                    let idioms : [SynSet] = turkishWordNet.constructIdiomSynSets(morphologicalParse1: previous!.getParse()!, morphologicalParse2: current!.getParse()!, morphologicalParse3: next!.getParse()!, metaParse1: previous!.getMetamorphicParse()!, metaParse2: current!.getMetamorphicParse()!, metaParse3: next!.getMetamorphicParse()!, fsm: fsm)
                    if idioms.count == 1 {
                        current!.setSemantic(semantic: idioms[0].getId())
                        done = true
                        continue
                    }
                }
                if next != nil && next!.getParse() != nil && twoNext != nil && twoNext!.getParse() != nil {
                    let idioms : [SynSet] = turkishWordNet.constructIdiomSynSets(morphologicalParse1: current!.getParse()!, morphologicalParse2: next!.getParse()!, morphologicalParse3: twoNext!.getParse()!, metaParse1: current!.getMetamorphicParse()!, metaParse2: next!.getMetamorphicParse()!, metaParse3: twoNext!.getMetamorphicParse()!, fsm: fsm)
                    if idioms.count == 1 {
                        current!.setSemantic(semantic: idioms[0].getId())
                        done = true
                        continue
                    }
                }
                if previous != nil && previous!.getParse() != nil {
                    let idioms : [SynSet] = turkishWordNet.constructIdiomSynSets(morphologicalParse1: previous!.getParse()!, morphologicalParse2: current!.getParse()!, metaParse1: previous!.getMetamorphicParse()!, metaParse2: current!.getMetamorphicParse()!, fsm: fsm)
                    if idioms.count == 1 {
                        current!.setSemantic(semantic: idioms[0].getId())
                        done = true
                        continue
                    }
                }
                if current!.getSemantic() == nil && next != nil && next!.getParse() != nil {
                    let idioms : [SynSet] = turkishWordNet.constructIdiomSynSets(morphologicalParse1: current!.getParse()!, morphologicalParse2: next!.getParse()!, metaParse1: current!.getMetamorphicParse()!, metaParse2: next!.getMetamorphicParse()!, fsm: fsm)
                    if idioms.count == 1 {
                        current!.setSemantic(semantic: idioms[0].getId())
                        done = true;
                        continue;
                    }
                }
                let meanings : [SynSet] = turkishWordNet.constructSynSets(word: current!.getParse()!.getWord().getName(), parse: current!.getParse()!, metaParse: current!.getMetamorphicParse()!, fsm: fsm)
                if current!.getSemantic() == nil && meanings.count == 1 {
                    done = true
                    current!.setSemantic(semantic: meanings[0].getId())
                }
            }
        }
        return done
    }
}
