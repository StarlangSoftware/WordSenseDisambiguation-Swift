import Foundation
import AnnotatedSentence
import WordNet
import MorphologicalAnalysis

public class SentenceAutoSemantic{
    
    /**
     * The method should set the senses of all words, for which there is only one possible sense.
     - Parameters:
        - sentence: The sentence for which word sense disambiguation will be determined automatically.
     */
    public func autoLabelSingleSemantics(sentence: AnnotatedSentence) -> Bool{return true}
    
    public func getCandidateSynSets(wordNet: WordNet, fsm: FsmMorphologicalAnalyzer, sentence: AnnotatedSentence, index: Int) -> [SynSet]{
        var twoPrevious : AnnotatedWord? = nil
        var previous : AnnotatedWord? = nil
        var twoNext : AnnotatedWord? = nil
        var next : AnnotatedWord? = nil
        var synSets : [SynSet] = []
        let current = sentence.getWord(index: index) as! AnnotatedWord
        if index > 1 {
            twoPrevious = sentence.getWord(index: index - 2) as? AnnotatedWord
        }
        if index > 0 {
            previous = sentence.getWord(index: index - 1) as? AnnotatedWord
        }
        if index != sentence.wordCount() - 1 {
            next = sentence.getWord(index: index + 1) as? AnnotatedWord
        }
        if (index < sentence.wordCount() - 2){
            twoNext = sentence.getWord(index: index + 2) as? AnnotatedWord
        }
        synSets = wordNet.constructSynSets(word: current.getParse()!.getWord().getName(),
                                           parse: current.getParse()!, metaParse: current.getMetamorphicParse()!, fsm: fsm)
        if twoPrevious != nil && twoPrevious!.getParse() != nil && previous!.getParse() != nil {
            synSets.append(contentsOf: wordNet.constructIdiomSynSets(morphologicalParse1: twoPrevious!.getParse()!, morphologicalParse2: previous!.getParse()!, morphologicalParse3: current.getParse()!,
                                                                     metaParse1: twoPrevious!.getMetamorphicParse()!, metaParse2: previous!.getMetamorphicParse()!, metaParse3: current.getMetamorphicParse()!, fsm: fsm))
        }
        if previous != nil && previous!.getParse() != nil && next != nil && next!.getParse() != nil {
            synSets.append(contentsOf: wordNet.constructIdiomSynSets(morphologicalParse1: previous!.getParse()!, morphologicalParse2: current.getParse()!, morphologicalParse3: next!.getParse()!,
                                                                     metaParse1: previous!.getMetamorphicParse()!, metaParse2: current.getMetamorphicParse()!, metaParse3: next!.getMetamorphicParse()!, fsm: fsm))
        }
        if next != nil && next!.getParse() != nil && twoNext != nil && twoNext!.getParse() != nil {
            synSets.append(contentsOf: wordNet.constructIdiomSynSets(morphologicalParse1: current.getParse()!, morphologicalParse2: next!.getParse()!, morphologicalParse3: twoNext!.getParse()!,
                                                                     metaParse1: current.getMetamorphicParse()!, metaParse2: next!.getMetamorphicParse()!, metaParse3: twoNext!.getMetamorphicParse()!, fsm: fsm))
        }
        if previous != nil && previous!.getParse() != nil {
            synSets.append(contentsOf: wordNet.constructIdiomSynSets(morphologicalParse1: previous!.getParse()!, morphologicalParse2: current.getParse()!,
                                                                     metaParse1: previous!.getMetamorphicParse()!, metaParse2: current.getMetamorphicParse()!, fsm: fsm))
        }
        if next != nil && next!.getParse() != nil {
            synSets.append(contentsOf: wordNet.constructIdiomSynSets(morphologicalParse1: current.getParse()!, morphologicalParse2: next!.getParse()!,
                                                                     metaParse1: current.getMetamorphicParse()!, metaParse2: next!.getMetamorphicParse()!, fsm: fsm))
        }
        return synSets
    }
    
    public func autoSemantic(sentence: AnnotatedSentence){
        if autoLabelSingleSemantics(sentence: sentence){
        }
    }
}
