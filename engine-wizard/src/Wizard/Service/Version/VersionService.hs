module Wizard.Service.Version.VersionService
  ( publishPackage
  ) where

import Control.Lens ((.~), (?~), (^.))
import Control.Monad.Reader (liftIO)
import Data.Time
import Data.UUID as U

import LensesConfig hiding (squash)
import Shared.Model.Event.Event
import Shared.Service.Package.PackageUtil
import Wizard.Api.Resource.Package.PackageSimpleDTO
import Wizard.Api.Resource.Version.VersionDTO
import Wizard.Database.DAO.Branch.BranchDAO
import Wizard.Database.DAO.Branch.BranchDataDAO
import Wizard.Database.DAO.Common
import Wizard.Database.DAO.Migration.KnowledgeModel.MigratorDAO
import Wizard.Model.Branch.Branch
import Wizard.Model.Branch.BranchData
import Wizard.Model.Context.AppContext
import Wizard.Service.Acl.AclService
import Wizard.Service.Branch.BranchUtil
import Wizard.Service.Branch.Collaboration.CollaborationService
import Wizard.Service.Config.AppConfigService
import Wizard.Service.KnowledgeModel.Squash.Squasher
import Wizard.Service.Package.PackageService
import Wizard.Service.Version.VersionMapper
import Wizard.Service.Version.VersionValidation

publishPackage :: String -> String -> VersionDTO -> AppContextM PackageSimpleDTO
publishPackage bUuid pkgVersion reqDto =
  runInTransaction $ do
    checkPermission _KM_PUBLISH_PERM
    branch <- findBranchById bUuid
    branchData <- findBranchDataById bUuid
    mMs <- findMigratorStateByBranchUuid' bUuid
    case mMs of
      Just ms -> do
        deleteMigratorStateByBranchUuid (U.toString $ branch ^. uuid)
        doPublishPackage
          pkgVersion
          reqDto
          branch
          branchData
          (ms ^. resultEvents)
          (Just $ ms ^. targetPackageId)
          (Just $ upgradePackageVersion (ms ^. branchPreviousPackageId) pkgVersion)
      Nothing -> do
        mMergeCheckpointPkgId <- getBranchForkOfPackageId branch
        mForkOfPkgId <- getBranchMergeCheckpointPackageId branch
        doPublishPackage pkgVersion reqDto branch branchData (branchData ^. events) mForkOfPkgId mMergeCheckpointPkgId

-- --------------------------------
-- PRIVATE
-- --------------------------------
doPublishPackage ::
     String
  -> VersionDTO
  -> Branch
  -> BranchData
  -> [Event]
  -> Maybe String
  -> Maybe String
  -> AppContextM PackageSimpleDTO
doPublishPackage pkgVersion reqDto branch branchData branchEvents mForkOfPkgId mMergeCheckpointPkgId = do
  let squashedBranchEvents = squash branchEvents
  appConfig <- getAppConfig
  let org = appConfig ^. organization
  validateNewPackageVersion pkgVersion branch org
  now <- liftIO getCurrentTime
  let pkg = fromPackage branch reqDto mForkOfPkgId mMergeCheckpointPkgId org pkgVersion squashedBranchEvents now
  createdPkg <- createPackage pkg
  let updatedBranch = (previousPackageId ?~ (pkg ^. pId)) . (updatedAt .~ now) $ branch
  updateBranchById updatedBranch
  let updatedBranchData = (events .~ []) . (updatedAt .~ now) $ branchData
  updateBranchDataById updatedBranchData
  logOutOnlineUsersWhenBranchDramaticallyChanged (U.toString $ branch ^. uuid)
  return createdPkg
