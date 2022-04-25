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

    private func mostFrequent(synSets: [SynSet], root: String) -> SynSet?{
        if synSets.count == 1 {
            return synSets[0]
        }
        var minSense : Int = 50
        var best : SynSet? = nil
        for synSet in synSets {
            for i in 0..<synSet.getSynonym().literalSize() {
                if Word.lowercase(s: synSet.getSynonym().getLiteral(index: i).getName()).hasPrefix(root)
                    || Word.lowercase(s: synSet.getSynonym().getLiteral(index: i).getName()).hasSuffix(" " + root) {
                    if synSet.getSynonym().getLiteral(index: i).getSense() < minSense {
                        minSense = synSet.getSynonym().getLiteral(index: i).getSense()
                        best = synSet
                    }
                }
            }
        }
        return best
    }
    
    public override func autoLabelSingleSemantics(sentence: AnnotatedSentence) -> Bool{
        for i in 0..<sentence.wordCount() {
            let synSets : [SynSet] = getCandidateSynSets(wordNet: turkishWordNet, fsm: fsm, sentence: sentence, index: i)
            if synSets.count > 0 {
                let best = mostFrequent(synSets: synSets, root: ((sentence.getWord(index: i) as? AnnotatedWord)?.getParse()!.getWord().getName())!)
                if best != nil {
                    (sentence.getWord(index: i) as? AnnotatedWord)!.setSemantic(semantic: best!.getId())
                }
            }
        }
        return true
    }

}
