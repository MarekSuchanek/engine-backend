module Wizard.Specs.Service.Questionnaire.Event.QuestionnaireEventServiceSpec where

import Control.Lens ((&), (.~), (^.))
import Data.Maybe (fromJust)
import Data.Time
import qualified Data.UUID as U
import Test.Hspec

import LensesConfig
import Shared.Model.Common.Lens
import Shared.Util.Uuid
import Wizard.Database.Migration.Development.Questionnaire.Data.QuestionnaireEvents
import Wizard.Database.Migration.Development.Questionnaire.Data.QuestionnaireVersions
import Wizard.Model.Questionnaire.QuestionnaireEvent
import Wizard.Model.Questionnaire.QuestionnaireEventLenses ()
import Wizard.Model.Questionnaire.QuestionnaireReply
import Wizard.Service.Questionnaire.Event.QuestionnaireEventService

-- ---------------------------
-- TESTS
-- ---------------------------
questionnaireEventServiceSpec appContext =
  describe "QuestionnaireEventService" $
  it "squash" $
      -- GIVEN: prepare data
   do
    let versions = [version1]
    let events =
          [ q1_event1
          , cre_rQ1'
          , q1_event2
          , sphse_1'
          , q1_event3
          , slble_rQ1'
          , q2_event1
          , q1_event4
          , q1_event5_nikola
          , q1_event6_anonymous1
          , q1_event7_nikola
          , q1_event8_nikola
          , q2_event2
          ]
      -- AND: prepare expectation
    let expEvents =
          [ cre_rQ1'
          , sphse_1'
          , slble_rQ1'
          , q2_event1
          , q1_event4
          , q1_event5_nikola
          , q1_event6_anonymous1
          , q1_event7_nikola
          , q1_event8_nikola
          , q2_event2
          ]
      -- WHEN:
    let resultEvents = squash versions events
      -- THEN:
    resultEvents `shouldBe` expEvents

-- ---------------------------
-- EVENTS
-- ---------------------------
q1_event1 :: QuestionnaireEvent
q1_event1 =
  SetReplyEvent' $
  SetReplyEvent
    { _setReplyEventUuid = u' "a493a8a9-4fba-4e2d-80a9-4b2a1d62f725"
    , _setReplyEventPath = "question1"
    , _setReplyEventValue = StringReply "question1_value_1"
    , _setReplyEventCreatedBy = albert
    , _setReplyEventCreatedAt = UTCTime (fromJust $ fromGregorianValid 2018 1 21) 0
    }

q1_event2 :: QuestionnaireEvent
q1_event2 =
  SetReplyEvent' $
  SetReplyEvent
    { _setReplyEventUuid = u' "313f6f3e-6fc1-4219-b370-0d2b486b3231"
    , _setReplyEventPath = "question1"
    , _setReplyEventValue = StringReply "question1_value_2"
    , _setReplyEventCreatedBy = albert
    , _setReplyEventCreatedAt = UTCTime (fromJust $ fromGregorianValid 2018 1 21) 1
    }

q1_event3 :: QuestionnaireEvent
q1_event3 =
  SetReplyEvent' $
  SetReplyEvent
    { _setReplyEventUuid = u' "0bd527f9-e2ee-4d05-914d-04702766ab48"
    , _setReplyEventPath = "question1"
    , _setReplyEventValue = StringReply "question1_value_3"
    , _setReplyEventCreatedBy = albert
    , _setReplyEventCreatedAt = UTCTime (fromJust $ fromGregorianValid 2018 1 21) 2
    }

q2_event1 :: QuestionnaireEvent
q2_event1 =
  SetReplyEvent' $
  SetReplyEvent
    { _setReplyEventUuid = u' "ea429c28-d5a6-47d7-ad5a-b2eb9e2aacc7"
    , _setReplyEventPath = "question2"
    , _setReplyEventValue = StringReply "question2_value_1"
    , _setReplyEventCreatedBy = albert
    , _setReplyEventCreatedAt = UTCTime (fromJust $ fromGregorianValid 2018 1 21) 3
    }

q1_event4 :: QuestionnaireEvent
q1_event4 =
  SetReplyEvent' $
  SetReplyEvent
    { _setReplyEventUuid = u' "be533d82-67e7-4de4-b46a-4db8b2bd8345"
    , _setReplyEventPath = "question1"
    , _setReplyEventValue = StringReply "question1_value_4"
    , _setReplyEventCreatedBy = albert
    , _setReplyEventCreatedAt = UTCTime (fromJust $ fromGregorianValid 2018 1 21) 4
    }

q1_event5_nikola :: QuestionnaireEvent
q1_event5_nikola =
  SetReplyEvent' $
  SetReplyEvent
    { _setReplyEventUuid = u' "401b39dc-f638-46ce-b139-3fa10bf8bc47"
    , _setReplyEventPath = "question1"
    , _setReplyEventValue = StringReply "question1_value_5"
    , _setReplyEventCreatedBy = nikola
    , _setReplyEventCreatedAt = UTCTime (fromJust $ fromGregorianValid 2018 1 21) 5
    }

q1_event6_anonymous1 :: QuestionnaireEvent
q1_event6_anonymous1 =
  SetReplyEvent' $
  SetReplyEvent
    { _setReplyEventUuid = u' "10dc346f-babf-4e7c-a220-fbbb6cc6d91c"
    , _setReplyEventPath = "question1"
    , _setReplyEventValue = StringReply "question1_value_6"
    , _setReplyEventCreatedBy = Nothing
    , _setReplyEventCreatedAt = UTCTime (fromJust $ fromGregorianValid 2018 1 21) 6
    }

q1_event7_nikola :: QuestionnaireEvent
q1_event7_nikola =
  SetReplyEvent' $
  SetReplyEvent
    { _setReplyEventUuid = u' "204e4e95-d4f2-402a-95d8-fe7cfccc9c50"
    , _setReplyEventPath = "question1"
    , _setReplyEventValue = StringReply "question1_value_7"
    , _setReplyEventCreatedBy = nikola
    , _setReplyEventCreatedAt = UTCTime (fromJust $ fromGregorianValid 2018 1 21) 7
    }

q1_event8_nikola :: QuestionnaireEvent
q1_event8_nikola =
  SetReplyEvent' $
  SetReplyEvent
    { _setReplyEventUuid = u' "58935613-63ff-4d7c-90b2-b9c6b1dd31f8"
    , _setReplyEventPath = "question1"
    , _setReplyEventValue = StringReply "question1_value_8"
    , _setReplyEventCreatedBy = nikola
    , _setReplyEventCreatedAt = UTCTime (fromJust $ fromGregorianValid 2018 1 21) 8
    }

q2_event2 :: QuestionnaireEvent
q2_event2 =
  SetReplyEvent' $
  SetReplyEvent
    { _setReplyEventUuid = u' "08576099-108d-4e22-ba7c-a023f5ef76f7"
    , _setReplyEventPath = "question2"
    , _setReplyEventValue = StringReply "question2_value_2"
    , _setReplyEventCreatedBy = albert
    , _setReplyEventCreatedAt = UTCTime (fromJust $ fromGregorianValid 2018 1 22) 0
    }

-- ---------------------------
-- VERSIONS
-- ---------------------------
version1 = questionnaireVersion1 & eventUuid .~ (q1_event7_nikola ^. uuid')

-- ---------------------------
-- USERS
-- ---------------------------
albert :: Maybe U.UUID
albert = Just $ u' "3e9da440-0a4f-43dc-86b0-0fe9009ae6f3"

nikola :: Maybe U.UUID
nikola = Just $ u' "dbcc9ac4-7e63-4d12-9a14-f2f918fd0a78"
