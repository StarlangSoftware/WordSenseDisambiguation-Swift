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

public class RandomSentenceAutoSemantic : SentenceAutoSemantic{
    
    private var turkishWordNet : WordNet
    private var fsm : FsmMorphologicalAnalyzer
    
    /**
     * Constructor for the {@link RandomSentenceAutoSemantic} class. Gets the Turkish wordnet and Turkish fst based
     * morphological analyzer from the user and sets the corresponding attributes.
     - Parameters:
        - turkishWordNet: Turkish wordnet
        - fsm: Turkish morphological analyzer
     */
    public init(turkishWordNet: WordNet, fsm: FsmMorphologicalAnalyzer){
        self.turkishWordNet = turkishWordNet
        self.fsm = fsm
    }

    public override func autoLabelSingleSemantics(sentence: AnnotatedSentence) -> Bool{
        for i in 0..<sentence.wordCount() {
            let synSets : [SynSet] = getCandidateSynSets(wordNet: turkishWordNet, fsm: fsm, sentence: sentence, index: i)
            if synSets.count > 0 {
                (sentence.getWord(index: i) as? AnnotatedWord)!.setSemantic(semantic: synSets[Int.random(in: 0..<synSets.count)].getId())
            }
        }
        return true
    }
}
