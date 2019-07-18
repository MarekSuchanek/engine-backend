module Database.BSON.Branch.BranchWithEvents where

import Control.Lens ((^.))
import qualified Data.Bson as BSON
import Data.Bson.Generic
import Data.Maybe

import Database.BSON.Common ()
import Database.BSON.Event.Common
import LensesConfig
import Model.Branch.Branch

instance ToBSON BranchWithEvents where
  toBSON branch =
    [ "uuid" BSON.=: (branch ^. uuid)
    , "name" BSON.=: (branch ^. name)
    , "kmId" BSON.=: (branch ^. kmId)
    , "metamodelVersion" BSON.=: (branch ^. metamodelVersion)
    , "parentPackageId" BSON.=: (branch ^. parentPackageId)
    , "lastAppliedParentPackageId" BSON.=: (branch ^. lastAppliedParentPackageId)
    , "lastMergeCheckpointPackageId" BSON.=: (branch ^. lastMergeCheckpointPackageId)
    , "ownerUuid" BSON.=: (branch ^. ownerUuid)
    , "events" BSON.=: convertEventToBSON <$> branch ^. events
    , "createdAt" BSON.=: (branch ^. createdAt)
    , "updatedAt" BSON.=: (branch ^. updatedAt)
    ]

instance FromBSON BranchWithEvents where
  fromBSON doc = do
    bUuid <- BSON.lookup "uuid" doc
    bName <- BSON.lookup "name" doc
    bKmId <- BSON.lookup "kmId" doc
    bMetamodelVersion <- BSON.lookup "metamodelVersion" doc
    bParentPackageId <- BSON.lookup "parentPackageId" doc
    bLastAppliedParentPackageId <- BSON.lookup "lastAppliedParentPackageId" doc
    bLastMergeCheckpointPackageId <- BSON.lookup "lastMergeCheckpointPackageId" doc
    bEventsSerialized <- BSON.lookup "events" doc
    let bEvents = fmap (fromJust . chooseEventDeserializator) bEventsSerialized
    let bOwnerUuid = BSON.lookup "ownerUuid" doc
    bCreatedAt <- BSON.lookup "createdAt" doc
    bUpdatedAt <- BSON.lookup "updatedAt" doc
    return
      BranchWithEvents
      { _branchWithEventsUuid = bUuid
      , _branchWithEventsName = bName
      , _branchWithEventsKmId = bKmId
      , _branchWithEventsMetamodelVersion = bMetamodelVersion
      , _branchWithEventsParentPackageId = bParentPackageId
      , _branchWithEventsLastAppliedParentPackageId = bLastAppliedParentPackageId
      , _branchWithEventsLastMergeCheckpointPackageId = bLastMergeCheckpointPackageId
      , _branchWithEventsEvents = bEvents
      , _branchWithEventsOwnerUuid = bOwnerUuid
      , _branchWithEventsCreatedAt = bCreatedAt
      , _branchWithEventsUpdatedAt = bUpdatedAt
      }
