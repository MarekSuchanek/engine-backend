module Database.BSON.Package.PackageWithEvents where

import Control.Lens ((^.))
import qualified Data.Bson as BSON
import Data.Bson.Generic
import Data.Maybe
import Data.UUID
import GHC.Generics

import Database.BSON.Common
import Database.BSON.Event.Answer
import Database.BSON.Event.Answer
import Database.BSON.Event.Chapter
import Database.BSON.Event.Common
import Database.BSON.Event.Expert
import Database.BSON.Event.FollowUpQuestion
import Database.BSON.Event.KnowledgeModel
import Database.BSON.Event.Question
import Database.BSON.Event.Reference
import Model.Event.Event
import Model.Package.Package

instance ToBSON PackageWithEvents where
  toBSON package =
    [ "id" BSON.=: package ^. pkgweId
    , "name" BSON.=: (package ^. pkgweName)
    , "groupId" BSON.=: (package ^. pkgweGroupId)
    , "artefactId" BSON.=: (package ^. pkgweArtefactId)
    , "version" BSON.=: (package ^. pkgweVersion)
    , "description" BSON.=: (package ^. pkgweDescription)
    , "parentPackage" BSON.=: (package ^. pkgweParentPackage)
    , "events" BSON.=: convertEventToBSON <$> (package ^. pkgweEvents)
    ]

instance FromBSON PackageWithEvents where
  fromBSON doc = do
    pkgId <- BSON.lookup "id" doc
    name <- BSON.lookup "name" doc
    groupId <- BSON.lookup "groupId" doc
    artefactId <- BSON.lookup "artefactId" doc
    version <- BSON.lookup "version" doc
    description <- BSON.lookup "description" doc
    parentPackage <- BSON.lookup "parentPackage" doc
    eventsSerialized <- BSON.lookup "events" doc
    let events = fmap (fromJust . chooseEventDeserializator) eventsSerialized
    return
      PackageWithEvents
      { _pkgweId = pkgId
      , _pkgweName = name
      , _pkgweGroupId = groupId
      , _pkgweArtefactId = artefactId
      , _pkgweVersion = version
      , _pkgweDescription = description
      , _pkgweParentPackage = parentPackage
      , _pkgweEvents = events
      }
