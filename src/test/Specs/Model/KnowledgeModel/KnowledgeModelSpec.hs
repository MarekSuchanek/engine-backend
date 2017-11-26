module Specs.Model.KnowledgeModel.KnowledgeModelSpec where

import Control.Lens
import Data.Maybe
import qualified Data.UUID as U
import Test.Hspec hiding (shouldBe)
import Test.Hspec.Expectations.Pretty

import Model.KnowledgeModel.KnowledgeModel

import qualified
       Fixtures.KnowledgeModel.AnswersAndFollowUpQuestions as FA
import qualified Fixtures.KnowledgeModel.Chapters as FCH
import qualified Fixtures.KnowledgeModel.Experts as FE
import qualified Fixtures.KnowledgeModel.KnowledgeModels as FKM
import qualified Fixtures.KnowledgeModel.Questions as FQ
import qualified Fixtures.KnowledgeModel.References as FR

knowledgeModelSpec =
  describe "Knowledge Model" $ do
    describe "getAllChapters" $
      it "Successfully listed" $ getAllChapters FKM.km1 `shouldBe` [FCH.chapter1, FCH.chapter2]
    describe "isThereAnyChapterWithGivenUuid" $ do
      it "Returns True if exists" $ isThereAnyChapterWithGivenUuid FKM.km1 (FCH.chapter2 ^. chUuid) `shouldBe` True
      it "Returns False if not exists" $
        isThereAnyChapterWithGivenUuid FKM.km1 (fromJust . U.fromString $ "c2dec208-3e58-473c-8cc3-a3964658e540") `shouldBe`
        False
    ---------------------------------------------
    describe "getAllQuestions" $
      it "Successfully listed" $
      getAllQuestions FKM.km1 `shouldBe`
      [FQ.question1, FQ.question2, FQ.question3, FA.followUpQuestion1, FA.followUpQuestion2]
    describe "isThereAnyQuestionWithGivenUuid" $ do
      it "Returns True if exists" $
        isThereAnyQuestionWithGivenUuid FKM.km1 (FA.followUpQuestion1 ^. qUuid) `shouldBe` True
      it "Returns False if not exists" $
        isThereAnyQuestionWithGivenUuid FKM.km1 (fromJust . U.fromString $ "c2dec208-3e58-473c-8cc3-a3964658e540") `shouldBe`
        False
    ---------------------------------------------
    describe "getAllAnswers" $
      it "Successfully listed" $
      getAllAnswers FKM.km1 `shouldBe`
      [ FA.answerNo1
      , FA.answerYes1
      , FA.answerNo2
      , FA.answerYes2
      , FA.answerNo3
      , FA.answerYes3
      , FA.answerNo4
      , FA.answerYes4
      ]
    describe "isThereAnyAnswerWithGivenUuid" $ do
      it "Returns True if exists" $ isThereAnyAnswerWithGivenUuid FKM.km1 (FA.answerYes3 ^. ansUuid) `shouldBe` True
      it "Returns False if not exists" $
        isThereAnyAnswerWithGivenUuid FKM.km1 (fromJust . U.fromString $ "c2dec208-3e58-473c-8cc3-a3964658e540") `shouldBe`
        False
    ---------------------------------------------
    describe "getAllExperts" $
      it "Successfully listed" $ getAllExperts FKM.km1 `shouldBe` [FE.expertDarth, FE.expertLuke]
    describe "isThereAnyExpertWithGivenUuid" $ do
      it "Returns True if exists" $ isThereAnyExpertWithGivenUuid FKM.km1 (FE.expertDarth ^. expUuid) `shouldBe` True
      it "Returns False if not exists" $
        isThereAnyExpertWithGivenUuid FKM.km1 (fromJust . U.fromString $ "c2dec208-3e58-473c-8cc3-a3964658e540") `shouldBe`
        False
    ---------------------------------------------
    describe "getAllReferences" $
      it "Successfully listed" $ getAllReferences FKM.km1 `shouldBe` [FR.referenceCh1, FR.referenceCh2]
    describe "isThereAnyReferenceWithGivenUuid" $ do
      it "Returns True if exists" $
        isThereAnyReferenceWithGivenUuid FKM.km1 (FR.referenceCh1 ^. refUuid) `shouldBe` True
      it "Returns False if not exists" $
        isThereAnyReferenceWithGivenUuid FKM.km1 (fromJust . U.fromString $ "c2dec208-3e58-473c-8cc3-a3964658e540") `shouldBe`
        False