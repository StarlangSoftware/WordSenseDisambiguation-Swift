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

public class Lesk : SentenceAutoSemantic{
    
    private var turkishWordNet : WordNet
    private var fsm : FsmMorphologicalAnalyzer
    
    /**
     * Constructor for the {@link Lesk} class. Gets the Turkish wordnet and Turkish fst based
     * morphological analyzer from the user and sets the corresponding attributes.
     - Parameters:
        - turkishWordNet: Turkish wordnet
        - fsm: Turkish morphological analyzer
     */
    public init(turkishWordNet: WordNet, fsm: FsmMorphologicalAnalyzer){
        self.turkishWordNet = turkishWordNet
        self.fsm = fsm
    }
    
    /// Calculates the number of words that occur (i) in the definition or example of the given synset and (ii) in the
    /// given sentence.
    /// - Parameters:
    ///   - synSet: Synset of which the definition or example will be checked
    ///   - sentence: Sentence to be annotated.
    /// - Returns: The number of words that occur (i) in the definition or example of the given synset and (ii) in the given
    /// sentence.
    private func intersection(synSet: SynSet, sentence: AnnotatedSentence) -> Int{
        var words1: [Substring]
        if synSet.getExample() != nil {
            words1 = (synSet.getLongDefinition()! + " " + synSet.getExample()!).split(separator: " ")
        } else {
            words1 = synSet.getLongDefinition()!.split(separator: " ")
        }
        let words2 = sentence.description().split(separator: " ")
        var count : Int = 0
        for word1 in words1 {
            for word2 in words2 {
                if Word.lowercase(s: String(word1)) == Word.lowercase(s: String(word2)) {
                    count += 1
                }
            }
        }
        return count
    }
    
    /// The method annotates the word senses of the words in the sentence according to the simplified Lesk algorithm.
    /// Lesk is an algorithm that chooses the sense whose definition or example shares the most words with the target
    /// word’s neighborhood. The algorithm processes target words one by one. First, the algorithm constructs an array of
    /// all possible senses for the target word to annotate. Then for each possible sense, the number of words shared
    /// between the definition of sense synset and target sentence is calculated. Then the sense with the maximum
    /// intersection count is selected.
    /// - Parameter sentence: Sentence to be annotated.
    /// - Returns: True, if at least one word is semantically annotated, false otherwise.
    public override func autoLabelSingleSemantics(sentence: AnnotatedSentence) -> Bool{
        var done : Bool = false
        for i in 0..<sentence.wordCount() {
            let synSets : [SynSet] = getCandidateSynSets(wordNet: turkishWordNet, fsm: fsm, sentence: sentence, index: i)
            var maxIntersection : Int = -1
            for j in 0..<synSets.count {
                let synSet = synSets[j]
                let intersectionCount = intersection(synSet: synSet, sentence: sentence)
                if intersectionCount > maxIntersection {
                    maxIntersection = intersectionCount
                }
            }
            var maxSynSets : [SynSet] = []
            for j in 0..<synSets.count {
                let synSet = synSets[j]
                if intersection(synSet: synSet, sentence: sentence) == maxIntersection {
                    maxSynSets.append(synSet)
                }
            }
            if maxSynSets.count > 0 {
                done = true
                (sentence.getWord(index: i) as? AnnotatedWord)!.setSemantic(semantic: maxSynSets[Int.random(in: 0..<maxSynSets.count)].getId())
            }
        }
        return done
    }
}
